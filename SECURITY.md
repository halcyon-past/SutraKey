# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

---

## Defense-in-Depth Architecture

SutraKey runs natively on macOS with access to system input events via `CGEventTap` and local command-line subprocesses (`yt-dlp`, `ffmpeg`, `wkhtmltopdf`/WebKit). We adhere to rigorous security guarantees:

1. **Local Confinement:** SutraKey **never** transmits clipboard data, URLs, browser cookies, or downloaded files to any external remote server.
2. **Subprocess Isolation:** `yt-dlp` commands are strictly invoked with `--no-exec` and `--restrict-filenames` to prevent command injection and malicious arbitrary binary execution from playlist metadata.
3. **Strict Destination Sandboxing:** File destinations are restricted to the user's `~/Downloads` directory (or user-chosen directory) with strict canonical path normalization to block directory traversal attacks (`..`).
4. **Keychain Security:** Browser cookie decryption keys accessed via macOS Keychain Services are held in volatile memory only for the lifetime of the download subprocess and are never persisted to disk or plain text files.
5. **Bitwise Event Guard:** Event taps validate modifier exclusivity bitwise (`Shift` only) and immediately reject input upon detecting extraneous modifier combinations.

---

## Reporting a Vulnerability

If you discover a security vulnerability within SutraKey:

1. **Email Us Privately:** Please email **[security@sutrakey.aritro.cloud](mailto:security@sutrakey.aritro.cloud)** with a CC to **[aritrosaha2025@gmail.com](mailto:aritrosaha2025@gmail.com)**.
2. **Include Reproduction Details:** Provide step-by-step instructions, a proof-of-concept, and expected impact.
3. **Coordinated Disclosure:** Please allow up to 48 hours for an initial response and acknowledgment before disclosing any details publicly. We will collaborate with you to release a patched build promptly.
