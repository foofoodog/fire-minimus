<#
.SYNOPSIS
    Amazon Fire Tablet Universal Custom Setup & Restoration Script (Windows PowerShell)
    Compatible with Windows 10/11 native PowerShell.
.DESCRIPTION
    Restores a clean, debloated, privacy-first, dark-mode state across Fire 7, HD 8, and HD 10 tablets.
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Device
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

# Ensure ADB is in PATH or present
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error "Error: 'adb' command not found in PATH. Please install Android Platform Tools or add adb.exe to your PATH."
    exit 1
}

# Auto-detect ADB device if not specified
if (-not $Device) {
    $connected = @(adb devices | Where-Object { $_ -match "\tdevice$" } | ForEach-Object { ($_ -split "\t")[0].Trim() })
    if ($connected.Count -eq 0) {
        Write-Error "Error: No ADB device connected and authorized. Enable USB Debugging on the tablet."
        exit 1
    }
    elseif ($connected.Count -gt 1) {
        Write-Host "Multiple devices detected. Please pass serial as argument:" -ForegroundColor Yellow
        Write-Host "  .\restore.ps1 <device-serial>"
        exit 1
    }
    else {
        $Device = $connected[0]
    }
}

Write-Host "==> Target Device: $Device" -ForegroundColor Cyan
adb -s $Device wait-for-device

# Hardware & Display Detection
$Model = (adb -s $Device shell getprop ro.product.model 2>$null).Trim()
$Codename = (adb -s $Device shell getprop ro.product.device 2>$null).Trim()
$WmSizeRaw = (adb -s $Device shell wm size 2>$null).Trim()

$Width = 0
$Height = 0
$ResStr = "Unknown"
if ($WmSizeRaw -match '(\d+)x(\d+)') {
    $Width = [int]$Matches[1]
    $Height = [int]$Matches[2]
    $ResStr = "${Width}x${Height}"
}

$DeviceType = switch -Wildcard ($ResStr) {
    "*600x1024*" { "Amazon Fire 7 (7-inch display)" }
    "*1024x600*" { "Amazon Fire 7 (7-inch display)" }
    "*800x1280*" { "Amazon Fire HD 8 (8-inch display)" }
    "*1280x800*" { "Amazon Fire HD 8 (8-inch display)" }
    "*1200x1920*" { "Amazon Fire HD 10 (10-inch display)" }
    "*1920x1200*" { "Amazon Fire HD 10 (10-inch display)" }
    Default {
        switch ($Model) {
            { $_ -in "KFMUWI","KFKAWI","KFAUWI" } { "Amazon Fire 7 (7-inch display)" }
            { $_ -in "KFONWI","KFMAWI","KFDOWI" } { "Amazon Fire HD 8 (8-inch display)" }
            { $_ -in "KFTRWI" }                   { "Amazon Fire HD 10 (10-inch display)" }
            Default                               { "Amazon Fire Tablet ($Model)" }
        }
    }
}

Write-Host "==> Detected Hardware: $DeviceType [Model: $Model | Codename: $Codename | Resolution: $ResStr]" -ForegroundColor Green

# 1. Debloat Amazon Bloatware
Write-Host "==> Disabling Amazon bloatware packages..." -ForegroundColor Cyan
$DisabledListPath = Join-Path $ScriptDir "packages_disabled.txt"
if (Test-Path $DisabledListPath) {
    Get-Content $DisabledListPath | ForEach-Object {
        $pkg = $_.Trim()
        if ($pkg.StartsWith("package:")) {
            $pkg = $pkg.Substring(8)
        }
        if (-not [string]::IsNullOrWhiteSpace($pkg)) {
            Write-Host "    - Disabling $pkg"
            adb -s $Device shell "pm disable-user --user 0 $pkg" 2>$null | Out-Null
        }
    }
}

# 2. Block Lockscreen Ads, Telemetry & Background Daemons
Write-Host "==> Configuring ad blocking, telemetry restrictions, and background limits..." -ForegroundColor Cyan
adb -s $Device shell "settings put global LOCKSCREEN_AD_ENABLED 0"
adb -s $Device shell "settings put secure com.amazon.systemui.kso.mode 1"
adb -s $Device shell "settings put global ota_disable_automatic_update 1"

$RestrictPkgs = @(
    "com.amazon.device.software.ota",
    "com.amazon.kindle.kso",
    "com.amazon.client.metrics",
    "com.amazon.whisperlink.core.android",
    "com.amazon.device.logmanager",
    "com.amazon.device.crashmanager"
)

foreach ($rPkg in $RestrictPkgs) {
    adb -s $Device shell "cmd appops set $rPkg RUN_IN_BACKGROUND ignore" 2>$null | Out-Null
    adb -s $Device shell "cmd appops set $rPkg RUN_ANY_IN_BACKGROUND ignore" 2>$null | Out-Null
    adb -s $Device shell "cmd appops set $rPkg WAKE_LOCK ignore" 2>$null | Out-Null
}

# Strip telemetry from Doze whitelist
adb -s $Device shell "dumpsys deviceidle whitelist -com.amazon.device.logmanager" 2>$null | Out-Null
adb -s $Device shell "dumpsys deviceidle whitelist -com.amazon.device.crashmanager" 2>$null | Out-Null
adb -s $Device shell "dumpsys deviceidle whitelist -com.amazon.client.metrics" 2>$null | Out-Null

