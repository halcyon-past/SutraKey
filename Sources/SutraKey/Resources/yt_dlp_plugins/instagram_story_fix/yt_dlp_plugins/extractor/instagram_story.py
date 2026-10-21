import re
from yt_dlp.extractor.instagram import InstagramBaseIE, _pk_to_id
from yt_dlp.utils import (
    ExtractorError,
    filter_dict,
    str_or_none,
    traverse_obj,
)


class InstagramStoryIE(InstagramBaseIE):
    _VALID_URL = r'https?://(?:www\.)?instagram\.com/stories/(?P<user>[^/?#]+)(?:/(?P<id>\d+))?'
    IE_NAME = 'instagram:story'

    def _yeild_relay_data(self, video_id, webpage):
        for relay in re.findall(r'<script[^>]*data-sjs[^>]*>\s*({.*?})\s*</script>', webpage, re.DOTALL):
            parsed = self._parse_json(relay, video_id, fatal=False)
            if parsed:
                yield parsed

    def _get_user_id(self, webpage):
        return self._search_regex(
            (r'\b(?:reel_ids_arr|user_id)":\s*\[?"(\d{7,15})"',
             r'"profile_id":"(\d{7,15})"',
             r'"owner":\{"id":"(\d{7,15})"'),
            webpage, 'user id', default=None
        )

    def _real_extract(self, url):
        username, story_id = self._match_valid_url(url).group('user', 'id')
        if username == 'highlights' and not story_id:
            raise ExtractorError('Input URL is missing a highlight ID', expected=True)
        display_id = story_id or username
        story_webpage = self._download_webpage(
            url, display_id, impersonate=self._can_impersonate and self._is_web_app)

        user_id = self._get_user_id(story_webpage)

        # Fallback: if user_id is not in story webpage, query the user profile page directly
        if not user_id and username != 'highlights':
            profile_page = self._download_webpage(
                f'{self._BASE_URL}{username}/', display_id,
                fatal=False, impersonate=self._can_impersonate and self._is_web_app)
            if profile_page:
                user_id = self._get_user_id(profile_page) or self._search_regex(
                    r'"id":"(\d{7,15})"', profile_page, 'user id', default=None)

        if username == 'highlights':
            story_info_url = f'highlight:{story_id}'
        else:
            if not user_id:
                raise ExtractorError(f'Unable to extract user id for Instagram user @{username}')
            story_info_url = user_id

        # 1. First attempt: Extract story reel from data-sjs relay payloads
        videos = traverse_obj(self._yeild_relay_data(display_id, story_webpage), (
            ..., 'require', ..., ..., ..., '__bbox',
            'require', ..., ..., ..., '__bbox',
            'result', 'data', 'xdt_api__v1__feed__reels_media',
            'reels_media', {list}, lambda _, x: str(x.get('id', '')) == str(user_id), {dict},
        ), get_all=False)

        # 2. Second attempt: API query fallback
        if not videos:
            videos = traverse_obj(self._download_json(
                f'{self._API_BASE_URL}/feed/reels_media/?reel_ids={story_info_url}',
                display_id, errnote=False, fatal=False, headers=self._api_headers,
                impersonate=self._can_impersonate and self._is_web_app), 'reels')

        if not videos:
            if not self._is_logged_in:
                self.raise_login_required('You need to log in to access this content. Ensure you are logged into Instagram in your configured browser.')
            else:
                raise ExtractorError('No active stories found for this account (stories expire after 24 hours).', expected=True)

        user_info = traverse_obj(videos, (user_id, 'user', {dict})) or {}
        full_name = traverse_obj(videos, (f'highlight:{story_id}', 'user', 'full_name'), (user_id, 'user', 'full_name')) or username
        story_title = traverse_obj(videos, (f'highlight:{story_id}', 'title')) or f'Story by {username}'

        highlights = traverse_obj(videos, (f'highlight:{story_id}', 'items'), (user_id, 'items'), ('items', {list})) or []
        info_data = []

        for highlight in highlights:
            highlight.setdefault('user', {}).update(user_info)
            highlight_data = self._extract_product(highlight)
            item_id = _pk_to_id(highlight.get('pk') or highlight.get('id') or '')

            if highlight_data.get('formats'):
                info_data.append({
                    'uploader': full_name,
                    'uploader_id': user_id,
                    'title': story_title,
                    **filter_dict(highlight_data),
                })
            elif highlight.get('image_versions2', {}).get('candidates'):
                # Handle Photo / Static Image Stories cleanly
                candidates = highlight.get('image_versions2', {}).get('candidates', [])
                best_image = max(candidates, key=lambda c: (c.get('width') or 0) * (c.get('height') or 0)) if candidates else None
                image_url = best_image.get('url') if best_image else None
                if image_url:
                    info_data.append({
                        'id': item_id,
                        'uploader': full_name,
                        'uploader_id': user_id,
                        'title': story_title,
                        'url': image_url,
                        'ext': 'jpg',
                        'formats': [{
                            'url': image_url,
                            'ext': 'jpg',
                            'format_id': 'photo',
                            'width': best_image.get('width'),
                            'height': best_image.get('height'),
                            'vcodec': 'none',
                            'acodec': 'none',
                        }],
                        'thumbnails': [{'url': c.get('url')} for c in candidates if c.get('url')],
                    })

        # If a single story ID was requested, return only that item
        if username != 'highlights' and story_id and not self._yes_playlist(username, story_id):
            target_ids = {str(story_id)}
            try:
                target_ids.add(str(_pk_to_id(story_id)))
            except Exception:
                pass
            single_match = next((item for item in info_data if str(item.get('id', '')) in target_ids or str(item.get('pk', '')) in target_ids), None)
            if single_match:
                return single_match
            if info_data:
                raise ExtractorError(f'Story {story_id} was not found in active stories (it may have expired after 24 hours or been deleted).', expected=True)
            else:
                raise ExtractorError(f'No active stories found for @{username} (stories expire after 24 hours).', expected=True)

        return self.playlist_result(info_data, playlist_id=story_id or user_id, playlist_title=story_title)
