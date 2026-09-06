# WinDownload - Project Context & Agent Handoff

> **Instructions for the AI Assistant:**  
> This file contains the complete context, architectural history, design decisions, and current repository state for **WinDownload**. Read this document to resume development seamlessly on macOS without missing any background or progress.

---

## 1. Project Background & Objective

### Origin
The workspace originally contained two repositories:
1. **`macUSB`** (`https://github.com/Kruszoneq/macUSB`): A native macOS SwiftUI app for discovering, downloading, and creating bootable macOS, Windows, and Linux USB installers on Mac. It features a polished Apple "Liquid Glass" design language, panel surfaces, status cards, and docked bottom action bars.
2. **`windows-iso-downloader`** (`https://github.com/starkSV/windows-iso-downloader`): A web frontend and Go CLI (`msdl`) that fetches official Windows ISO download links directly from Microsoft's CDN without requiring a Windows machine, browser locks, or the Media Creation Tool.

### Mission
Create **WinDownload**: a universal application, starting **native on macOS first**, modeled after `macUSB`'s design system, to discover, resolve, and download official Windows ISOs directly to the user's Mac. The priority was to establish the native UI and the download/resolution logic first.

---

## 2. GitHub Repository & Status

- **Remote URL:** `git@github.com:milankkk/WinDownload.git` (Private)
- **Web URL:** `https://github.com/milankkk/WinDownload`
- **Default Branch:** `main` (synchronized and up-to-date with `origin/main`)
- **Working Tree:** Clean.

---

## 3. Architecture & Codebase Map

The project is structured with modular separation between Core (domain & networking) and UI (SwiftUI & AppKit):

```
WinDownload/
├── Package.swift                             # Swift Package Manager definition
├── build.sh                                  # Single-command macOS build & test runner
├── WinDownload.xcodeproj/                    # Standard Xcode project
│   ├── project.pbxproj                       # Validated OpenStep PBX project
│   └── xcshareddata/xcschemes/
│       └── WinDownload.xcscheme              # Shared Xcode build/run scheme
├── WinDownload/
│   ├── App/
│   │   ├── WinDownloadApp.swift              # App entry point, single-instance enforcement
│   │   ├── ContentView.swift                 # Root view switching screens via Coordinator
│   │   ├── Info.plist                        # macOS app configuration
│   │   └── WinDownload.entitlements          # Network client & file access entitlements
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── WindowsProduct.swift          # Product, Edition, Category, Badges, DownloadOption
│   │   │   ├── WindowsLanguage.swift         # 38 languages (English, Polish, German, French, etc.)
│   │   │   ├── WindowsArchitecture.swift     # x64, ARM64, x86 with host architecture probe
│   │   │   ├── DownloadTaskState.swift       # Stages, DownloadStatus, DownloadProgressMetrics
│   │   │   └── WindowsCatalog.swift          # Catalog of consumer & evaluation releases
│   │   ├── Network/
│   │   │   ├── MicrosoftSessionClient.swift  # Direct session handshake with Microsoft's connector
│   │   │   ├── MSDLAPIClient.swift           # Fallback to distributed MSDL cache
│   │   │   ├── EvaluationScraper.swift       # Resolves Server & Enterprise fwlink redirects
│   │   │   └── WindowsISOResolver.swift      # Unified resolver combining direct + cache fallback
│   │   ├── Download/
│   │   │   ├── WindowsDownloadEngine.swift   # URLSession streaming engine with pause/resume
│   │   │   ├── FileDownloadDelegate.swift    # Rolling speed (MB/s) and ETA calculations
│   │   │   └── ChecksumCalculator.swift      # Async CryptoKit SHA-256 computation
│   │   └── Utils/
│   │       ├── DiskSpaceUtility.swift        # Volume available capacity checker
│   │       ├── NotificationsManager.swift    # UserNotifications for download completion
│   │       └── MacUSBHandoff.swift           # One-click handoff to open ISO in macUSB
│   ├── Shared/UI/
│   │   ├── DesignTokens.swift                # 560x760 pt canvas tokens, paddings, corner radii
│   │   ├── LiquidGlassCompatibility.swift    # Panel surfaces (.winDownloadPanelSurface), button styles
│   │   ├── StatusCard.swift                  # StatusCard with semantic tones (.neutral, .subtle, etc.)
│   │   └── BottomActionBar.swift             # Docked bottom action bar with safe-area support
│   └── Features/Downloader/
│       ├── Coordinator/
│       │   └── WindowsDownloaderCoordinator.swift # Central UI state machine & flow coordinator
│       └── UI/
│           ├── WindowsDownloaderSelectionView.swift # Catalog, tabs, search, lang & arch pickers
│           ├── WindowsDownloaderProcessView.swift   # Real-time progress bar, stages, pause/resume
│           ├── WindowsDownloaderSummaryView.swift   # Success view, file metadata, SHA-256, actions
│           └── WindowsDownloaderOptionsSheet.swift  # Settings for verification & notifications
├── Tests/
│   └── WinDownloadTests.swift                # Unit tests for models, formatting, and options
├── docs/
│   └── ARCHITECTURE.md                       # Deep technical architecture documentation
└── scripts/
    └── test_resolver.go                      # Standalone CLI test harness for Microsoft APIs
```

