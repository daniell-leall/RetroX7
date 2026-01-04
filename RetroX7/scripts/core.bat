@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ================= CONFIGURAÇÃO BASE =================

set BASEDIR=C:\RetroX7
set SCRIPTSDIR=%BASEDIR%\scripts
set RCLONEDIR=%BASEDIR%\rclone
set CONFIGDIR=%RCLONEDIR%\.config
set CONFIGFILE=%CONFIGDIR%\rclone.conf
set CONFIGFLAG=%CONFIGDIR%\.configured

set VERSION_FILE=%BASEDIR%\version.txt
set TEMP_REMOTE_VERSION=%TEMP%\retrox7_remote_version.txt
set GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/refs/heads/main/RetroX7/version.txt

set RETROBATDIR=C:\RetroBat
set RETROBATEXE=%RETROBATDIR%\RetroBat.exe
set EMUSTATION_EXE=emulationstation.exe

:: ================= DISPATCHER =================

set ACTION=%1

if "%ACTION%"=="init" goto INIT
if "%ACTION%"=="start_full_session" goto START_FULL_SESSION
if "%ACTION%"=="reconfigure_network" goto RECONFIGURE_NETWORK
if "%ACTION%"=="rebuild_links" goto REBUILD_LINKS
if "%ACTION%"=="reset_retrobat" goto RESET_RETROBAT
if "%ACTION%"=="clean_cache" goto CLEAN_CACHE
if "%ACTION%"=="check_updates_manual" goto CHECK_UPDATES_MANUAL

exit /b 0

:: ================= INIT (ANTES DO MENU) =================

:INIT
call "%SCRIPTSDIR%\check-connection.bat"
if errorlevel 1 exit /b 1

:: Apenas verifica — NÃO atualiza
call :CHECK_UPDATES
exit /b %ERRORLEVEL%

:: ================= SESSÃO PRINCIPAL =================

:START_FULL_SESSION
cls
echo ==================================================
echo   Starting RetroX7 Network + RetroBat Session
echo ==================================================
echo.

start "RetroX7 Network" "%SCRIPTSDIR%\network-connect.bat"
timeout /t 3 >nul

if not exist "%RETROBATEXE%" (
    echo RetroBat was not found at:
    echo %RETROBATEXE%
    pause
    call "%SCRIPTSDIR%\network-disconnect.bat"
    exit /b 1
)

start "" "%RETROBATEXE%"

:WAIT_EMUSTATION_START
tasklist | find /i "%EMUSTATION_EXE%" >nul || (
    timeout /t 1 >nul
    goto WAIT_EMUSTATION_START
)

:WAIT_EMUSTATION_CLOSE
tasklist | find /i "%EMUSTATION_EXE%" >nul && (
    timeout /t 2 >nul
    goto WAIT_EMUSTATION_CLOSE
)

call "%SCRIPTSDIR%\network-disconnect.bat"
exit /b 0

:: ================= SETTINGS =================

:RECONFIGURE_NETWORK
call "%SCRIPTSDIR%\first-run.bat"
call "%SCRIPTSDIR%\create-symlinks.bat"
exit /b 0

:REBUILD_LINKS
call "%SCRIPTSDIR%\create-symlinks.bat"
exit /b 0

:RESET_RETROBAT
call "%SCRIPTSDIR%\reset-retrobat.bat"
exit /b 0

:CLEAN_CACHE
call "%SCRIPTSDIR%\clean-cache.bat"
exit /b 0

:: ================= UPDATE CHECK =================
:: Retornos:
:: 0  = Sem update
:: 10 = Update disponível

:CHECK_UPDATES_MANUAL
call :CHECK_UPDATES
exit /b %ERRORLEVEL%

:CHECK_UPDATES
if exist "%VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%VERSION_FILE%"
) else (
    set LOCAL_VERSION=0.0.0
)

curl.exe -s -L "%GITHUB_VERSION_URL%" > "%TEMP_REMOTE_VERSION%"
set /p REMOTE_VERSION=<"%TEMP_REMOTE_VERSION%"
del "%TEMP_REMOTE_VERSION%"

if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    exit /b 0
)

exit /b 10
