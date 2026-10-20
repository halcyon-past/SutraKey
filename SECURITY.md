# Security Policy

## Supported Versions
| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## Reporting a Vulnerability
The SutraKey team takes the security of our users seriously. SutraKey runs natively with local subprocesses and accessibility hooks, which require high standards of isolation and defense-in-depth:

- SutraKey **never** sends clipboard data, URLs, or downloaded content to external servers.
- `yt-dlp` commands are always executed with `--no-exec` and `--restrict-filenames`.
- Destination paths are strictly bounded to `~/Downloads` with explicit traversal checks (`..`).

To report a vulnerability:
1. Email `security@sutrakey.aritro.cloud` with reproduction steps and potential impact.
2. Please do not open public issues for zero-day vulnerabilities.
3. We will acknowledge receipt within 48 hours and coordinate a coordinated disclosure timeline.
