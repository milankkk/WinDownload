# WinDownload

### The native Windows ISO downloader for Mac & multi-platform

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Universal-black) ![Architecture](https://img.shields.io/badge/Architecture-Apple_Silicon%20%2F%20Intel-black) ![License](https://img.shields.io/badge/License-MIT-blue) ![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)

**WinDownload** is a native, guided application designed to discover, resolve, and download official Windows ISO files directly from Microsoft's CDN — without a Windows machine, the Media Creation Tool, or browser lockouts.

Built to mirror the elegance, design system, and workflow ergonomics of **macUSB**, WinDownload brings a seamless native experience to macOS first, with a modular core designed for multi-platform deployment.

---

## ✨ Features

- **Direct Microsoft CDN Downloads:** Fetch official, untouched Windows ISOs directly from Microsoft's servers (`software.download.prss.microsoft.com`).
- **Complete Windows Catalog:**
  - **Windows 11:** 25H2 (Build 26200 refresh), 24H2 (Build 26100), Home China, Pro China
  - **Windows 10:** 22H2 (Build 19045), Home China
  - **Windows Server:** Server 2025, Server 2022, Server 2019, Server 2016
  - **Enterprise & Legacy:** Windows 11 Enterprise (Evaluation), Windows 8.1
- **All 38 Languages Supported:** Full localized release discovery matching Microsoft's SKU catalog.
- **ARM64 + x64 + x86 Support:** Native Apple Silicon / Qualcomm Snapdragon ARM64 builds and 64-bit/32-bit Intel/AMD ISOs.
- **Resilient Resolution Pipeline:**
  - Direct Microsoft Software Download API with session negotiation
  - Fallback to distributed MSDL link cache for speed and rate-limit mitigation
  - Automated Evaluation Center fwlink redirection for Server and Enterprise builds
- **Production Download Engine:**
  - Non-blocking `URLSession` streaming with pause, resume, and cancellation
  - Real-time rolling speed calculation (MB/s) and estimated time remaining (ETA)
  - Pre-flight disk space verification
  - Post-download SHA-256 cryptographic checksum calculation
- **macUSB Integration:** One-click handoff to `macUSB` to immediately write the downloaded ISO into a bootable UEFI/BIOS USB installer.
- **Liquid Glass Design Language:** Follows the Apple Human Interface Guidelines and `macUSB` design tokens, with native translucent panel surfaces, status cards, and docked action bars.

---

## 🧭 Application Workflow

1. **Selection Screen:**
   - Filter by category (*Windows 11*, *Windows 10*, *Windows Server*, *Legacy*).
   - Select your target language and processor architecture.
   - Choose destination folder (shows live available disk space).
2. **Download Process Screen:**
   - Real-time stage tracking (*Resolving Link* → *Downloading ISO* → *Verifying SHA-256* → *Ready*).
   - Live download speed, progress percentage, and time remaining.
   - Pause, resume, or cancel at any moment.
3. **Summary Screen:**
   - Confirms completion with verified file size and SHA-256 checksum.
   - Click **Reveal in Finder** to locate the `.iso` file.
   - Click **Open in macUSB** to immediately create bootable USB media.

---

## 🏗️ Architecture & Multi-Platform Strategy

The codebase is organized into clean, decoupled layers:

```
WinDownload/
├── Package.swift                             # Swift Package Manager manifest
├── WinDownload.xcodeproj/                    # Standard Xcode project
├── WinDownload/
│   ├── App/
│   │   ├── WinDownloadApp.swift              # App entry point & lifecycle
│   │   ├── ContentView.swift                 # Root view & screen coordinator
│   │   ├── Info.plist                        # macOS app configuration
│   │   └── WinDownload.entitlements          # Security entitlements
│   ├── Core/
│   │   ├── Models/                           # WindowsProduct, Language, Architecture, Metrics
│   │   ├── Network/                          # MicrosoftSessionClient, MSDLAPIClient, EvaluationScraper, Resolver
│   │   ├── Download/                         # WindowsDownloadEngine, FileDownloadDelegate, ChecksumCalculator
│   │   └── Utils/                            # DiskSpaceUtility, NotificationsManager, MacUSBHandoff
│   ├── Shared/UI/                            # DesignTokens, LiquidGlassCompatibility, StatusCard, BottomActionBar
│   └── Features/Downloader/
│       ├── Coordinator/                      # WindowsDownloaderCoordinator
│       └── UI/                               # SelectionView, ProcessView, SummaryView, OptionsSheet
└── Tests/                                    # Unit & integration test suite
```

### Multi-Platform Roadmap:
- **macOS (Current):** 100% native Swift & SwiftUI leveraging AppKit and URLSession.
- **Windows (Planned):** Native WinUI 3 frontend consuming the shared Core API contracts.
- **Linux (Planned):** Native GTK 4 / Libadwaita frontend.

---

## 🛠️ Building and Running

### Requirements
- macOS 14.0 (Sonoma) or newer
- Xcode 15.0+ or Swift 5.9+

### Open in Xcode
Double-click `WinDownload.xcodeproj` or open the directory in Xcode:
```bash
open WinDownload.xcodeproj
```
Select the **WinDownload** scheme and press **Cmd + R** to build and run.

### Build with Swift Package Manager
```bash
swift build -c release
```

---

## 📄 License

Distributed under the MIT License.
