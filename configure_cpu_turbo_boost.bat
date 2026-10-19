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
echo Configuring AMD Ryzen 3 3250U Turbo / Precision Boost
echo Base Clock: 2.60 GHz  ^|  Max Boost: 3.50 GHz (+35%% Speed)
echo ========================================================
echo.

:: 1. Permanently unhide Processor Performance Boost Mode in Windows Power Options GUI
echo [1/4] Unhiding Processor Performance Boost Mode in Windows Control Panel...
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 -ATTRIB_HIDE
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f >nul

:: 2. Configure Plugged In (AC) setting -> Aggressive Boost (up to 3.50 GHz for fast compiling & apps)
echo [2/4] Setting Plugged In (AC) to Aggressive Boost (3.50 GHz Max Performance)...
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 2

:: 3. Configure On Battery (DC) setting -> Disabled (locks at 2.60 GHz for long battery & cool laptop)
echo [3/4] Setting On Battery (DC) to Disabled (2.60 GHz Cool and Power-Saving)...
powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 0

:: 4. Apply changes immediately
echo [4/4] Applying new power settings to active power scheme...
powercfg /setactive SCHEME_CURRENT

echo.
echo ========================================================
echo Turbo Boost Configuration Complete!
echo.
echo When Plugged In : Turbo Boost ENABLED (up to 3.50 GHz)
echo                   Faster npm dev builds, compilation and hot reloads!
echo.
echo When On Battery : Turbo Boost DISABLED (2.60 GHz)
echo                   Laptop stays cool, quiet fan, extra battery life!
echo.
echo You can also adjust this anytime in:
echo Control Panel -^> Power Options -^> Change plan settings -^> Advanced
echo ========================================================
pause
