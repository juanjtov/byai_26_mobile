# Xcode Project Setup Guide

This guide walks you through creating the Xcode project for Remodly Mobile.

## Prerequisites

- Xcode 15.0 or later installed
- Apple Developer account (free or paid)
- Mac with macOS Sonoma or later (recommended)

## Step 1: Create New Xcode Project

1. Open **Xcode**
2. Select **File → New → Project** (or press `Cmd + Shift + N`)
3. Choose **iOS** tab at the top
4. Select **App** and click **Next**

## Step 2: Configure Project Settings

Fill in the following:

| Field | Value |
|-------|-------|
| Product Name | `Remodly` |
| Team | Select your Apple Developer team |
| Organization Identifier | `com.remodly` |
| Bundle Identifier | Will auto-fill as `com.remodly.Remodly` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **None** (we'll add SwiftData later if needed) |
| Include Tests | ✅ Check both Unit Tests and UI Tests |

Click **Next**.

## Step 3: Save Location

1. Navigate to: `/Users/jujot/developer/byai_26_mobile`
2. **Important**: Uncheck "Create Git repository" (we already have one)
3. Click **Create**

## Step 4: Move Files Into Project

After Xcode creates the project, you need to add the existing Swift files:

### Option A: Using Xcode (Recommended for beginners)

1. In Xcode's Project Navigator (left sidebar), right-click on the **Remodly** folder
2. Select **Add Files to "Remodly"...**
3. Navigate to `/Users/jujot/developer/byai_26_mobile/Remodly`
4. Select all folders (App, Core, Models, Services, Features, Resources)
5. Check ✅ "Copy items if needed" is **UNCHECKED**
6. Check ✅ "Create groups" is selected
7. Click **Add**

### Option B: Manual Reorganization

1. Delete the auto-generated `ContentView.swift` and `RemodlyApp.swift` that Xcode created
2. Drag our existing folders into the Xcode project navigator
3. When prompted, choose "Create groups"

## Step 5: Configure Project Capabilities

1. Click on the **Remodly** project in the navigator (blue icon at top)
2. Select the **Remodly** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** and add:
   - **Camera** (required for RoomPlan)

## Step 6: Configure Info.plist

Add these privacy descriptions (Xcode may create Info.plist automatically):

1. Go to **Info** tab in target settings
2. Add these keys under "Custom iOS Target Properties":

| Key | Value |
|-----|-------|
| Privacy - Camera Usage Description | Remodly needs camera access to scan rooms using LiDAR |
| Privacy - Photo Library Usage Description | Save design snapshots to your photo library |

Or add directly to Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>Remodly needs camera access to scan rooms using LiDAR</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Save design snapshots to your photo library</string>
```

## Step 7: Set Deployment Target

1. In project settings, go to **General** tab
2. Set **Minimum Deployments** → iOS to **16.0**

## Step 8: Build and Run

1. Select a simulator or connected device from the dropdown
   - **Important**: For LiDAR features, you need a physical device (iPhone 12 Pro or later)
   - Simulator works for UI development but not RoomPlan scanning
2. Press `Cmd + R` to build and run

## Common Issues

### "No such module 'RoomPlan'"
RoomPlan is only available on devices with LiDAR. The code will compile but scanning won't work on simulator.

### Build errors about missing files
Make sure all Swift files are added to the target:
1. Select a file in Project Navigator
2. In the File Inspector (right panel), check that "Target Membership" includes "Remodly"

### Signing errors
1. Go to Signing & Capabilities
2. Make sure a Team is selected
3. Enable "Automatically manage signing"

## Project Structure After Setup

Your Xcode project should look like this:

```
Remodly/
├── Remodly.xcodeproj
├── Remodly/
│   ├── App/
│   │   ├── RemodlyApp.swift
│   │   ├── ContentView.swift
│   │   ├── MainTabView.swift
│   │   └── Configuration/
│   ├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Features/
│   └── Resources/
├── RemodlyTests/
└── RemodlyUITests/
```

## Next Steps

After completing this setup:

1. Build the project (`Cmd + B`) to verify everything compiles
2. Run on simulator to see the basic UI
3. Connect an iPhone 12 Pro or later to test RoomPlan scanning

See the main README.md for the development phases and next features to implement.
