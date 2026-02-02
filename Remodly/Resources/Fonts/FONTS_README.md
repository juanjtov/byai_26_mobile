# Custom Fonts for Remodly

## Required Fonts

Download the following fonts from Google Fonts:

### 1. Cormorant Garamond (Display/Headings)
- **Download:** https://fonts.google.com/specimen/Cormorant+Garamond
- **Required weights:**
  - CormorantGaramond-Regular.ttf
  - CormorantGaramond-Medium.ttf
  - CormorantGaramond-SemiBold.ttf
  - CormorantGaramond-Bold.ttf

### 2. DM Sans (Body/UI)
- **Download:** https://fonts.google.com/specimen/DM+Sans
- **Required weights:**
  - DMSans-Regular.ttf
  - DMSans-Medium.ttf
  - DMSans-Bold.ttf

## Installation Steps

1. Download font files from Google Fonts (click "Download family" button)
2. Extract the ZIP files
3. Copy the required .ttf files to this directory (`Remodly/Resources/Fonts/`)
4. In Xcode:
   - Select the font files in the Project Navigator
   - In the File Inspector, check "Target Membership" for "Remodly"
5. The Info.plist already contains the `UIAppFonts` entries

## Verification

After adding fonts, run the app and check the console for:
- No "font not found" errors
- Correct font rendering in the UI

## Font Fallbacks

If fonts fail to load, the app will automatically fall back to system fonts:
- Display: Georgia → System Serif
- Body: System UI (SF Pro)
