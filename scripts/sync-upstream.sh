#!/bin/bash
# Sync with upstream claude-skills while preserving custom skills
# Original repo: https://github.com/jezweb/claude-skills by Jeremy Dawes

set -e  # Exit on error

echo "🔄 Claude Skills Upstream Sync"
echo "================================"
echo ""

# Check if upstream remote exists
if ! git remote | grep -q "^upstream$"; then
    echo "⚠️  Upstream remote not found."
    echo "Add it with:"
    echo "  git remote add upstream https://github.com/jezweb/claude-skills.git"
    echo ""
    read -p "Add upstream remote now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote add upstream https://github.com/jezweb/claude-skills.git
        echo "✅ Upstream remote added"
    else
        echo "❌ Cancelled. Add upstream remote manually and try again."
        exit 1
    fi
fi

echo "📥 Fetching upstream changes..."
git fetch upstream

echo ""
echo "🌿 Creating temporary sync branch..."
git checkout -b temp-upstream-sync upstream/main

echo ""
echo "🔀 Switching to main branch..."
git checkout main

echo ""
echo "🔗 Merging upstream (no auto-commit)..."
if git merge temp-upstream-sync --no-commit --no-ff; then
    echo "✅ Merge successful (no conflicts)"
else
    echo "⚠️  Merge conflicts detected. Resolving..."
fi

echo ""
echo "🛡️  Restoring custom skills folder..."
git checkout HEAD -- skills/

echo ""
echo "📝 Restoring custom documentation..."
# Restore files with your custom info
git checkout HEAD -- README.md
git checkout HEAD -- CONTRIBUTING.md

echo ""
echo "✅ Sync preparation complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Review changes: git status"
echo "  2. Check diff: git diff --cached"
echo "  3. Commit when ready: git commit -m 'Sync with upstream - preserved custom skills'"
echo "  4. Clean up temp branch: git branch -D temp-upstream-sync"
echo ""
echo "💡 Tip: Your custom skills in /skills are preserved"
