# WinDownload Technical Architecture

This document describes the architectural specifications, subsystem contracts, and data flows of **WinDownload**.

---

## 1. System Overview

WinDownload is built as a native macOS application modeled directly on the design language, modularity, and user experience standards of **macUSB**.

Its mission is to provide an official, safe, and intuitive channel for downloading authentic Windows ISOs directly from Microsoft's Content Delivery Network (CDN) with cryptographic verification and seamless handoff to USB creation workflows.

```
┌─────────────────────────────────────────────────────────────┐
│                    WinDownload (SwiftUI)                    │
│  ┌───────────────────────┐       ┌───────────────────────┐  │
│  │     SelectionView     │  ───> │      ProcessView      │  │
│  └───────────────────────┘       └───────────────────────┘  │
│                                              │              │
│                                              ▼              │
│                                  ┌───────────────────────┐  │
│                                  │      SummaryView      │  │
│                                  └───────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                WindowsDownloaderCoordinator
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
   WindowsISOResolver                   WindowsDownloadEngine
  (Link & SKU Discovery)              (Streaming & Verification)
            │                                     │
   ┌────────┴────────┐                   ┌────────┴────────┐
   ▼                 ▼                   ▼                 ▼
Microsoft        MSDL Cache          URLSession       CryptoKit
Session Client     Fallback           Download         SHA-256
```

---

## 2. Link Resolution Pipeline

Microsoft's Software Download service enforces session tokens, TLS fingerprinting, and specific referral chains. `WindowsISOResolver` abstracts these requirements through a prioritized resolution strategy:

### A. Direct Microsoft Session Negotiation (`MicrosoftSessionClient`)
1. Generates a unique UUID session identifier.
2. Contacts Microsoft tracking endpoints (`vlscppe.microsoft.com/tags`) with session context.
3. Retrieves and parses dynamic tokens (`w` and `rticks`) from `ov-df.microsoft.com/mdt.js`.
4. Exchanges telemetry ping with `ov-df.microsoft.com`.
5. Queries `getskuinformationbyproductedition` for available languages.
6. Calls `GetProductDownloadLinksBySku` with edition ID, SKU, and appropriate `Referer` headers to retrieve signed Azure CDN links (`software.download.prss.microsoft.com`). Links have a 24-hour expiration (`se` parameter).

### B. Distributed Cache Fallback (`MSDLAPIClient`)
If Microsoft's connector triggers an IP rate-limit (e.g. error code `715-123130`) or network errors occur, the resolver transparently falls back to the MSDL cache API (`https://api.msdl.tech-latest.com/skuinfo` and `/proxy`), ensuring uninterrupted user experience.

### C. Evaluation Center Scraper (`EvaluationScraper`)
For Windows Server editions (2025, 2022, 2019, 2016) and Windows 11 Enterprise:
- Discovers official `go.microsoft.com/fwlink` references from the Evaluation Center.
- Resolves HTTP redirects to determine direct `.iso` download URLs.
- Matches processor architecture (ARM64 vs x64).

---

## 3. Download & Verification Engine

The streaming engine (`WindowsDownloadEngine`) is built on asynchronous Apple networking:
- **Streaming Transfer:** Uses `URLSessionDownloadTask` with delegate callbacks (`FileDownloadDelegate`) to minimize memory usage even when downloading 6+ GB disk images.
- **Speed & ETA Calculation:** Samples transferred byte deltas at regular intervals to maintain a moving average speed in MB/s, mitigating momentary network spikes and providing accurate time estimates.
- **Resilience:** Implements cancellation data capture (`resumeData`), allowing paused downloads to be resumed without re-downloading existing chunks.
- **Verification:** Streams file blocks through Apple's `CryptoKit.SHA256` to produce a cryptographic digest for user verification.

---

## 4. UI Design System Contract

The UI directly incorporates the design language of `macUSB`:
- **Window Assumptions:** Fixed 560 x 760 pt canvas matching macUSB.
- **Liquid Glass Integration:** Conditional glass styling for newer macOS releases (`.glassEffect`) with high-contrast, translucent fallback surfaces on older systems.
- **Panel Surfaces & Status Cards:** Visual hierarchy driven by `WinDownloadSurfaceTone` (`.neutral`, `.subtle`, `.info`, `.success`, `.warning`, `.error`, `.active`).
- **Docked Action Bar:** Clean action button docking with safe-area support.

---

## 5. Integration with macUSB

Upon download completion:
1. `MacUSBHandoff` tests if `macUSB.app` is installed on the host Mac (via bundle identifier `com.kruszoneq.macusb` or `/Applications/macUSB.app`).
2. Provides a one-click button ("Open in macUSB") that opens `macUSB` with the downloaded `.iso` selected as source.
3. Allows the user to proceed immediately to bootable USB preparation.
