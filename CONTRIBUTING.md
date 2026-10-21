# Contributing to SutraKey

Thank you for your interest in contributing to **SutraKey**! SutraKey is a 100% free and open-source native macOS utility engineered with Swift 6 strict concurrency and high-craft native UI.

- **Website:** [https://sutrakey.aritro.cloud](https://sutrakey.aritro.cloud)
- **License:** MIT License

---

## Branching Model & PR Rules

We maintain three core environment branches:
1. `dev` — Active feature integration and continuous testing.
2. `uat` — Release stabilization, user acceptance testing, and release candidates.
3. `main` — Production-grade releases and tagged releases (`v1.0.0`, etc.).

### Branch Naming Conventions
All branches (including branches created inside external forks) must adhere to the following rules:

1. **Core Branches:** `dev`, `uat`, `main`
2. **Feature Branches:**
   - Pattern: `feature/(dev|uat|main)/<feature-name>`
   - Example: `feature/dev/radial-haptics`, `feature/uat/ytdlp-parser`
   - Allowed characters: lowercase alphanumeric and hyphens.
3. **Hotfix Branches:**
   - Pattern: `hotfix/<feature-name>`
   - Example: `hotfix/safari-url-extraction`

PRs with branch names violating these patterns will be rejected by our automated GitHub Actions guard (`.github/workflows/branch-guard.yml`).

---

## Local Development Workflow

### Requirements
- macOS Sonoma 14.0+ (Universal Binary `arm64` & `x86_64`)
- Swift 6.0+ toolchain
- Python 3.10+ with `Pillow` and `numpy` (for the procedural icon generator)
- `yt-dlp` and `ffmpeg` (installed via Homebrew or bundled)

### Setup
```bash
# Clone the repository
git clone https://github.com/halcyon-past/SutraKey.git
cd SutraKey

# Initialize branches and git hooks
bash Scripts/setup_git_branches.sh

# Generate icons and compile AppIcon.icns
python3 Scripts/generate_icons.py
bash Scripts/build_icns.sh

# Run unit tests
swift test

# Build debug binary
swift build
```

---

## Coding Standards & Concurrency

- **Swift 6 Concurrency:** All UI operations must be `@MainActor` isolated. Background operations, task queues, and process workers must use `actor` isolation or `Sendable` types.
- **No Force Unwrapping (`!`):** Force unwraps are strictly forbidden outside test files (`Tests/`). Use `guard let`, `if let`, or explicit throwing functions.
- **Strict Sandbox & Downloads Destination:** Files must only be downloaded directly into `~/Downloads`. Any relative traversal (`../`) must be rejected.
- **Tests First:** Any new feature, parser change, or bugfix must include corresponding unit tests in `Tests/SutraKeyTests/`.
