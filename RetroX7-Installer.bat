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

:: ===============================
:: Variables
:: ===============================
set TEMPDIR=%TEMP%

set RETROBATURL=https://github.com/RetroBat-Official/retrobat/releases/download/7.5.2/RetroBat-v7.5.2.1-stable-win64-setup.exe
set WINFSPURL=https://github.com/winfsp/winfsp/releases/download/v2.1/winfsp-2.1.25156.msi
set ZIPURL=https://github.com/daniell-leall/RetroX7/raw/main/RetroX7.zip

set RETROBATFILE=%TEMPDIR%\RetroBat-setup.exe
set WINFSPFILE=%TEMPDIR%\WinFsp.msi
set TEMPZIP=%TEMPDIR%\RetroX7.zip

set DEST=C:\RetroX7
set RETROBATDIR=C:\RetroBat

:: ===============================
:: Create destination folder
:: ===============================
if not exist "%DEST%" mkdir "%DEST%"

cls

:: ===============================
:: RetroBAT step
:: ===============================
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
echo  If your internet connection drops during the download,
echo  you can close this installer and run it again.
echo  The download will automatically resume.
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

:: ===============================
:: WinFSP step
:: ===============================
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

:: ===============================
:: RetroX7 step
:: ===============================
echo ==================================================
echo              RetroX7 installation
echo ==================================================
echo.

curl.exe -L -C - --progress-bar -o "%TEMPZIP%" "%ZIPURL%"

echo.
echo Extracting RetroX7 to:
echo   %DEST%
echo.

powershell -Command "Expand-Archive -Path '%TEMPZIP%' -DestinationPath '%DEST%' -Force"

del /f /q "%TEMPZIP%"

echo.
echo ==================================================
echo Installation completed successfully!
echo ==================================================
echo.
echo.
echo.
echo.
echo.

:: ===============================
:: Create Desktop Shortcuts
:: ===============================
cls
echo ==================================================
echo        Creating RetroX7 desktop shortcuts
echo ==================================================
echo.

set SHORTCUT_SOURCE=C:\RetroX7\RetroX7.lnk

if not exist "%SHORTCUT_SOURCE%" (
    echo ERROR: Shortcut not found at:
    echo %SHORTCUT_SOURCE%
    echo.
    goto END_SHORTCUT
)

:: User Desktop
if exist "%USERPROFILE%\Desktop" (
    copy /Y "%SHORTCUT_SOURCE%" "%USERPROFILE%\Desktop\" >nul
    echo Shortcut copied to user desktop.
)

:: Public Desktop (All Users)
if exist "C:\Users\Public\Desktop" (
    copy /Y "%SHORTCUT_SOURCE%" "C:\Users\Public\Desktop\" >nul
    echo Shortcut copied to public desktop.
)

:: OneDrive Desktop (if exists)
if exist "%USERPROFILE%\OneDrive\Desktop" (
    copy /Y "%SHORTCUT_SOURCE%" "%USERPROFILE%\OneDrive\Desktop\" >nul
    echo Shortcut copied to OneDrive desktop.
)

echo.
echo Desktop shortcut creation completed.
echo.

:END_SHORTCUT

