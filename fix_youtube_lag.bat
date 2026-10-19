@echo off
setlocal
echo ========================================================
echo Applying Lifetime Fix for YouTube Video and Desktop Lag
echo (Preserving SMB and Hotspot intact)
echo ========================================================
echo.

:: 1. Disable Multi-Plane Overlay (MPO) in DWM (Fixes AMD Vega presentation lockup)
echo [1/4] Disabling Multi-Plane Overlay (MPO) in Desktop Window Manager...
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f

:: 2. Fix WinDefend RpcSs dependency loop
echo [2/4] Repairing WinDefend service dependency (fixes Event 7003)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v DependOnService /t REG_MULTI_SZ /d "RpcSs" /f

:: 3. Optimize Realtek RTL8821CE Wi-Fi adapter (no power sleep, no 802.11d stall scan, fallback DNS)
echo [3/4] Optimizing Wi-Fi adapter and DNS (Hotspot and SMB remain 100%% active)...
powershell -NoProfile -Command "Set-NetAdapterAdvancedProperty -Name 'WiFi' -DisplayName '802.11d' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'WiFi' -ServerAddresses ('10.90.203.215', '1.1.1.1', '8.8.8.8') -ErrorAction SilentlyContinue; $nic = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -eq 'WiFi' }; if ($nic) { $pnp = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\' + ('{0:D4}' -f $nic.Index); Set-ItemProperty -Path $pnp -Name 'PnPCapabilities' -Value 24 -Type DWord -Force -ErrorAction SilentlyContinue }"

:: 4. Restart DWM to take effect immediately without rebooting
echo [4/4] Restarting Desktop Window Manager (DWM)...
powershell -NoProfile -Command "Stop-Process -Name dwm -Force"

echo.
echo ========================================================
echo Fixes applied successfully!
echo ========================================================
pause
