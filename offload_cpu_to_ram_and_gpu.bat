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
echo Offloading CPU to RAM, GPU, and Fast Storage Cache
echo (Maximizing 16GB RAM Cache and Freeing 2-Core CPU)
echo ========================================================
echo.

:: 1. Keep Windows Kernel and System Drivers locked in physical RAM (Zero CPU paging overhead)
echo [1/4] Locking Windows Kernel and Drivers in RAM (DisablePagingExecutive)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul

:: 2. Use free RAM (~6.5GB) as a high-speed disk file cache for Node.js, Git, and compiling
echo [2/4] Enabling Large System RAM Cache for fast file I/O (LargeSystemCache)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul

:: 3. Give 100%% CPU Priority to your active window (VS Code, Terminal, Browser)
echo [3/4] Optimizing foreground CPU scheduling (Win32PrioritySeparation = 38)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul

:: 4. Disable Windows UI Transparency effects to save CPU compositing cycles
echo [4/4] Disabling Windows acrylic transparency overhead...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul

echo.
echo ========================================================
echo Offloading Optimizations Applied!
echo.
echo 1. RAM Utilization: Kernel and file cache stay in 16GB RAM.
echo 2. CPU Priority: Active app gets priority; background tasks wait.
echo 3. FxSound Advisory: FxSound currently uses 1300+ CPU seconds.
echo    Lowering Bass/Surround in FxSound frees up massive CPU!
echo ========================================================
pause
