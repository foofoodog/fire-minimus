#!/usr/bin/env bash
# ==============================================================================
# Amazon Fire 7 (9th Gen, 2019 - mustang) Custom Setup & Restoration Script
# Generated automatically to restore the clean, debloated, no-login state.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE="${1:-}"

if [ -z "$DEVICE" ]; then
    DEVICES=($(adb devices | grep -w "device" | awk '{print $1}'))
    if [ ${#DEVICES[@]} -eq 0 ]; then
        echo "Error: No ADB device connected and authorized."
        exit 1
    elif [ ${#DEVICES[@]} -gt 1 ]; then
        echo "Multiple devices detected. Please pass serial as argument:"
        echo "  $0 <device-serial>"
        exit 1
    else
        DEVICE="${DEVICES[0]}"
    fi
fi

echo "==> Target Device: $DEVICE"
adb -s "$DEVICE" wait-for-device

# 1. Debloat Amazon Bloatware
echo "==> Disabling Amazon bloatware packages..."
while IFS= read -r line || [ -n "$line" ]; do
    pkg="${line#package:}"
    pkg="$(echo "$pkg" | tr -d '\r\n ')"
    if [ -n "$pkg" ]; then
        echo "    - Disabling $pkg"
        adb -s "$DEVICE" shell "pm disable-user --user 0 $pkg" </dev/null >/dev/null 2>&1 || true
    fi
done < "$SCRIPT_DIR/packages_disabled.txt"

# 2. Block Lockscreen Ads & OTA Updates
echo "==> Configuring ad blocking and OTA restrictions..."
adb -s "$DEVICE" shell "settings put global LOCKSCREEN_AD_ENABLED 0"
adb -s "$DEVICE" shell "settings put secure com.amazon.systemui.kso.mode 1"
adb -s "$DEVICE" shell "settings put global ota_disable_automatic_update 1"
adb -s "$DEVICE" shell "cmd appops set com.amazon.device.software.ota RUN_IN_BACKGROUND ignore" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell "cmd appops set com.amazon.device.software.ota RUN_ANY_IN_BACKGROUND ignore" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell "cmd appops set com.amazon.device.software.ota WAKE_LOCK ignore" >/dev/null 2>&1 || true

# 3. Apply Performance & System UI Tweaks
echo "==> Applying UI performance tweaks & private ad-blocking DNS..."
adb -s "$DEVICE" shell "settings put global window_animation_scale 0.5"
adb -s "$DEVICE" shell "settings put global transition_animation_scale 0.5"
adb -s "$DEVICE" shell "settings put global animator_duration_scale 0.5"
adb -s "$DEVICE" shell "settings put global private_dns_mode hostname"
adb -s "$DEVICE" shell "settings put global private_dns_specifier dns.adguard-dns.com"
adb -s "$DEVICE" shell "settings put system sound_effects_enabled 0"
adb -s "$DEVICE" shell "settings put system dtmf_tone 0"
adb -s "$DEVICE" shell "settings put system alexa_enabled 0"

# 4. System-wide Dark Mode
echo "==> Enabling system-wide Dark Theme..."
adb -s "$DEVICE" shell "cmd uimode night yes"
adb -s "$DEVICE" shell "settings put secure ui_night_mode 2"

# 5. Native English Fire Keyboard Setup
echo "==> Ensuring Fire Keyboard (English QWERTY) is default..."
adb -s "$DEVICE" shell "pm enable com.amazon.redstone" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell "ime enable com.amazon.redstone/.FireKeyboardService" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell "ime set com.amazon.redstone/.FireKeyboardService" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell "settings put secure default_input_method com.amazon.redstone/.FireKeyboardService"
adb -s "$DEVICE" shell "settings put secure enabled_input_methods com.amazon.redstone/.FireKeyboardService"
adb -s "$DEVICE" shell "pm disable-user --user 0 jp.co.omronsoft.iwnnime.mlaz" >/dev/null 2>&1 || true

# 6. Sideload Stores & Apps (Aurora Store, F-Droid, Via Browser)
echo "==> Installing Aurora Store, F-Droid & Via Browser..."
mkdir -p "$SCRIPT_DIR/apks"

# Aurora Store
if [ ! -f "$SCRIPT_DIR/apks/AuroraStore.apk" ]; then
    echo "    - Downloading Aurora Store..."
    curl -f -sL "https://auroraoss.com/downloads/AuroraStore/Release/AuroraStore-4.7.5.apk" -o "$SCRIPT_DIR/apks/AuroraStore.apk" || true
fi
if [ -f "$SCRIPT_DIR/apks/AuroraStore.apk" ]; then
    echo "    - Installing Aurora Store..."
    adb -s "$DEVICE" install -r -g "$SCRIPT_DIR/apks/AuroraStore.apk"
fi

# F-Droid
if [ ! -f "$SCRIPT_DIR/apks/FDroid.apk" ]; then
    echo "    - Downloading F-Droid..."
    curl -f -sL "https://f-droid.org/F-Droid.apk" -o "$SCRIPT_DIR/apks/FDroid.apk" || true
fi
if [ -f "$SCRIPT_DIR/apks/FDroid.apk" ]; then
    echo "    - Installing F-Droid..."
    adb -s "$DEVICE" install -r -g "$SCRIPT_DIR/apks/FDroid.apk"
fi

# Via Browser
if [ ! -f "$SCRIPT_DIR/apks/ViaBrowser.apk" ]; then
    echo "    - Downloading Via Browser..."
    curl -f -L --retry 3 "https://res.viayoo.com/v1/via-release.apk" -o "$SCRIPT_DIR/apks/ViaBrowser.apk" || true
fi
if [ -f "$SCRIPT_DIR/apks/ViaBrowser.apk" ]; then
    echo "    - Installing Via Browser..."
    adb -s "$DEVICE" install -r -g "$SCRIPT_DIR/apks/ViaBrowser.apk"
fi

# 7. Restore Solid Black Wallpaper
echo "==> Restoring solid black wallpaper..."
adb -s "$DEVICE" shell input keyevent 224 >/dev/null 2>&1 || true
adb -s "$DEVICE" shell input keyevent 82 >/dev/null 2>&1 || true
if [ -f "$SCRIPT_DIR/wallpaper/black.png" ]; then
    adb -s "$DEVICE" push "$SCRIPT_DIR/wallpaper/black.png" /storage/emulated/0/Pictures/black.png >/dev/null 2>&1 || true
    adb -s "$DEVICE" shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Pictures/black.png" >/dev/null 2>&1 || true
    sleep 2
    # Get media ID safely without pipefail exit
    MEDIA_ID=$( (adb -s "$DEVICE" shell "content query --uri content://media/external/images/media --projection _id:_data" 2>/dev/null || true) | grep black.png | head -n 1 | sed -n 's/.*_id=\([0-9]*\).*/\1/p' | tr -d '\r\n' || true )
    if [ -n "$MEDIA_ID" ]; then
        echo "    - Applying black wallpaper (Media ID $MEDIA_ID)..."
        adb -s "$DEVICE" shell am start -n com.android.wallpaper/.picker.StandalonePreviewActivity -d content://media/external/images/media/"$MEDIA_ID" -t image/png --grant-read-uri-permission >/dev/null 2>&1 || true
        sleep 2
        adb -s "$DEVICE" shell "input tap 299 939" >/dev/null 2>&1 || true
        sleep 1
    fi
fi

adb -s "$DEVICE" shell input keyevent KEYCODE_HOME

echo "==> Restoration complete! Device is sleek, debloated, and running in dark mode."