---

## 4. Key Workflows & Features

### 1. Catalog & Link Resolution
- **Consumer Releases:** Windows 11 (25H2, 24H2, China Home/Pro, ARM64), Windows 10 (22H2), Windows 8.1.
- **Evaluation Releases:** Windows Server 2025, 2022, 2019, 2016, and Windows 11 Enterprise.
- **Languages:** 38 official languages matching Microsoft's SKU catalog.
- **Resolution Strategy:**
  1. Direct Microsoft session negotiation via `MicrosoftSessionClient` (replicates browser handshake with `vlscppe` and `mdt.js` token exchange).
  2. Automatic fallback to MSDL link cache (`MSDLAPIClient`) if Microsoft rate limits the client IP.
  3. Evaluation Center scraper (`EvaluationScraper`) follows Microsoft fwlink redirects to determine direct `.iso` URLs.

### 2. Download Engine
- Streams data via `URLSessionDownloadTask` to minimize memory footprint for 5-6 GB disk images.
- Throttled sampling provides a smooth rolling speed average in `MB/s` and dynamic `ETA`.
- Supports Pause, Resume (using `resumeData`), and Cancel.
- Checks disk space before download starts (flags warning if free space < 9 GB).
- Automatically calculates cryptographic `SHA-256` checksum upon completion using Apple's `CryptoKit`.

### 3. UI Design System (macUSB Alignment)
- Fixed `560 x 760` pt window canvas.
- Translucent Liquid Glass panel surfaces with backward-compatible fallbacks.
- Semantic card tones: `.neutral`, `.subtle`, `.info`, `.success`, `.warning`, `.error`, `.active`.
- Docked bottom action bar (`BottomActionBar`) with safe-area insets.
- **macUSB Handoff:** On download completion, detects if `macUSB.app` is installed and offers an "Open in macUSB" button to immediately flash the ISO to a bootable USB drive.

---

## 5. Build, Test, and Xcode Setup

### Requirements
- macOS 14.0 (Sonoma) or newer (including macOS 15 Sequoia / 26).
- Xcode 15.0+ or Swift 5.9+ Command Line Tools.

### Commands
- **Build & Run with Single Command:**
  ```bash
  ./build.sh --run
  ```
- **Run Unit Tests:**
  ```bash
  ./build.sh --test --run
  # or
  swift test
  ```
- **Open in Xcode:**
  ```bash
  open WinDownload.xcodeproj
  ```

### Xcode Project Note
The `WinDownload.xcodeproj/project.pbxproj` was reconstructed with valid 24-character hexadecimal UUIDs and balanced configuration lists, eliminating Xcode parse errors. A shared scheme is provided under `xcshareddata/xcschemes/WinDownload.xcscheme`.

---

## 6. Planned Next Steps
- Add custom macOS AppIcon asset catalog.
- Localization strings (`Localizable.xcstrings` / `Localizable.strings`) for Polish, English, German, etc.
- Multiplatform extraction roadmap: reuse `WinDownloadCore` models for potential Windows (WinUI 3) and Linux (GTK) native frontends.
