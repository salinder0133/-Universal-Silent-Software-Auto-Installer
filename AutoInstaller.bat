@echo off
setlocal
title Universal Software Deployment Utility

:: Enable ANSI Colors for Modern UI
for /f %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_CYAN=%ESC%[96m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_RED=%ESC%[91m"
set "C_GRAY=%ESC%[90m"
set "C_WHITE=%ESC%[97m"

:: 1. Check Administrator Privileges & Auto-Elevate
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  %C_YELLOW%[WARN]%C_RESET% Administrator privileges required. Requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 2. Set Working Directory
cd /d "%~dp0"
cls

:: 3. Pre-Scan Packages for Progress Counter
set "msi_total=0"
set "exe_total=0"
for %%F in ("%~dp0*.msi") do if exist "%%~fF" set /a msi_total+=1
for %%F in ("%~dp0*.exe") do if exist "%%~fF" set /a exe_total+=1
set /a total_pkgs=msi_total+exe_total
set "current_pkg=0"
set "success_count=0"
set "fail_count=0"

:: 4. Render Header UI
echo.
echo  %C_CYAN%+====================================================================+%C_RESET%
echo  %C_CYAN%^|%C_RESET%               %C_WHITE%UNIVERSAL SILENT SOFTWARE INSTALLER%C_RESET%                  %C_CYAN%^|%C_RESET%
echo  %C_CYAN%+====================================================================+%C_RESET%
echo  %C_GRAY%  Directory : %~dp0%C_RESET%
echo  %C_GRAY%  Detected  : %msi_total% MSI  ^|  %exe_total% EXE  ^|  %total_pkgs% Total Packages%C_RESET%
echo  %C_CYAN%+--------------------------------------------------------------------+%C_RESET%
echo.

if %total_pkgs% equ 0 (
    echo  %C_RED%[ERROR]%C_RESET% No .msi or .exe installers found in this directory.
    echo.
    echo  Press any key to exit...
    pause >nul
    exit /b
)

:: 5. Process MSI Packages
if %msi_total% gtr 0 (
    echo  %C_CYAN%[ PHASE 1 : DEPLOYING MSI PACKAGES ]%C_RESET%
    echo  %C_GRAY%--------------------------------------------------------------------%C_RESET%
    for %%F in ("%~dp0*.msi") do (
        if exist "%%~fF" call :InstallMSI "%%~fF"
    )
    echo.
)

:: 6. Process EXE Packages
if %exe_total% gtr 0 (
    echo  %C_CYAN%[ PHASE 2 : DEPLOYING EXE PACKAGES ]%C_RESET%
    echo  %C_GRAY%--------------------------------------------------------------------%C_RESET%
    for %%F in ("%~dp0*.exe") do (
        if exist "%%~fF" call :InstallEXE "%%~fF"
    )
    echo.
)

:: 7. Final Summary UI
echo  %C_CYAN%+====================================================================+%C_RESET%
echo  %C_CYAN%^|%C_RESET%                        %C_WHITE%DEPLOYMENT SUMMARY%C_RESET%                          %C_CYAN%^|%C_RESET%
echo  %C_CYAN%+====================================================================+%C_RESET%
echo    Total Processed : %C_WHITE%%total_pkgs%%C_RESET%
echo    Succeeded       : %C_GREEN%%success_count%%C_RESET%
echo    Failed / Manual : %C_RED%%fail_count%%C_RESET%
echo  %C_CYAN%+====================================================================+%C_RESET%
echo.
echo  %C_GRAY%Press any key to close this window...%C_RESET%
pause >nul
exit /b


:: ====================================================================
:: Subroutine: MSI Installer
:: ====================================================================
:InstallMSI
set "target=%~1"
set "fname=%~nx1"
set /a current_pkg+=1

echo  %C_WHITE%[%current_pkg%/%total_pkgs%]%C_RESET% Package : %C_WHITE%%fname%%C_RESET%
echo        Engine  : %C_GRAY%Windows Installer [MSI]  ^|  Switch: /qn /norestart%C_RESET%
echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%

start /wait "" msiexec.exe /i "%target%" /qn /norestart
set "ec=%errorlevel%"

if %ec% equ 0 (
    set /a success_count+=1
    echo        Result  : %C_GREEN%[ SUCCESS ] Installed successfully%C_RESET%
) else if %ec% equ 3010 (
    set /a success_count+=1
    echo        Result  : %C_GREEN%[ SUCCESS ] Installed [System Reboot Required]%C_RESET%
) else (
    set /a fail_count+=1
    echo        Result  : %C_RED%[ FAILED  ] Exit Code: %ec%%C_RESET%
)
echo  %C_GRAY%--------------------------------------------------------------------%C_RESET%
exit /b


:: ====================================================================
:: Subroutine: Smart EXE Installer
:: ====================================================================
:InstallEXE
set "target=%~1"
set "fname=%~nx1"
set "installer_type=UNKNOWN"
set /a current_pkg+=1

echo  %C_WHITE%[%current_pkg%/%total_pkgs%]%C_RESET% Package : %C_WHITE%%fname%%C_RESET%

:: Fast 1MB header scan via PowerShell
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = $env:target; if (-not (Test-Path -LiteralPath $p)) { 'UNKNOWN'; exit }; try { $fs = [System.IO.File]::OpenRead($p); $len = [Math]::Min($fs.Length, 1048576); $b = New-Object byte[] $len; [void]$fs.Read($b, 0, $len); $fs.Close(); $s = [System.Text.Encoding]::ASCII.GetString($b); if ($s -match 'Inno Setup') { 'INNO' } elseif ($s -match 'Nullsoft') { 'NSIS' } elseif ($s -match 'InstallShield') { 'ISHIELD' } elseif ($s -match 'WixBundle|BurnEngine') { 'WIX' } elseif ($s -match 'Squirrel\.Windows|Electron') { 'SQUIRREL' } elseif ($s -match 'Google Update|Omaha') { 'CHROME' } else { 'UNKNOWN' } } catch { 'UNKNOWN' }"') do set "installer_type=%%I"

if "%installer_type%"=="INNO" (
    echo        Engine  : %C_GRAY%Inno Setup        ^|  Switch: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
) else if "%installer_type%"=="NSIS" (
    echo        Engine  : %C_GRAY%Nullsoft [NSIS]   ^|  Switch: /S%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" /S
) else if "%installer_type%"=="ISHIELD" (
    echo        Engine  : %C_GRAY%InstallShield     ^|  Switch: /s /v"/qn"%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" /s /v"/qn"
) else if "%installer_type%"=="WIX" (
    echo        Engine  : %C_GRAY%WiX Burn Engine   ^|  Switch: /quiet /norestart%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" /quiet /norestart
) else if "%installer_type%"=="SQUIRREL" (
    echo        Engine  : %C_GRAY%Squirrel/Electron ^|  Switch: --silent%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" --silent
) else if "%installer_type%"=="CHROME" (
    echo        Engine  : %C_GRAY%Google Installer  ^|  Switch: /silent /install%C_RESET%
    echo        Status  : %C_YELLOW%Installing silently, please wait...%C_RESET%
    start /wait "" "%target%" /silent /install
) else (
    echo        Engine  : %C_GRAY%Generic Installer ^|  Fallback Switch: /S%C_RESET%
    echo        Status  : %C_YELLOW%Attempting silent installation...%C_RESET%
    start /wait "" "%target%" /S
)

set "ec=%errorlevel%"
if %ec% equ 0 (
    set /a success_count+=1
    echo        Result  : %C_GREEN%[ SUCCESS ] Installed successfully%C_RESET%
) else if %ec% equ 3010 (
    set /a success_count+=1
    echo        Result  : %C_GREEN%[ SUCCESS ] Installed [System Reboot Required]%C_RESET%
) else (
    set /a fail_count+=1
    echo        Result  : %C_RED%[ FAILED  ] Exit Code: %ec%%C_RESET%
)
echo  %C_GRAY%--------------------------------------------------------------------%C_RESET%
exit /b
