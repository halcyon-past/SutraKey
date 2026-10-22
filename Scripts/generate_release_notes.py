#!/usr/bin/env python3
"""
Release notes generator for SutraKey.
Extracts release notes from CHANGELOG.md, injects optional custom announcement messages,
and appends direct DMG and Homebrew references.
"""

import argparse
import os
import re
import sys


def resolve_changelog_path(preferred_path: str = "CHANGELOG.md") -> str:
    if os.path.exists(preferred_path):
        return preferred_path
    if os.path.exists("docs/CHANGELOG.md"):
        return "docs/CHANGELOG.md"
    return preferred_path


def generate_notes(version: str, custom_message: str = "", changelog_path: str = "CHANGELOG.md", repo: str = "halcyon-past/SutraKey") -> str:
    resolved_path = resolve_changelog_path(changelog_path)
    if not os.path.exists(resolved_path):
        print(f"❌ ERROR: Changelog file '{resolved_path}' does not exist!", file=sys.stderr)
        sys.exit(1)

    with open(resolved_path, "r", encoding="utf-8") as f:
        full_changelog = f.read()

    # Match markdown section ## [version] ... up to the next ## [ or end
    pattern = rf"##\s*\[{re.escape(version)}\][^\n]*\n(.*?)(?=\n##\s*\[|\Z)"
    match = re.search(pattern, full_changelog, re.DOTALL)
    if not match or not match.group(1).strip():
        print(
            f"❌ ERROR: Release notes for version {version} not found in {resolved_path}!\n"
            f"You must add a '## [{version}]' entry with release details to {resolved_path}.",
            file=sys.stderr,
        )
        sys.exit(1)

    changelog_content = match.group(1).strip()

    lines = [f"# SutraKey v{version} (macOS)\n"]

    if custom_message and custom_message.strip():
        clean_msg = custom_message.strip()
        lines.append(f"> **Announcement:**\n> {clean_msg}\n")

    clean_changelog = re.sub(r"\n---\s*$", "", changelog_content.strip()).strip()
    lines.append(clean_changelog)
    lines.append("\n---\n")
    lines.append("### 📦 Installation Options\n")
    lines.append("#### Homebrew Cask (Recommended)\n")
    lines.append("```bash\nbrew install --cask halcyon-past/tap/sutrakey\n```\n")
    lines.append("#### Direct DMG & Auto-Update Package\n")
    lines.append(f"- 🍎 **Universal DMG:** [`SutraKey-v{version}.dmg`](https://github.com/{repo}/releases/download/v{version}/SutraKey-v{version}.dmg)")
    lines.append(f"- 📦 **ZIP Archive:** [`SutraKey-v{version}.zip`](https://github.com/{repo}/releases/download/v{version}/SutraKey-v{version}.zip)")
    lines.append("\n*Requires macOS 14.0 Sonoma or later on Apple Silicon & Intel.*")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate release notes for SutraKey")
    parser.add_argument("--version", required=True, help="Release version (e.g. 1.0.0)")
    parser.add_argument("--custom-message", default="", help="Optional announcement message")
    parser.add_argument("--changelog", default="CHANGELOG.md", help="Path to CHANGELOG.md")
    parser.add_argument("--output", default="RELEASE_NOTES.md", help="Output file path")
    parser.add_argument("--repo", default="halcyon-past/SutraKey", help="GitHub repo (owner/repo)")

    args = parser.parse_args()

    notes = generate_notes(
        version=args.version,
        custom_message=args.custom_message,
        changelog_path=args.changelog,
        repo=args.repo,
    )

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(notes)

    print(f"✅ Generated release notes in {args.output}")


if __name__ == "__main__":
    main()
