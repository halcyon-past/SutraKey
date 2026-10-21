#!/usr/bin/env python3
"""
Synchronize SutraKey release version and DMG SHA-256 across:
  1. Local Casks/sutrakey.rb in SutraKey repo
  2. Local homebrew-tap if installed in /opt/homebrew/Library/Taps/halcyon-past/homebrew-tap
  3. Remote halcyon-past/homebrew-tap via GitHub API (gh api)
"""

import argparse
import base64
import json
import os
import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
LOCAL_CASK_PATH = ROOT_DIR / "Casks" / "sutrakey.rb"
LOCAL_TAP_DIR = Path("/opt/homebrew/Library/Taps/halcyon-past/homebrew-tap")


def update_cask_content(content: str, version: str, sha256: str) -> str:
    content = re.sub(
        r'(^\s*version\s+")[^"]+(")',
        rf'\g<1>{version}\g<2>',
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r'(^\s*sha256\s+")[^"]+(")',
        rf'\g<1>{sha256}\g<2>',
        content,
        flags=re.MULTILINE,
    )
    return content


def run_gh_api(args: list[str], token: str | None = None) -> str:
    env = os.environ.copy()
    if token:
        env["GH_TOKEN"] = token
    result = subprocess.run(
        ["gh", "api", *args],
        env=env,
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def sync_local_tap(cask_content: str, version: str) -> bool:
    if not LOCAL_TAP_DIR.exists():
        print(f"ℹ️ Local tap directory not found at {LOCAL_TAP_DIR}, skipping local tap copy.")
        return False

    tap_casks_dir = LOCAL_TAP_DIR / "Casks"
    tap_casks_dir.mkdir(parents=True, exist_ok=True)
    target_cask = tap_casks_dir / "sutrakey.rb"

    target_cask.write_text(cask_content, encoding="utf-8")
    print(f"✅ Updated local tap cask at {target_cask}")

    # Check git status in local tap
    status = subprocess.run(
        ["git", "-C", str(LOCAL_TAP_DIR), "status", "--porcelain"],
        capture_output=True,
        text=True,
    )
    if "sutrakey.rb" in status.stdout:
        subprocess.run(["git", "-C", str(LOCAL_TAP_DIR), "add", "Casks/sutrakey.rb"], check=True)
        subprocess.run(
            ["git", "-C", str(LOCAL_TAP_DIR), "commit", "-m", f"bump(sutrakey): update cask to v{version}"],
            check=True,
        )
        # Push if possible
        try:
            subprocess.run(["git", "-C", str(LOCAL_TAP_DIR), "push", "origin", "main"], check=True)
            print("🚀 Pushed local tap commit to origin/main successfully!")
        except Exception as e:
            print(f"⚠️ Could not push local tap repository: {e}")
        return True
    return False


def sync_remote_tap_api(cask_content: str, version: str, tap_repo: str = "halcyon-past/homebrew-tap", token: str | None = None) -> bool:
    endpoint = f"repos/{tap_repo}/contents/Casks/sutrakey.rb"
    remote_sha = None
    try:
        raw = run_gh_api([endpoint], token)
        data = json.loads(raw)
        remote_sha = data.get("sha")
        remote_content = base64.b64decode(data.get("content", "")).decode("utf-8")
        if remote_content.strip() == cask_content.strip():
            print(f"✅ Remote tap ({tap_repo}) is already up to date at v{version}.")
            return False
    except subprocess.CalledProcessError:
        # File doesn't exist yet on remote tap
        print(f"ℹ️ Casks/sutrakey.rb does not exist yet on {tap_repo}. Will create it.")

    b64_payload = base64.b64encode(cask_content.encode("utf-8")).decode("utf-8")
    commit_msg = f"bump(sutrakey): update cask to v{version}"
    args = [
        "--method",
        "PUT",
        endpoint,
        "-f",
        f"message={commit_msg}",
        "-f",
        f"content={b64_payload}",
    ]
    if remote_sha:
        args.extend(["-f", f"sha={remote_sha}"])

    out = run_gh_api(args, token)
    print(f"🚀 Updated remote Homebrew tap ({tap_repo}) via API to v{version}!")
    return True


def main():
    parser = argparse.ArgumentParser(description="Synchronize SutraKey version & DMG SHA-256")
    parser.add_argument("--version", required=True, help="Release version (e.g. 1.0.0)")
    parser.add_argument("--sha256", required=True, help="DMG SHA-256 hash")
    parser.add_argument("--tap-repo", default="halcyon-past/homebrew-tap", help="Target Homebrew tap repository")
    args = parser.parse_args()

    # 1. Update local Cask in SutraKey repo
    if not LOCAL_CASK_PATH.exists():
        print(f"❌ Error: {LOCAL_CASK_PATH} does not exist!")
        sys.exit(1)

    cask_text = LOCAL_CASK_PATH.read_text(encoding="utf-8")
    updated_cask = update_cask_content(cask_text, args.version, args.sha256)
    LOCAL_CASK_PATH.write_text(updated_cask, encoding="utf-8")
    print(f"✅ Updated local Cask: {LOCAL_CASK_PATH} (v{args.version}, sha256: {args.sha256})")

    # 2. Update local tap directory if present
    sync_local_tap(updated_cask, args.version)

    # 3. Update remote GitHub Homebrew tap
    token = os.environ.get("HOMEBREW_TAP_TOKEN") or os.environ.get("GH_TOKEN")
    try:
        sync_remote_tap_api(updated_cask, args.version, args.tap_repo, token)
    except Exception as e:
        print(f"ℹ️ Remote API sync note: {e}")


if __name__ == "__main__":
    main()
