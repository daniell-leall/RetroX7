@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Network Launcher

:: ================= BASE =================
set "BASEDIR=C:\RetroX7"
set "SCRIPTSDIR=%BASEDIR%\scripts"

:: ================= STARTUP =================
cls
call "%SCRIPTSDIR%\core.bat" init

:: ================= AUTO UPDATE CHECK =================
call "%SCRIPTSDIR%\check-update.bat" auto
set "UPD=%ERRORLEVEL%"

if "%UPD%"=="10" goto AUTO_UPDATE_PROMPT

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

if errorlevel 3 exit 0
if errorlevel 2 goto SETTINGS
if errorlevel 1 (
    call "%SCRIPTSDIR%\core.bat" start_full_session
    goto MENU
)

goto MENU

:: ================= AUTO UPDATE PROMPT =================
:AUTO_UPDATE_PROMPT
cls
echo ==================================================
echo             RetroX7 Update Available
echo ==================================================
echo.
call "%SCRIPTSDIR%\check-update.bat" show
echo.
echo   [1] Yes, update now
echo   [2] No, continue
echo.
choice /C 12 /N /M ">> Select an option: "

if errorlevel 2 goto MENU
if errorlevel 1 (
    call "%SCRIPTSDIR%\start-update.bat"
    goto MENU
)

:: ================= SETTINGS =================
:SETTINGS
cls
echo ==================================================
echo                 RetroX7 Settings
echo ==================================================
echo.
echo   [1] Reconfigure Network Connection
echo   [2] Clean Cache
echo   [3] Check for Updates
echo   [0] Back to Main Menu
echo.
choice /C 1230 /N /M ">> Select an option: "

if errorlevel 4 goto MENU
if errorlevel 3 goto UPDATE_MENU
if errorlevel 2 (
    call "%SCRIPTSDIR%\core.bat" clean_cache
    goto SETTINGS
)
if errorlevel 1 (
    call "%SCRIPTSDIR%\core.bat" reconfigure_network
    goto SETTINGS
)

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

if errorlevel 2 goto SETTINGS
if errorlevel 1 (
    call "%SCRIPTSDIR%\start-update.bat"
    goto MENU
)

:NO_UPDATE
cls
echo You already have the latest version.
echo.
pause
goto SETTINGS
