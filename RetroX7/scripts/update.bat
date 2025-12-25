@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Forced Update

:: ===============================
:: Paths and URLs
:: ===============================
set BASEDIR=C:\RetroX7
set VERSION_FILE=%BASEDIR%\version.txt
set TEMPZIP=%TEMP%\RetroX7_update.zip
set DEST=%BASEDIR%

set GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/main/version.txt
set GITHUB_DOWNLOAD_URL=https://github.com/daniell-leall/RetroX7/raw/main/RetroX7.zip

cls
echo ==================================================
echo            RetroX7 Forced Update
echo ==================================================
echo.
echo This process will update RetroX7 regardless of
echo the currently installed version.
echo.
echo ==================================================
echo.

:: ===============================
:: Download RetroX7 ZIP
:: ===============================
echo Downloading RetroX7 package...
echo.

curl.exe -L -C - --progress-bar -o "%TEMPZIP%" "%GITHUB_DOWNLOAD_URL%"

:: ===============================
:: Extract files
:: ===============================
echo.
echo Extracting files to:
echo   %DEST%
echo.

powershell -Command "Expand-Archive -Path '%TEMPZIP%' -DestinationPath '%DEST%' -Force"

del /f /q "%TEMPZIP%"

:: ===============================
:: Update version.txt (optional but recommended)
:: ===============================
echo Updating version file...
curl.exe -s -L "%GITHUB_VERSION_URL%" > "%VERSION_FILE%"

echo.
echo ==================================================
echo Update completed successfully!
echo ==================================================
echo.

pause
exit /b
