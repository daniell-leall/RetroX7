@echo off
setlocal EnableExtensions DisableDelayedExpansion

title RetroX7 - Configuration

set BASEDIR=C:\RetroX7
set RCLONEDIR=%BASEDIR%\rclone
set CONFIGDIR=%RCLONEDIR%\.config
set CONFIGFILE=%CONFIGDIR%\rclone.conf
set CONFIGFLAG=%CONFIGDIR%\.configured
set TMPPASS=%TEMP%\rx_pass.tmp

set RCLONE_CONFIG=%CONFIGFILE%

if not exist "%CONFIGDIR%" mkdir "%CONFIGDIR%"

cls
echo ==================================================
echo              RetroX7 - Configuration
echo ==================================================
echo.

:CREDENTIALS
cls
echo ==================================================
echo            The service is operational
echo ==================================================
echo.
echo Please enter your credentials below.
echo.

set /p RX_USER=" Username: "
set /p RX_PASS=" Password: "

echo %RX_PASS%>"%TMPPASS%"
set RX_PASS=
set /p RX_PASS=<"%TMPPASS%"

cls
echo Creating rclone configuration...
"%RCLONEDIR%\rclone.exe" config create SFTPGo webdav ^
    url "https://retrox7.darkwebhub.store" ^
    vendor "other" ^
    user "%RX_USER%" ^
    pass "%RX_PASS%"

if errorlevel 1 goto AUTH_ERROR

cls
echo Testing server authentication...
"%RCLONEDIR%\rclone.exe" lsd SFTPGo:

if errorlevel 1 goto AUTH_ERROR

echo configured > "%CONFIGFLAG%"

del "%TMPPASS%" >nul 2>&1
set RX_PASS=

cls
echo ==================================================
echo       CONFIGURATION COMPLETED SUCCESSFULLY
echo ==================================================
echo Configuration flag created at:
echo %CONFIGFLAG%
echo.
exit /b

:AUTH_ERROR
del "%TMPPASS%" >nul 2>&1
del "%CONFIGFILE%" >nul 2>&1

cls
echo ==================================================
echo               AUTHENTICATION FAILED
echo ==================================================
echo.
echo  Invalid username or password.
echo.
echo   [1] Try again
echo   [0] Exit
echo.

choice /c 10 /n /m "Select an option: "

if errorlevel 2 exit /b
if errorlevel 1 goto CREDENTIALS
