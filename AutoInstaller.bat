@echo off
setlocal enabledelayedexpansion
title Universal Software Auto-Installer

:: 1. Administrator rights check karein aur auto-elevate karein
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator rights ki zarurat hai. Permission request ki ja rahi hai...
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 2. Working directory ko script ke folder par set karein
cd /d "%~dp0"

echo ========================================================
echo          SILENT SOFTWARE AUTO-INSTALLER
echo ========================================================
echo Folder Path: %~dp0
echo.

:: 3. Folder ki sabhi .MSI files ko install karein
echo --------------------------------------------------------
echo [STEP 1] .MSI Files Install Ho Rahi Hain...
echo --------------------------------------------------------
set msi_count=0
for %%F in ("%~dp0*.msi") do (
    if exist "%%~fF" (
        set /a msi_count+=1
        call :InstallMSI "%%~fF"
    )
)
if %msi_count% equ 0 echo Koi bhi .msi file nahi mili.
echo.

:: 4. Folder ki sabhi .EXE files ko install karein
echo --------------------------------------------------------
echo [STEP 2] .EXE Files Install Ho Rahi Hain...
echo --------------------------------------------------------
set exe_count=0
for %%F in ("%~dp0*.exe") do (
    if exist "%%~fF" (
        set /a exe_count+=1
        call :InstallEXE "%%~fF"
    )
)
if %exe_count% equ 0 echo Koi bhi .exe file nahi mili.
echo.

echo ========================================================
echo          SABHI SOFTWARE INSTALL HO GAYE HAIN!
echo ========================================================
echo Band karne ke liye koi bhi key dabayein...
pause >nul
exit /b


:: ----------------------------------------------------------
:: Function: MSI Installer
:: ----------------------------------------------------------
:InstallMSI
set "target=%~1"
set "fname=%~nx1"
echo [+] Installing MSI: %fname% ...
start /wait msiexec.exe /i "%target%" /qn /norestart
if %errorlevel% equ 0 (
    echo     [DONE] Successfully installed: %fname%
) else (
    echo     [NOTE] Exit Code: %errorlevel%
)
echo.
exit /b


:: ----------------------------------------------------------
:: Function: EXE Installer (Smart Engine Detection)
:: ----------------------------------------------------------
:InstallEXE
set "target=%~1"
set "fname=%~nx1"
echo [+] Installing EXE: %fname% ...

:: Installer framework detect karein
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "& { param($p); if (-not (Test-Path $p)) { return 'UNKNOWN' }; $b = [System.IO.File]::ReadAllBytes($p); $len = [Math]::Min($b.Length, 1048576); $s = [System.Text.Encoding]::ASCII.GetString($b[0..($len-1)]); if ($s -match 'Inno Setup') { 'INNO' } elseif ($s -match 'Nullsoft') { 'NSIS' } elseif ($s -match 'InstallShield') { 'ISHIELD' } elseif ($s -match 'WixBundle|BurnEngine') { 'WIX' } else { 'UNKNOWN' } }" -args "%target%"') do set "installer_type=%%I"

if "%installer_type%"=="INNO" (
    echo     Type: Inno Setup detect hua (Switch: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-)
    start /wait "" "%target%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
) else if "%installer_type%"=="NSIS" (
    echo     Type: NSIS detect hua (Switch: /S)
    start /wait "" "%target%" /S
) else if "%installer_type%"=="ISHIELD" (
    echo     Type: InstallShield detect hua (Switch: /s /v\"/qn\")
    start /wait "" "%target%" /s /v"/qn"
) else if "%installer_type%"=="WIX" (
    echo     Type: WiX / Burn Engine detect hua (Switch: /quiet /norestart)
    start /wait "" "%target%" /quiet /norestart
) else (
    echo     Type: Standard Switch use kiya ja raha hai (/S)
    start /wait "" "%target%" /S
)

if %errorlevel% equ 0 (
    echo     [DONE] Successfully installed: %fname%
) else (
    echo     [NOTE] Exit Code: %errorlevel%
)
echo.
exit /b