@echo off
setlocal
cd /d "%~dp0"
echo ==============================================================================
echo Fire-Minimus: Amazon Fire Tablet Restoration Suite (Windows Launcher)
echo ==============================================================================

where adb >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 'adb' was not found in your PATH.
    echo Please download Android Platform-Tools and ensure adb.exe is in your PATH.
    echo https://developer.android.com/tools/releases/platform-tools
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore.ps1" %*
set SCRIPT_EXIT=%ERRORLEVEL%

if %SCRIPT_EXIT% neq 0 (
    echo.
    echo [ERROR] Script finished with exit code %SCRIPT_EXIT%.
)

pause
exit /b %SCRIPT_EXIT%
