# Fire-Minimus: Amazon Fire Tablet Configuration & Restoration Suite
### Universal Debloat, Privacy, and Performance Suite (7", 8", and 10" Form Factors)

- **Supported OS:** Fire OS 7 (Android 9 Pie / API 28) & Fire OS 6 (Android 7.1 Nougat)
- **Repository:** Private Backup & Restoration Engine
- **Last Updated:** 2026-11-13

---

## Mission

The goal of this project is simple: **keep capable hardware in use and out of landfills**.

Many of these tablets end up forgotten in drawers or discarded as e-waste simply because heavy background services and ads slow them down over time. By stripping away unnecessary background overhead, **Fire-Minimus** repurposes inexpensive, existing Fire tablets into clean, battery-efficient, and responsive devices for reading, media consumption, web browsing, and lightweight communication.

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
- **Zero Bloat / Telemetry:** 46 Amazon background telemetry, ads, and bloatware packages disabled (including Wi-Fi Locker, shopping trailers, and Alexa daemons).
- **Protected Service Restrictions:** AppOps enforcement on system-protected Amazon services (`kso` lockscreen ads, `metrics`, `whisperlink`, and `crashmanager`/`logmanager`) stripping background execution and wakelocks.
- **Deep Sleep & Battery Optimization:** Native Wi-Fi sleep policy (`wifi_sleep_policy=0`) disconnects radios on lock; telemetry services stripped from Android Doze whitelist exemptions; background BLE and Wi-Fi hotspot scanning disabled.
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

- `restore.sh`: The master bash script for Linux / macOS.
- `restore.ps1`: Native Windows PowerShell restoration script.
- `restore.bat`: One-click Windows batch launcher (bypasses execution policy and runs `restore.ps1`).
- `packages_disabled.txt`: Full record of all 46 disabled system packages.
- `wallpaper/black.png`: Pure black background asset for home and lock screens.

---

## Preparation Steps (Before Running Restore)

> [!TIP]
> **Preferred Starting Point: Factory Reset**
> Performing a **Factory Reset** (**Settings > Device Options > Reset to Factory Defaults**) is strongly preferred before beginning. A factory reset guarantees a completely clean slate—wiping lingering caches, secondary profiles, and leftover junk. After resetting, connect to Wi-Fi, proceed through initial setup without registering an account (or skip account setup), and jump straight to **Step 1 (Enable Developer Mode)**.
>
> If you are **not** factory resetting the tablet, proceed through all steps below in their exact order.

1. **Enable Developer Mode & USB Debugging:**
   - Go to **Settings > Device Options > About Fire Tablet**.
   - Tap **Serial Number** rapidly **7 times** until the message *"You are now a developer"* appears.
   - Go back one screen, tap **Developer Options**, and toggle **USB Debugging** to **ON**.

2. **Deregister Amazon Account & Household (If Not Factory Reset):**
   - Go to **Settings > My Account** and tap **Deregister**.
   - Confirm deregistration. This unlinks your Amazon account, wipes all secondary child/family profiles, and anonymizes the primary tablet identity to generic `Owner`.
   > **Important Note on Order:** You **must** deregister the account *before* trying to turn off the lock screen PIN. If secondary family or child profiles are still present on the tablet, Fire OS security locks the passcode setting and will not allow the PIN to be removed.

3. **Turn Off Lock Screen Passcode (PIN) (If Not Factory Reset):**
   - Go to **Settings > Security & Privacy > Lockscreen Passcode** (or *Screen Lock*).
   - Enter your existing PIN/password and choose **None / Turn Off**.
   *(Android prevents ADB from modifying or bypassing lock screen credentials without user input).*

---

## How to Restore

1. Connect the tablet to your computer via USB.
2. Check the tablet screen and tap **"Always allow from this computer"** on the USB Debugging authorization prompt.
3. Run the script for your operating system:

### On Linux / macOS:
```bash
cd ~/code/fire-minimus
./restore.sh
```
*(If multiple devices are plugged in: `./restore.sh <serial_number>`)*

### On Windows (Native PowerShell / CMD):
1. Ensure [Android Platform-Tools](https://developer.android.com/tools/releases/platform-tools) (`adb.exe`) is in your PATH.
2. Open PowerShell or Command Prompt in `~/code/fire-minimus` and run:
```powershell
.\restore.ps1
```
*(Or simply double-click **`restore.bat`** from Windows File Explorer).*

> [!NOTE]
> **Can this run inside WSL (Windows Subsystem for Linux)?**  
> Yes, but WSL 2 runs inside a virtual machine and cannot see physical USB devices by default. To use `restore.sh` inside WSL, you must install [usbipd-win](https://github.com/dorssel/usbipd-win) on Windows to forward the USB port into WSL (`usbipd attach --wsl --busid <id>`). Because of this extra step, using **`restore.bat`** or **`restore.ps1`** natively on Windows is much simpler and faster.

4. **Automatic Reboot:** Upon completion, the script automatically reboots the tablet to flush lingering background daemons and free up to 600 MB of inactive RAM. Once the tablet finishes booting, it will open directly to the clean, dark-mode home screen.

