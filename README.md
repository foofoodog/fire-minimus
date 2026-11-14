# Amazon Fire 7 (9th Gen, 2019) Configuration & Restoration Suite

- **Device Model:** Amazon Fire 7 (9th Generation, 2019)
- **Codename / Hardware:** `mustang` / MediaTek MT8163
- **Base OS:** Fire OS 7.3.3.1 (Android 9 Pie / API 28)
- **Serial Number:** `G8J0X801123601DE`
- **Backup Date:** 2026-11-13

---

## Overview

This repository contains a complete declarative blueprint and one-click restoration suite for the Amazon Fire 7 (2019) tablet. It transforms the stock, ad-heavy, slow Fire OS into a sleek, private, dark-mode tablet with zero bloat and no Google or Amazon tracking.

### Key Enhancements Included:
- **Zero Bloat / Telemetry:** 34 Amazon background telemetry, ads, and bloatware packages disabled.
- **Google Framework Removed:** Full removal of Google Play Services, Play Store, and Google Service Framework.
- **Privacy Stores & Browser:**
  - **Aurora Store:** Anonymous, no-login Google Play Store client.
  - **F-Droid:** Free and open-source software repository.
  - **Via Browser:** Ultra-lightweight (~2.4 MB, ~30 MB RAM) fast web browser with native ad-blocking.
- **Ad Blocking:** System-wide DNS-over-TLS ad and tracker blocking via AdGuard Private DNS (`dns.adguard-dns.com`).
- **Snappy Performance:** 0.5x window, transition, and animator scales.
- **Dark Mode & Minimalist UI:** System-wide dark theme active (`uimode night yes`), solid black wallpaper applied, and native English QWERTY keyboard (`com.amazon.redstone`) configured.
- **OTA Lock:** Automatic Amazon system updates disabled.

---

## Repository Contents

- `restore.sh`: The master bash script that configures the device, fetches official APKs on the fly, and applies all settings.
- `packages_disabled.txt`: Full record of all 34 disabled system packages.
- `packages_thirdparty.txt`: Record of installed third-party user applications.
- `wallpaper/black.png`: Pure black background asset for home and lock screens.
- `settings_global.txt`, `settings_secure.txt`, `settings_system.txt`: Dumps of Android OS settings tables.

---

## How to Restore

1. Enable **Developer Options** and **USB Debugging** on the tablet (*Settings > Device Options > About Fire Tablet > Tap Serial Number 7 times*).
2. Connect the tablet to this machine via USB and approve the ADB authorization prompt.
3. Run:

```bash
./restore.sh
```

*(If multiple devices are plugged in, provide the target serial: `./restore.sh <serial_number>`)*

