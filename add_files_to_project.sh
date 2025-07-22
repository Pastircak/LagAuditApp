#!/bin/bash

# Script to add missing files to Xcode project
# This script will help identify what needs to be done

echo "=== LagAuditApp - Adding Missing Files to Xcode Project ==="
echo ""

echo "The following files need to be added to the Xcode project:"
echo ""

echo "1. AppRouter.swift"
echo "   Location: Utilities/AppRouter.swift"
echo "   Target: LagAuditApp"
echo "   Group: Utilities"
echo ""

echo "2. AuditViewModel.swift"
echo "   Location: ViewModels/AuditViewModel.swift"
echo "   Target: LagAuditApp"
echo "   Group: ViewModels"
echo ""

echo "=== How to Add Files in Xcode ==="
echo ""

echo "Method 1: Add Files Menu"
echo "1. Open Xcode project"
echo "2. Right-click on the appropriate group (Utilities or ViewModels)"
echo "3. Select 'Add Files to LagAuditApp'"
echo "4. Navigate to the file location"
echo "5. Select the file"
echo "6. Make sure 'Add to target: LagAuditApp' is checked"
echo "7. Click 'Add'"
echo ""

echo "Method 2: Drag and Drop"
echo "1. Open Finder and navigate to the project folder"
echo "2. Drag the file from Finder to the appropriate group in Xcode"
echo "3. Make sure 'Copy items if needed' is checked"
echo "4. Make sure 'Add to target: LagAuditApp' is checked"
echo "5. Click 'Finish'"
echo ""

echo "=== Verification ==="
echo "After adding the files, run:"
echo "xcodebuild -project LagAuditApp.xcodeproj -scheme LagAuditApp -destination 'platform=iOS Simulator,name=iPhone 16' build"
echo ""

echo "The project should compile successfully after adding these files."
echo ""

# Check if files exist
echo "=== File Status ==="
if [ -f "Utilities/AppRouter.swift" ]; then
    echo "✅ AppRouter.swift exists"
else
    echo "❌ AppRouter.swift missing"
fi

if [ -f "ViewModels/AuditViewModel.swift" ]; then
    echo "✅ AuditViewModel.swift exists"
else
    echo "❌ AuditViewModel.swift missing"
fi

echo ""
echo "=== Summary ==="
echo "The new architecture is ready! Just add the two missing files to Xcode."
echo "See ADD_MISSING_FILES.md for detailed instructions." 