@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===============================
:: Window title
:: ===============================
title RetroX7 - Network Launcher

:: ===============================
:: Base paths
:: ===============================
set BASEDIR=C:\RetroX7
set SCRIPTSDIR=%BASEDIR%\scripts
set RCLONEDIR=%BASEDIR%\rclone
set CONFIGDIR=%RCLONEDIR%\.config
set CONFIGFILE=%CONFIGDIR%\rclone.conf
set CONFIGFLAG=%CONFIGDIR%\.configured

:: ===============================
:: Update / version
:: ===============================
set VERSION_FILE=%BASEDIR%\version.txt
set TEMP_REMOTE_VERSION=%TEMP%\retrox7_remote_version.txt
set GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/refs/heads/main/RetroX7/version.txt

:: ===============================
:: RetroBat
:: ===============================
set RETROBATDIR=C:\RetroBat
set RETROBATEXE=%RETROBATDIR%\RetroBat.exe

:: Tell rclone where the config is
set RCLONE_CONFIG=%CONFIGFILE%

cls

:: ===============================
:: Automatic update check (startup)
:: ===============================
call :AUTO_CHECK_UPDATES

:: ===============================
:: Check configuration (first run)
:: ===============================
if not exist "%CONFIGFLAG%" (
    cls
    echo ==================================================
    echo RetroX7 first-time setup required
    echo ==================================================
    echo.
    echo No network configuration was found.
    echo.
    echo You must configure your connection before continuing.
    echo.
    call "%SCRIPTSDIR%\first-run.bat"

    echo.
    echo Creating symbolic links...
    call "%SCRIPTSDIR%\create-symlinks.bat"
    echo Symbolic links created successfully.
    cls
)

:: ===============================
:: Main menu
:: ===============================
:MENU
cls
echo ==================================================
echo              RetroX7 Network Manager
echo ==================================================
echo.
echo   [1] Start RetroX7 Network
echo   [2] Start RetroBat
echo   [3] Reconfigure RetroX7 Connection
echo   [4] Reconfigure RetroX7 Folders
echo   [5] Reset RetroBat (Default Settings)
echo   [6] Check for Updates
echo   [0] Exit
echo.
choice /C 1234560 /N /M ">> Select an option: "

if errorlevel 7 goto EXIT
if errorlevel 6 goto CHECK_UPDATES
if errorlevel 5 goto RESET_RETROBAT
if errorlevel 4 goto RECONFIGURE_FOLDERS
if errorlevel 3 goto RECONFIGURE
if errorlevel 2 goto START_RETROBAT
if errorlevel 1 goto START
goto MENU

:: ===============================
:: Start network
:: ===============================
:START
cls
echo ==================================================
echo             Starting RetroX7 Network
echo ==================================================
echo.
echo A new connection window will be opened.
echo.
echo IMPORTANT:
echo - Keep the connection window OPEN to stay connected.
echo - Closing that window will DISCONNECT the network.
echo.
timeout /t 5 >nul

if exist "C:\RetroX7\mnt\sftpgo" (
    rmdir /s /q "C:\RetroX7\mnt\sftpgo"
)

start "RetroX7 Network Connection" "%RCLONEDIR%\rclone.exe" mount SFTPGo: C:\RetroX7\mnt\sftpgo --vfs-cache-mode minimal

goto MENU

:: ===============================
:: Start RetroBat
:: ===============================
:START_RETROBAT
cls
echo ==================================================
echo               Starting RetroBat
echo ==================================================
echo.

if not exist "%RETROBATEXE%" (
    echo RetroBat was not found at:
    echo %RETROBATEXE%
    echo.
    pause
    goto MENU
)

start "" "%RETROBATEXE%"
goto MENU

:: ===============================
:: Reconfigure connection
:: ===============================
:RECONFIGURE
cls
echo ==================================================
echo Reconfiguring RetroX7 connection
echo ==================================================
call "%SCRIPTSDIR%\first-run.bat"

echo.
echo Creating symbolic links...
call "%SCRIPTSDIR%\create-symlinks.bat"

goto MENU

:: ===============================
:: Reconfigure folders
:: ===============================
:RECONFIGURE_FOLDERS
cls
echo ==================================================
echo Reconfiguring RetroX7 folders
echo ==================================================
call "%SCRIPTSDIR%\create-symlinks.bat"

goto MENU

:: ===============================
:: Reset RetroBat
:: ===============================
:RESET_RETROBAT
cls
echo ==================================================
echo Resetting RetroBat to default settings
echo ==================================================
call "%SCRIPTSDIR%\retrobat-reset.bat"

goto MENU

:: ===============================
:: Check for Updates (manual)
:: ===============================
:CHECK_UPDATES
cls
echo ==================================================
echo           Checking for RetroX7 updates
echo ==================================================
echo.

if exist "%VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%VERSION_FILE%"
) else (
    set LOCAL_VERSION=0.0.0
)

curl.exe -s -L "%GITHUB_VERSION_URL%" > "%TEMP_REMOTE_VERSION%"
set /p REMOTE_VERSION=<"%TEMP_REMOTE_VERSION%"
del "%TEMP_REMOTE_VERSION%"

echo Local version : %LOCAL_VERSION%
echo Remote version: %REMOTE_VERSION%
echo.

if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    echo You already have the latest version.
    echo.
    pause
    goto MENU
)

echo A new version is available.
echo.
echo   [1] Yes, update now
echo   [2] No, return to menu
echo.
choice /C 12 /N /M ">> Select an option: "

if errorlevel 2 goto MENU
if errorlevel 1 call "%SCRIPTSDIR%\update.bat"
goto MENU

:: ===============================
:: Automatic update check (startup)
:: ===============================
:AUTO_CHECK_UPDATES

if exist "%VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%VERSION_FILE%"
) else (
    set LOCAL_VERSION=0.0.0
)

curl.exe -s -L "%GITHUB_VERSION_URL%" > "%TEMP_REMOTE_VERSION%"
set /p REMOTE_VERSION=<"%TEMP_REMOTE_VERSION%"
del "%TEMP_REMOTE_VERSION%"

if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    goto :EOF
)

cls
echo ==================================================
echo           RetroX7 Update Available
echo ==================================================
echo.
echo Local version : %LOCAL_VERSION%
echo Remote version: %REMOTE_VERSION%
echo.
echo   [1] Yes, update now
echo   [2] No, continue
echo.
choice /C 12 /N /M ">> Select an option: "

if errorlevel 2 goto :EOF
if errorlevel 1 call "%SCRIPTSDIR%\update.bat"
goto :EOF

:: ===============================
:: Exit
:: ===============================
:EXIT
cls
echo Exiting RetroX7.
exit /b
