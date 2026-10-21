#!/usr/bin/env bash
set -euo pipefail

# SutraKey Git Repository & Branch Strategy Initializer
# Enforces: main, uat, dev branches + branch-naming commit/push guards

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "🌿 Initializing SutraKey Git Governance Strategy..."

# Ensure git is initialized
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Ensure user name and email exist for local git commits
if ! git config user.name >/dev/null 2>&1; then
    git config user.name "SutraKey Bot"
fi
if ! git config user.email >/dev/null 2>&1; then
    git config user.email "bot@sutrakey.aritro.cloud"
fi

# Stage files and initial commit if no commits yet
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    git add .
    git commit -m "chore: initial scaffold for SutraKey native macOS utility"
    echo "✅ Initial commit created on 'main'."
else
    # Stage any unstaged changes
    if [ -n "$(git status --porcelain)" ]; then
        git add .
        git commit -m "chore: synchronize repository updates" || true
    fi
fi

# Create uat branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/uat; then
    git branch uat main
    echo "✅ Created branch 'uat' tracking 'main'."
else
    echo "ℹ️ Branch 'uat' already exists."
fi

# Create dev branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/dev; then
    git branch dev main
    echo "✅ Created branch 'dev' tracking 'main'."
else
    echo "ℹ️ Branch 'dev' already exists."
fi

# Install local pre-push git hook to enforce branch naming
HOOKS_DIR=".git/hooks"
mkdir -p "$HOOKS_DIR"
PRE_PUSH_HOOK="$HOOKS_DIR/pre-push"

cat << 'EOF' > "$PRE_PUSH_HOOK"
#!/usr/bin/env bash
# SutraKey Pre-Push Branch Guard
set -eu

while read local_ref local_sha remote_ref remote_sha; do
    branch_name="${local_ref#refs/heads/}"

    # Allow deleting branches
    if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
        continue
    fi

    # Allow pushing tags
    if [[ "$local_ref" =~ ^refs/tags/ ]]; then
        continue
    fi

    # Check Core branches
    if [[ "$branch_name" =~ ^(main|uat|dev)$ ]]; then
        continue
    fi

    # Check Feature / Hotfix branch patterns
    if [[ "$branch_name" =~ ^feature/(main|uat|dev)/[a-z0-9-]+$ ]] || [[ "$branch_name" =~ ^hotfix/[a-z0-9-]+$ ]]; then
        continue
    fi

    echo "❌ [SutraKey Git Hook] Push rejected for branch: '$branch_name'"
    echo "Allowed branch patterns:"
    echo "  - Core: main, uat, dev"
    echo "  - Feature: feature/(main|uat|dev)/<feature-name>"
    echo "  - Hotfix: hotfix/<feature-name>"
    exit 1
done
exit 0
EOF

chmod +x "$PRE_PUSH_HOOK"
echo "✅ Installed git pre-push hook for branch governance."
echo "🎉 SutraKey git environment initialized successfully."