# 3. Apply Performance, Battery & System UI Tweaks
Write-Host "==> Applying UI performance tweaks, deep sleep settings & private DoT DNS..." -ForegroundColor Cyan
adb -s $Device shell "settings put global window_animation_scale 0.5"
adb -s $Device shell "settings put global transition_animation_scale 0.5"
adb -s $Device shell "settings put global animator_duration_scale 0.5"
adb -s $Device shell "settings put global private_dns_mode hostname"
adb -s $Device shell "settings put global private_dns_specifier dns.adguard-dns.com"
adb -s $Device shell "settings put global wifi_sleep_policy 0"
adb -s $Device shell "settings put global wifi_networks_available_notification_on 0"
adb -s $Device shell "settings put global ble_scan_always_enabled 0"
adb -s $Device shell "settings put system sound_effects_enabled 0"
adb -s $Device shell "settings put system lockscreen_sounds_enabled 0"
adb -s $Device shell "settings put system dtmf_tone 0"
adb -s $Device shell "settings put system alexa_enabled 0"

# 4. System-wide Dark Mode
Write-Host "==> Enabling system-wide Dark Theme..." -ForegroundColor Cyan
adb -s $Device shell "cmd uimode night yes"
adb -s $Device shell "settings put secure ui_night_mode 2"

# 5. Native English Fire Keyboard Setup
Write-Host "==> Ensuring Fire Keyboard (English QWERTY) is default..." -ForegroundColor Cyan
adb -s $Device shell "pm enable com.amazon.redstone" 2>$null | Out-Null
adb -s $Device shell "ime enable com.amazon.redstone/.FireKeyboardService" 2>$null | Out-Null
adb -s $Device shell "ime set com.amazon.redstone/.FireKeyboardService" 2>$null | Out-Null
adb -s $Device shell "settings put secure default_input_method com.amazon.redstone/.FireKeyboardService"
adb -s $Device shell "settings put secure enabled_input_methods com.amazon.redstone/.FireKeyboardService"
adb -s $Device shell "pm disable-user --user 0 jp.co.omronsoft.iwnnime.mlaz" 2>$null | Out-Null

# 6. Sideload Stores & Apps (Aurora Store, F-Droid, Via Browser)
Write-Host "==> Installing Aurora Store, F-Droid & Via Browser..." -ForegroundColor Cyan
$ApkDir = Join-Path $ScriptDir "apks"
if (-not (Test-Path $ApkDir)) {
    New-Item -ItemType Directory -Path $ApkDir | Out-Null
}

$Apks = @(
    @{
        Name = "Aurora Store"
        File = "AuroraStore.apk"
        Url  = "https://auroraoss.com/downloads/AuroraStore/Release/AuroraStore-4.7.5.apk"
    },
    @{
        Name = "F-Droid"
        File = "FDroid.apk"
        Url  = "https://f-droid.org/F-Droid.apk"
    },
    @{
        Name = "Via Browser"
        File = "ViaBrowser.apk"
        Url  = "https://res.viayoo.com/v1/via-release.apk"
    }
)

# Use TLS 1.2 for web downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

foreach ($item in $Apks) {
    $targetPath = Join-Path $ApkDir $item.File
    if (-not (Test-Path $targetPath)) {
        Write-Host "    - Downloading $($item.Name)..."
        try {
            Invoke-WebRequest -Uri $item.Url -OutFile $targetPath -UserAgent "Mozilla/5.0" -UseBasicParsing
        } catch {
            Write-Warning "Failed downloading $($item.Name): $_"
        }
    }
    if (Test-Path $targetPath) {
        Write-Host "    - Installing $($item.Name)..."
        adb -s $Device install -r -g $targetPath
    }
}

# 7. Restore Solid Black Wallpaper
Write-Host "==> Restoring solid black wallpaper..." -ForegroundColor Cyan
adb -s $Device shell input keyevent 224 2>$null | Out-Null
adb -s $Device shell input keyevent 82 2>$null | Out-Null

$WallpaperPath = Join-Path $ScriptDir "wallpaper\black.png"
if (Test-Path $WallpaperPath) {
    adb -s $Device push $WallpaperPath /storage/emulated/0/Pictures/black.png 2>$null | Out-Null
    adb -s $Device shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Pictures/black.png" 2>$null | Out-Null
    Start-Sleep -Seconds 2

    $QueryOut = (adb -s $Device shell "content query --uri content://media/external/images/media --projection _id:_data" 2>$null)
    $MediaId = ""
    foreach ($line in ($QueryOut -split "\r?\n")) {
        if ($line -match 'black\.png') {
            if ($line -match '_id=(\d+)') {
                $MediaId = $Matches[1]
                break
            }
        }
    }

    if ($MediaId) {
        Write-Host "    - Applying black wallpaper (Media ID $MediaId)..."
        adb -s $Device shell am start -n com.android.wallpaper/.picker.StandalonePreviewActivity -d content://media/external/images/media/$MediaId -t image/png --grant-read-uri-permission 2>$null | Out-Null
        Start-Sleep -Seconds 2

        if ($Width -gt 0 -and $Height -gt 0) {
            $TapX = [int]($Width / 2)
            $TapY = [int]($Height * 0.92)
        } else {
            $TapX = 300
            $TapY = 940
        }
        adb -s $Device shell "input tap $TapX $TapY" 2>$null | Out-Null
        Start-Sleep -Seconds 1
    }
}

# 8. Reboot to Flush Memory & Finalize
Write-Host "==> Rebooting tablet to flush inactive memory and lock in optimizations..." -ForegroundColor Cyan
adb -s $Device reboot 2>$null | Out-Null

Write-Host "==> Restoration complete! Tablet is rebooting into a sleek, debloated, dark-mode state." -ForegroundColor Green
