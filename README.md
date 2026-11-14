# Amazon Fire Tablet Configuration & Restoration Suite
### Universal Debloat, Privacy, and Performance Suite (7", 8", and 10" Form Factors)

- **Supported OS:** Fire OS 7 (Android 9 Pie / API 28) & Fire OS 6 (Android 7.1 Nougat)
- **Repository:** Private Backup & Restoration Engine
- **Last Updated:** 2026-11-13

---

## Overview

This repository contains a declarative configuration twin and universal one-click restoration suite for Amazon Fire tablets. It transforms stock, ad-heavy, slow Fire OS tablets into sleek, private, dark-mode devices with zero bloat and no Google or Amazon tracking.

The suite features **automatic hardware and form factor detection** that queries device codenames, model strings, and physical display dimensions over ADB to dynamically tailor UI touch coordinates and wallpaper scaling to the specific tablet screen.

---

## Supported Form Factors & Hardware

| Form Factor | Screen Resolution | Verified Hardware Models & Codenames | Status |
| :--- | :--- | :--- | :--- |
| **7-inch Tablets** | `600x1024` | Fire 7 9th Gen (`KFMUWI` / `mustang`), Fire 7 7th Gen (`KFKAWI` / `austin`) | **Verified & Supported** |
| **8-inch Tablets** | `800x1280` | Fire HD 8 10th Gen (`KFONWI` / `onyx`), Fire HD 8 8th Gen (`KFKAWI` / `karnak`) | **Verified & Supported** |
| **10-inch Tablets** | `1200x1920` | Fire HD 10 9th Gen (`KFTRWI` / `maverick`), Fire HD 10 11th Gen (`tethys`) | **Supported** |

When `restore.sh` executes, it automatically detects the connected device and outputs:
```text
==> Target Device: <device-serial>
==> Detected Hardware: Amazon Fire HD 8 (8-inch display) [Model: KFONWI | Codename: onyx | Resolution: 800x1280]
```

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

## Preparation Steps (Before Running Restore)

Before running the restoration script on a new or factory-reset tablet, perform these three quick steps on the tablet screen:

1. **Enable Developer Mode & USB Debugging:**
   - Go to **Settings > Device Options > About Fire Tablet**.
   - Tap **Serial Number** rapidly **7 times** until the message *"You are now a developer"* appears.
   - Go back one screen, tap **Developer Options**, and toggle **USB Debugging** to **ON**.
2. **Turn Off Lock Screen Passcode (PIN):**
   - Go to **Settings > Security & Privacy > Lockscreen Passcode** (or *Screen Lock*).
   - Enter your existing PIN/password and choose **None / Turn Off**.
   *(Android prevents ADB from modifying or bypassing lock screen credentials without user input).*
3. **Deregister Amazon Account & Household:**
   - Go to **Settings > My Account** and tap **Deregister**.
   - Confirm deregistration. This unlinks your Amazon account, removes secondary family profiles, and anonymizes the tablet identity to generic `Owner`.

---

## How to Restore

1. Connect the tablet to this machine via USB.
2. Check the tablet screen and tap **"Always allow from this computer"** on the USB Debugging authorization prompt.
3. Run the script:

```bash
cd /home/mike/fire7_backup
./restore.sh
```

*(If multiple devices are plugged in, pass the target serial number: `./restore.sh <serial_number>`)*

