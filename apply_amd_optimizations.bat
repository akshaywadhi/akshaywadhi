@echo off
setlocal
echo ========================================================
echo Applying AMD & Windows Performance Tweaks (HP 15s)
echo ========================================================
echo.

:: 1. Disable AMD ULPS (Ultra Low Power State) across all GPU registry classes
echo [1/4] Disabling AMD ULPS (prevents GPU micro-sleep stutters)...
powershell -NoProfile -Command "Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}' -Recurse -ErrorAction SilentlyContinue | Where-Object { (Get-ItemProperty -Path $_.PSPath).EnableUlps -ne $null } | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name 'EnableUlps' -Value 0 -Type DWord -Force; Write-Host '  Disabled ULPS for:' $_.PSChildName }"

:: 2. Disable Windows Fast Startup (prevents driver memory leak persistence)
echo [2/4] Disabling Fast Startup (ensures clean driver state on boot)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f

:: 3. Disable AMD Crash Defender background watchdog (reduces CPU spikes)
echo [3/4] Optimizing AMD Crash Defender service...
sc config "AMD Crash Defender Service" start= demand >nul 2>&1

:: 4. Restart Desktop Window Manager (DWM)
echo [4/4] Refreshing Desktop Window Manager (DWM)...
powershell -NoProfile -Command "Stop-Process -Name dwm -Force -ErrorAction SilentlyContinue"

echo.
echo ========================================================
echo Optimizations applied successfully!
echo Reminder: In your browser, install 'enhanced-h264ify'
echo and check 'Block AV1' to avoid dual-core CPU overload.
echo ========================================================
pause
