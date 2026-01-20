# Remodly Mobile

iOS mobile application for Remodly - an on-site remodeling estimation platform that enables project managers to scan rooms with LiDAR, generate instant 3D visualizations, and create professional estimates for homeowners.

## Overview

Remodly Mobile is a native iOS app built with Swift and SwiftUI that leverages Apple's RoomPlan framework to capture room geometry using LiDAR. The app enables contractors to walk into a home, scan a room, and within minutes present homeowners with style options, 3D snapshots, and rough estimates.

## Features

### Room Scanning
- LiDAR capture using Apple's RoomPlan framework
- Scan quality scoring and validation
- Guided scan checklist (perimeter, openings, fixtures, ceiling)
- Offline scan capability

### Quantity Extraction
- Automatic derivation of quantities from room model:
  - Floor area
  - Wall area
  - Perimeter length
  - Ceiling height
  - Door/window counts and sizes
  - Fixture counts
- Manual override capability
- Versioned Quantity Sheets

### Style Visualization
- Three style presets (Sophisticated, Antique, European)
- On-device scene assembly from RoomPlan output
- Instant material and lighting preset application
- 3-6 snapshot renders from fixed camera angles
- Real-time style toggling

### Estimate Generation
- Integration with backend estimating services
- Contractor-formatted estimates
- Labor and materials breakdown
- Finish allowance ranges
- PDF generation and share link creation

### Offline Support
- Scan, quantities, and instant snapshots work offline
- Upload queue when connectivity is restored
- Local rough estimate capability (optional)

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **LiDAR Capture:** RoomPlan
- **3D Rendering:** ARKit, RealityKit
- **Performance:** Metal (optional for MVP)
- **Minimum iOS:** 16.0+ (RoomPlan requirement)
- **Device Requirement:** iPhone/iPad with LiDAR sensor

## Architecture

The mobile app is part of a larger platform that includes:
- **FastAPI Backend** - Handles estimate generation, document processing, and data storage
- **Web Portal** - Contractor admin interface for pricing, templates, and company profile
- **Homeowner Share Page** - Web-based view for homeowners to review options and sign

The mobile app communicates with the backend via REST API with token-based authentication and tenant isolation.

## Project Structure

```
byai_26_mobile/
├── docs/                    # Documentation
├── Remodly/                 # Main app target
│   ├── App/                 # App entry point and configuration
│   ├── Features/            # Feature modules
│   │   ├── Auth/            # Authentication
│   │   ├── Projects/        # Project management
│   │   ├── Scanning/        # RoomPlan capture
│   │   ├── Quantities/      # Quantity sheet management
│   │   ├── Styles/          # Style presets and visualization
│   │   └── Estimates/       # Estimate display and sharing
│   ├── Core/                # Shared utilities and extensions
│   ├── Services/            # API and data services
│   ├── Models/              # Data models
│   └── Resources/           # Assets, localization
├── RemodlyTests/            # Unit tests
├── RemodlyUITests/          # UI tests
└── README.md
```

## Requirements

- Xcode 15.0+
- iOS 16.0+
- Device with LiDAR sensor (iPhone 12 Pro or later, iPad Pro 2020 or later)
- Active internet connection for estimate generation (scanning works offline)

## Getting Started

1. Clone the repository
2. Open `Remodly.xcodeproj` in Xcode
3. Configure signing and capabilities
4. Set up environment variables (see Configuration section)
5. Build and run on a LiDAR-enabled device

## Configuration

Create a `.env` file in the project root with the following variables:

```
API_BASE_URL=https://api.remodly.com
```

## Performance Targets

| Operation | Target |
|-----------|--------|
| Scan capture (bathroom) | 1-3 minutes |
| Quantity sheet ready | < 10 seconds |
| Style toggle | < 2 seconds |
| Snapshot render (4 views/style) | < 20 seconds |

## Related Repositories

- **byai_26_backend** - FastAPI backend services
- **byai_26_web** - Contractor web portal

## License

Proprietary - All rights reserved
