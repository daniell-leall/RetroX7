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

goto :EOF

:: ================= INIT (ANTES DO MENU) =================

:INIT
call "%SCRIPTSDIR%\check-connection.bat"
if errorlevel 1 exit /b

call :AUTO_CHECK_UPDATES

if not exist "%CONFIGFLAG%" (
    cls
    echo ==================================================
    echo        RetroX7 first-time configuration
    echo ==================================================
    echo.
    call "%SCRIPTSDIR%\first-run.bat"
    call "%SCRIPTSDIR%\create-symlinks.bat"
)
goto :EOF

:: ================= SESSÃO PRINCIPAL =================

:START_FULL_SESSION
cls
echo ==================================================
echo   Starting RetroX7 Network + RetroBat Session
echo ==================================================
echo.

:: 1. Conecta a rede
start "RetroX7 Network" "%SCRIPTSDIR%\network-connect.bat"

:: Aguarda estabilizar
timeout /t 3 >nul

:: 2. Verifica RetroBat
if not exist "%RETROBATEXE%" (
    echo RetroBat was not found at:
    echo %RETROBATEXE%
    echo.
    pause
    call "%SCRIPTSDIR%\network-disconnect.bat"
    goto :EOF
)

:: 3. Inicia RetroBat
echo Launching RetroBat...
start "" "%RETROBATEXE%"

:: 4. Aguarda EmulationStation iniciar
echo Waiting for EmulationStation...
:WAIT_EMUSTATION_START
tasklist | find /i "%EMUSTATION_EXE%" >nul
if errorlevel 1 (
    timeout /t 1 >nul
    goto WAIT_EMUSTATION_START
)

:: 5. Aguarda EmulationStation fechar
echo EmulationStation running. Monitoring session...
:WAIT_EMUSTATION_CLOSE
tasklist | find /i "%EMUSTATION_EXE%" >nul
if not errorlevel 1 (
    timeout /t 2 >nul
    goto WAIT_EMUSTATION_CLOSE
)

:: 6. Sessão encerrada → desconecta a rede
echo.
echo RetroBat session ended. Disconnecting network...
call "%SCRIPTSDIR%\network-disconnect.bat"

timeout /t 1 >nul
goto :EOF

:: ================= SETTINGS ACTIONS =================

:RECONFIGURE_NETWORK
cls
echo ==================================================
echo     Reconfiguring RetroX7 Network Connection
echo ==================================================
echo.
call "%SCRIPTSDIR%\first-run.bat"
call "%SCRIPTSDIR%\create-symlinks.bat"
goto :EOF

:REBUILD_LINKS
cls
echo ==================================================
echo       Rebuilding RetroX7 Links and Folders
echo ==================================================
echo.
call "%SCRIPTSDIR%\create-symlinks.bat"
goto :EOF

:RESET_RETROBAT
cls
echo ==================================================
echo     Resetting RetroBat to Default Configuration
echo ==================================================
echo.
call "%SCRIPTSDIR%\reset-retrobat.bat"
goto :EOF

:CLEAN_CACHE
cls
echo ==================================================
echo           Cleaning RetroX7 Cache
echo ==================================================
echo.
call "%SCRIPTSDIR%\clean-cache.bat"
goto :EOF

:: ================= UPDATE SYSTEM =================

:CHECK_UPDATES_MANUAL
call :CHECK_UPDATES
goto :EOF

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
    echo Latest version already installed.
    timeout /t 1 >nul
    goto :EOF
)

cls
echo ==================================================
echo            RetroX7 Update Available
echo ==================================================
echo.
echo Local version : %LOCAL_VERSION%
echo Remote version: %REMOTE_VERSION%
echo.
echo Starting update...
echo RetroX7 will now close.
echo.

timeout /t 2 >nul

start "" "%SCRIPTSDIR%\update.bat"

:: CORE FINALIZA — UPDATE ASSUME CONTROLE TOTAL
exit /b

:AUTO_CHECK_UPDATES
call :CHECK_UPDATES
goto :EOF
