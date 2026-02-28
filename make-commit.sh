#!/bin/bash
# Git Commit Script for Phase 5 Completion
# Run this script to commit all Phase 5 changes

cd "$(dirname "$0")"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║         Phase 5 Completion - Git Commit Script                ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

echo "📦 Staging all changes..."
git add -A

echo ""
echo "📋 Files to be committed:"
git status --short | head -20
echo ""

echo "💾 Creating commit..."
git commit -F .git-commit-message

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Commit successful!"
    echo ""
    echo "📝 Commit details:"
    git log -1 --stat
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🎉 Phase 5 Complete! Commit created successfully."
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo "  1. Review commit: git show HEAD"
    echo "  2. Push to remote: git push"
    echo "  3. Start Phase 6: Follow docs/XCODE_SETUP.md"
    echo ""
else
    echo ""
    echo "❌ Commit failed"
    echo "Please check for errors and try again"
    exit 1
fi

