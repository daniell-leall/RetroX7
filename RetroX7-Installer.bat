@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 Setup - Installer

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ==================================================
echo                 RetroX7 Installer
echo ==================================================
echo.
echo  Created by Daniel Leal
echo.
echo  RetroX7 is an integration tool designed to work
echo  alongside RetroBAT, enabling advanced features
echo  such as remote storage and filesystem support.
echo.
echo  This installer will guide you through the
echo  required dependencies and setup steps.
echo.
echo ==================================================
echo.
echo  Press any key to continue...
pause >nul
cls

:: Variables
set "TEMPDIR=%TEMP%"

set "RETROBATURL=https://github.com/RetroBat-Official/retrobat/releases/download/7.5.2/RetroBat-v7.5.2.1-stable-win64-setup.exe"
set "WINFSPURL=https://github.com/winfsp/winfsp/releases/download/v2.1/winfsp-2.1.25156.msi"
set "ZIPURL=https://github.com/daniell-leall/RetroX7/archive/refs/heads/main.zip"

set "RETROBATFILE=%TEMPDIR%\RetroBat-setup.exe"
set "WINFSPFILE=%TEMPDIR%\WinFsp.msi"
set "TEMPZIP=%TEMPDIR%\RetroX7.zip"

set "DEST=C:\RetroX7"
set "RETROBATDIR=C:\RetroBat"

:: RetroBAT step
cls
echo ==================================================
echo              RetroBAT installation
echo ==================================================
echo.

if exist "%RETROBATDIR%" (
    echo  RetroBAT installation detected at:
    echo  %RETROBATDIR%
    echo.
) else (
    echo  RetroBAT could not be located in the default installation directory.
    echo.
)

echo  IMPORTANT:
echo.
echo  RetroBAT must be installed in the default location:
echo  C:\RetroBat
echo  Installing it in a different folder may cause errors.
echo.
echo  During installation, please install all dependencies
echo  requested by the RetroBAT installer.
echo.
echo ==================================================
echo  Choose an option:
echo.
echo   [1] Install or reinstall RetroBAT
echo   [2] Skip this step and continue
echo.

choice /C 12 /N /M ">> Select an option: "

if errorlevel 2 goto AFTER_RETROBAT
if errorlevel 1 goto INSTALL_RETROBAT

:INSTALL_RETROBAT
cls
echo ==================================================
echo             Downloading RetroBAT...
echo ==================================================
echo.

curl.exe -L -C - --progress-bar -o "%RETROBATFILE%" "%RETROBATURL%"

echo.
echo Download completed.
echo Launching RetroBAT installer...
echo.

start /wait "" "%RETROBATFILE%"

echo.
echo RetroBAT installation finished.
echo.

:AFTER_RETROBAT
cls

:: WinFSP step
echo ==================================================
echo               WinFSP installation
echo ==================================================
echo.
echo WinFSP is required for RetroX7 (rclone filesystem).
echo Please complete the installer when prompted.
echo.

curl.exe -L -C - --progress-bar -o "%WINFSPFILE%" "%WINFSPURL%"

echo.
echo Launching WinFSP installer...
echo.

start /wait msiexec /i "%WINFSPFILE%"

echo.
echo WinFSP installation finished.
echo.

cls

:: RetroX7 step
echo ==================================================
echo              RetroX7 installation
echo ==================================================
echo.

echo Downloading RetroX7...
curl.exe -L --progress-bar -o "%TEMPZIP%" "%ZIPURL%"

if not exist "%TEMPZIP%" (
    echo ERROR: RetroX7.zip was not downloaded.
    goto END_INSTALL
)

echo.
echo Extracting RetroX7 to TEMP...
echo.

set "TEMPX7DIR=%TEMPDIR%\RetroX7"

if exist "%TEMPX7DIR%" rmdir /s /q "%TEMPX7DIR%"
mkdir "%TEMPX7DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Path '%TEMPZIP%' -DestinationPath '%TEMPX7DIR%' -Force"

if not exist "%TEMPX7DIR%\RetroX7-main\RetroX7" (
    echo ERROR: Expected RetroX7 folder structure not found.
    goto END_INSTALL
)

echo.
echo Moving RetroX7 files to:
echo   %DEST%
echo.

if exist "%DEST%" rmdir /s /q "%DEST%"
mkdir "%DEST%"

xcopy "%TEMPX7DIR%\RetroX7-main\RetroX7\*" "%DEST%\" /E /I /Y >nul

echo.
echo Cleaning temporary files...
echo.

:: rmdir /s /q "%TEMPX7DIR%"
:: del /f /q "%TEMPZIP%"

if exist "%RETROBATFILE%" del /f /q "%RETROBATFILE%"
if exist "%WINFSPFILE%" del /f /q "%WINFSPFILE%"

echo.
echo ==================================================
echo Installation completed successfully!
echo ==================================================
echo.
echo.
echo.
echo.
echo.

:: Create Desktop Shortcuts
cls
echo ==================================================
echo        Creating RetroX7 desktop shortcuts
echo ==================================================
echo.

set "SHORTCUT_SOURCE=C:\RetroX7\RetroX7.lnk"

if not exist "%SHORTCUT_SOURCE%" (
    echo ERROR: Shortcut not found at:
    echo %SHORTCUT_SOURCE%
    echo.
    goto END_SHORTCUT
)

:: User Desktop
if exist "%USERPROFILE%\Desktop" (
    if not exist "%USERPROFILE%\Desktop\RetroX7.lnk" (
        copy /Y "%SHORTCUT_SOURCE%" "%USERPROFILE%\Desktop\" >nul
        echo Shortcut created on user desktop.
    ) else (
        echo Shortcut already exists on user desktop. Skipping.
    )
)

:: Public Desktop (All Users)
if exist "C:\Users\Public\Desktop" (
    if not exist "C:\Users\Public\Desktop\RetroX7.lnk" (
        copy /Y "%SHORTCUT_SOURCE%" "C:\Users\Public\Desktop\" >nul
        echo Shortcut created on public desktop.
    ) else (
        echo Shortcut already exists on public desktop. Skipping.
    )
)

:: OneDrive Desktop
if exist "%USERPROFILE%\OneDrive\Desktop" (
    if not exist "%USERPROFILE%\OneDrive\Desktop\RetroX7.lnk" (
        copy /Y "%SHORTCUT_SOURCE%" "%USERPROFILE%\OneDrive\Desktop\" >nul
        echo Shortcut created on OneDrive desktop.
    ) else (
        echo Shortcut already exists on OneDrive desktop. Skipping.
    )
)

echo.
echo Desktop shortcut creation completed.
echo.

:END_SHORTCUT
goto END_INSTALL

:END_INSTALL
exit /b
