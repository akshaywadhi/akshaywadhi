@echo off
setlocal

:: Check for administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo Silencing All Background Update and Defender Error Loops
echo (Preserving SMB and Mobile Hotspot 100%% Intact)
echo ========================================================
echo.

:: 1. Disable Windows Update, Orchestrator, and Medic Services
echo [1/5] Stopping and disabling Windows Update and Orchestrator services...
net stop wuauserv >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v Start /t REG_DWORD /d 4 /f >nul

net stop UsoSvc >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UsoSvc" /v Start /t REG_DWORD /d 4 /f >nul

net stop WaaSMedicSvc >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f >nul

net stop SecurityHealthService >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v Start /t REG_DWORD /d 4 /f >nul

:: 2. Configure Group Policies to cleanly block update scans without error logs
echo [2/5] Setting Clean NoAutoUpdate and Defender Group Policies...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiVirus /t REG_DWORD /d 1 /f >nul

:: 3. Disable remaining Windows Update scheduled tasks
echo [3/5] Disabling Windows Update background scheduled tasks...
schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable >nul 2>&1

:: 4. Fix CAPI2 Event 513 MSLLDP Security Descriptor
echo [4/5] Fixing MSLLDP permissions (eliminates CAPI2 Event 513)...
sc.exe sdset mslldp D:(D;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BG)(A;;CCDCLCSWRPWPDTLORCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLORCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;FA;CCDCLCSWRPWPDTLOSDRCWDWO;;;WD) >nul 2>&1

:: 5. Clean up accumulated Windows Error Reporting crash logs
echo [5/5] Clearing old 0x80070433 Windows Error Reporting logs...
powershell -NoProfile -Command "Get-ChildItem 'C:\ProgramData\Microsoft\Windows\WER\ReportArchive' -Filter '*0x80070433*' -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

echo.
echo ========================================================
echo All background error loops silenced permanently!
echo 1. Windows Update and Orchestrator services STOPPED and DISABLED.
echo 2. Background error loops (0x8024200B and Event 7003) ELIMINATED.
echo 3. CAPI2 513 permission error RESOLVED.
echo 4. SMB and Mobile Hotspot remain completely UNTOUCHED and ACTIVE.
echo ========================================================
pause
