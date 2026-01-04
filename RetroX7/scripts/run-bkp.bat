@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Network Launcher

:: ================= BASE =================
set "BASEDIR=C:\RetroX7"
set "SCRIPTSDIR=%BASEDIR%\scripts"

:: ================= STARTUP =================
cls
call "%SCRIPTSDIR%\core.bat" init

:: ================= AUTO UPDATE =================
call "%SCRIPTSDIR%\check-update.bat" auto
set "UPD=%ERRORLEVEL%"

if "%UPD%"=="10" (
    cls
    echo ==================================================
    echo             RetroX7 Update Available
    echo ==================================================
    echo.
    :: Mostra versões
    call "%SCRIPTSDIR%\check-update.bat" show
    echo.
    echo   [1] Yes, update now
    echo   [2] No, continue
    echo.
    choice /C 12 /N /M ">> Select an option: "
    set "CHOICE=%ERRORLEVEL%"
    if "%CHOICE%"=="1" (
        call "%SCRIPTSDIR%\start-update.bat"
        exit
    )
)

:: ====== GARANTE QUE SEMPRE VAI PARA O MENU ======
goto MENU

:: ================= MAIN MENU =================
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
set "CHOICE=%ERRORLEVEL%"

:: Corrigido para usar os valores corretos do choice
if "%CHOICE%"=="1" call "%SCRIPTSDIR%\core.bat" start_full_session && goto MENU
if "%CHOICE%"=="2" goto SETTINGS
if "%CHOICE%"=="3" exit 0  :: 0 é a terceira opção em /C 120
goto MENU

:: ================= SETTINGS =================
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
set "CHOICE=%ERRORLEVEL%"

:: Corrigido para usar os valores corretos do choice
if "%CHOICE%"=="1" call "%SCRIPTSDIR%\core.bat" reconfigure_network && goto SETTINGS
if "%CHOICE%"=="2" call "%SCRIPTSDIR%\core.bat" rebuild_links && goto SETTINGS
if "%CHOICE%"=="3" call "%SCRIPTSDIR%\core.bat" reset_retrobat && goto SETTINGS
if "%CHOICE%"=="4" call "%SCRIPTSDIR%\core.bat" clean_cache && goto SETTINGS
if "%CHOICE%"=="5" goto UPDATE_MENU
if "%CHOICE%"=="6" goto MENU  :: 0 é a sexta opção em /C 123450
goto SETTINGS

:: ================= MANUAL UPDATE =================
:UPDATE_MENU
cls
echo ==================================================
echo           Checking for RetroX7 updates
echo ==================================================
echo.

call "%SCRIPTSDIR%\check-update.bat" manual
set "UPD=%ERRORLEVEL%"

if "%UPD%"=="0" goto NO_UPDATE
if "%UPD%"=="10" goto HAS_UPDATE

:: Segurança
echo Unexpected error in update check (%UPD%)
pause
goto SETTINGS

:HAS_UPDATE
cls
echo ==================================================
echo           RetroX7 Update Available
echo ==================================================
echo.
call "%SCRIPTSDIR%\check-update.bat" show
echo.
echo   [1] Yes, update now
echo   [2] No, return
echo.
choice /C 12 /N /M ">> Select an option: "
set "CHOICE=%ERRORLEVEL%"

if "%CHOICE%"=="1" (
    call "%SCRIPTSDIR%\start-update.bat"
    exit
)

:: Se escolheu 2, volta para menu de configurações
goto SETTINGS

:NO_UPDATE
cls
echo You already have the latest version.
echo.
pause
goto SETTINGS