# WinDownload

[![Download Nightly DMG](https://img.shields.io/badge/Download-Nightly%20DMG-blue?logo=apple)](https://github.com/milankkk/WinDownload/releases/download/nightly/WinDownload.dmg)

A native macOS application to discover and download official Windows ISOs directly from Microsoft's CDN — no Windows PC, browser tricks, or Media Creation Tool required.

> **Note:** This project is vibecoded with AI pair programming and based on two open-source projects: **[macUSB](https://github.com/Kruszoneq/macUSB)** (UI design and bootable USB handoff) and **[windows-iso-downloader](https://github.com/starkSV/windows-iso-downloader)** (Microsoft CDN resolution logic).

---

## Features

- **Official Microsoft CDN Downloads:** Direct, untouched ISOs for Windows 11, Windows 10, Windows Server, and Enterprise LTSC.
- **Architecture & Languages:** Full support for x64, ARM64 (Apple Silicon), and all 38 official languages.
- **Download Engine:** High-speed streaming with pause/resume, live metrics, and SHA-256 verification.
- **macUSB Integration:** One-click handoff to create a bootable USB installer immediately after download.

---

## Building

### Requirements
- macOS 14.0+
- Xcode 15.0+ or Swift 5.9+

### Build App Bundle & DMG
```bash
./build.sh --dmg
```
The compiled `.app` bundle and distributable `.dmg` will be in `build/`.

### Open in Xcode
```bash
open WinDownload.xcodeproj
```

---

## Acknowledgements

- **[macUSB](https://github.com/Kruszoneq/macUSB)** by [@Kruszoneq](https://github.com/Kruszoneq) for UI design tokens, layout patterns, and bootable USB creation handoff.
- **[windows-iso-downloader](https://github.com/starkSV/windows-iso-downloader)** by [@starkSV](https://github.com/starkSV) for Microsoft API session negotiation and link resolution mechanics.

---

## License

This project is licensed under the [GNU General Public License v2.0](LICENSE) (GPL-2.0).
