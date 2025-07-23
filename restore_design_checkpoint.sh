#!/bin/bash

# LagAuditApp Design Checkpoint Restore Script
# This script helps you return to the design checkpoint state

echo "🔄 LagAuditApp Design Checkpoint Restore"
echo "========================================"
echo ""
echo "This will restore your app to the design checkpoint state."
echo "Current changes will be lost unless committed."
echo ""

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes!"
    echo "Current changes:"
    git status --porcelain
    echo ""
    read -p "Do you want to commit these changes first? (y/n): " commit_changes
    
    if [[ $commit_changes == "y" || $commit_changes == "Y" ]]; then
        echo "Committing current changes..."
        git add .
        read -p "Enter commit message: " commit_message
        git commit -m "$commit_message"
    fi
fi

echo ""
echo "Choose restore method:"
echo "1) Restore to design checkpoint tag (recommended)"
echo "2) Restore to design checkpoint backup branch"
echo "3) Hard reset to checkpoint commit"
echo "4) Just show differences (no restore)"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "🔄 Restoring to design checkpoint tag..."
        git checkout design-checkpoint-v1.0
        echo "✅ Restored to design checkpoint tag"
        ;;
    2)
        echo "🔄 Restoring to design checkpoint backup branch..."
        git checkout design-checkpoint-backup
        echo "✅ Restored to design checkpoint backup branch"
        ;;
    3)
        echo "🔄 Hard resetting to checkpoint commit..."
        git reset --hard ed4280f
        echo "✅ Hard reset to checkpoint commit"
        ;;
    4)
        echo "📊 Showing differences with checkpoint..."
        git diff design-checkpoint-v1.0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Done! Your app is now at the design checkpoint state."
echo "To return to your latest work: git checkout main" 