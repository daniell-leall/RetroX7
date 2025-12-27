@echo off
setlocal EnableExtensions EnableDelayedExpansion

mode con: cols=180 lines=20
title RetroX7 - Network Connection

:: Paths
set "BASEDIR=C:\RetroX7"
set "RCLONEDIR=%BASEDIR%\rclone"
set "MOUNTDIR=%BASEDIR%\mnt\sftpgo"
set "CONFIGFILE=%BASEDIR%\rclone\.config\rclone.conf"
set "CACHEDIR=%RCLONEDIR%\cache"

cls
echo ==================================================
echo        Starting RetroX7 Network Connection
echo ==================================================
echo.
echo IMPORTANT:
echo - Keep this window OPEN to stay connected.
echo - Closing it will DISCONNECT the network.
echo.

:: Check active connection
if exist "%MOUNTDIR%" (
    dir "%MOUNTDIR%" >nul 2>&1
    if not errorlevel 1 (
        cls
        echo ==================================================
        echo RetroX7 network is already CONNECTED
        echo.
        echo Close the existing connection window
        echo before starting a new one.
        echo ==================================================
        echo.
        pause
        exit /b
    )
)

:: Prepare mount directory
echo Removing existing mount directory...
if exist "%MOUNTDIR%" (
    rmdir /s /q "%MOUNTDIR%"
)

:: Prepare cache directory
if not exist "%CACHEDIR%" (
    mkdir "%CACHEDIR%" >nul 2>&1
)

echo.
echo Connecting to RetroX7 network...
echo.

:: Mount
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
