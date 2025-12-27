@echo off
setlocal EnableExtensions EnableDelayedExpansion

mode con: cols=180 lines=18
title RetroX7 - Network Connection

:: Check internet and server connectivity first
call "C:\RetroX7\scripts\check-connection.bat"
if errorlevel 1 (
    echo.
    echo Connection check FAILED. Cannot proceed with network mount.
    echo.
    pause
    exit /b 1
)

:: Verify configuration file exists
set "BASEDIR=C:\RetroX7"
set "RCLONEDIR=%BASEDIR%\rclone"
set "CONFIGFILE=%BASEDIR%\rclone\.config\rclone.conf"

if not exist "%CONFIGFILE%" (
    cls
    echo ==================================================
    echo           NO CONFIGURATION FILE FOUND
    echo ==================================================
    echo.
    echo  The RetroX7 network configuration file was not found.
    echo.
    echo  Please configure your connection before proceeding.
    echo.
    pause
    exit /b 1
)

:: Paths for mount and cache
set "MOUNTDIR=%BASEDIR%\mnt\sftpgo"
set "CACHEDIR=%RCLONEDIR%\cache"

cls
echo ==================================================
echo        Starting RetroX7 Network Connection
echo ==================================================
echo.
echo  IMPORTANT:
echo  - Keep this window OPEN to stay connected.
echo  - Closing it will DISCONNECT the network.
echo.

:: Check if already connected
if exist "%MOUNTDIR%" (
    dir "%MOUNTDIR%" >nul 2>&1
    if not errorlevel 1 (
        cls
        echo ==================================================
        echo  RetroX7 network is already CONNECTED
        echo.
        echo  Close the existing connection window
        echo  before starting a new one.
        echo ==================================================
        echo.
        pause
        exit /b
    )
)

:: Prepare mount and cache directories
echo Removing existing mount directory...
if exist "%MOUNTDIR%" (
    rmdir /s /q "%MOUNTDIR%"
)

if not exist "%CACHEDIR%" (
    mkdir "%CACHEDIR%" >nul 2>&1
)

echo.
echo Connecting to RetroX7 network...
echo.

:: Mount the network
"%RCLONEDIR%\rclone.exe" mount SFTPGo: "%MOUNTDIR%" ^
    --config "%CONFIGFILE%" ^
    --cache-dir "%CACHEDIR%" ^
    --vfs-cache-mode full ^
    --vfs-cache-max-age 30d ^
    --vfs-cache-max-size 30G ^
    --vfs-read-chunk-size 32M ^
    --vfs-read-chunk-size-limit 2G ^
    --links ^
    --log-level INFO ^
    --log-format date,time

:: Disconnect message
echo.
echo ==================================================
echo RetroX7 network DISCONNECTED
echo ==================================================
pause
exit /b
