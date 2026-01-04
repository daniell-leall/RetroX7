@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Network Launcher

:: Diretórios base
set BASEDIR=C:\RetroX7
set SCRIPTSDIR=%BASEDIR%\scripts

:: Inicialização geral (rede, auto-update, first-run)
call "%SCRIPTSDIR%\core.bat" init

:MENU
cls
echo ==================================================
echo              RetroX7 Network Manager
echo ==================================================
echo.
echo   [1] Start RetroX7 Network + RetroBat
echo   [2] Settings
echo   [0] Exit
echo.
choice /C 120 /N /M ">> Select an option: "

if errorlevel 3 exit
if errorlevel 2 goto SETTINGS
if errorlevel 1 call "%SCRIPTSDIR%\core.bat" start_full_session
goto MENU

:SETTINGS
cls
echo ==================================================
echo                 RetroX7 Settings
echo ==================================================
echo.
echo   [1] Reconfigure Network Connection
echo   [2] Rebuild RetroX7 Links ^& Folders
echo   [3] Reset RetroBat to Default Settings
echo   [4] Clean Cache
echo   [5] Check for Updates
echo   [0] Back to Main Menu
echo.
choice /C 123450 /N /M ">> Select an option: "

if errorlevel 6 goto MENU

:: UPDATE → CORE INICIA UPDATE → MENU ENCERRA
if errorlevel 5 (
    call "%SCRIPTSDIR%\core.bat" check_updates_manual
    exit
)

if errorlevel 4 call "%SCRIPTSDIR%\core.bat" clean_cache
if errorlevel 3 call "%SCRIPTSDIR%\core.bat" reset_retrobat
if errorlevel 2 call "%SCRIPTSDIR%\core.bat" rebuild_links
if errorlevel 1 call "%SCRIPTSDIR%\core.bat" reconfigure_network
goto SETTINGS
