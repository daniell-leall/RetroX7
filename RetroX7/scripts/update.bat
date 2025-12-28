@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Update

:: Paths and URLs
set "BASEDIR=C:\RetroX7"
set "VERSION_FILE=%BASEDIR%\version.txt"

set "TEMPZIP=%TEMP%\RetroX7_update.zip"
set "TEMPX7DIR=%TEMP%\RetroX7_update"

set "GITHUB_ZIP_URL=https://github.com/daniell-leall/RetroX7/archive/refs/heads/main.zip"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/refs/heads/main/RetroX7/version.txt"

:: Script to recreate symbolic links (POST-UPDATE)
set "SYMLINK_SCRIPT=C:\RetroX7\scripts\create-symlinks.bat"

cls
echo ==================================================
echo                RetroX7 Update
echo ==================================================
echo.
echo This process will update RetroX7 files
echo without deleting local or user-created data.
echo.
echo ==================================================
echo.

:: PRE-CLEAN TEMP (IMPORTANT)
echo Preparing update environment...
echo Cleaning previous temporary files...
echo.

if exist "%TEMPZIP%" (
    echo Removing old ZIP...
    del /f /q "%TEMPZIP%"
)

if exist "%TEMPX7DIR%" (
    echo Removing old extracted folder...
    rmdir /s /q "%TEMPX7DIR%"
)

:: Download ZIP
echo.
echo Downloading update package...
echo.

curl.exe -L --progress-bar -o "%TEMPZIP%" "%GITHUB_ZIP_URL%"

if not exist "%TEMPZIP%" (
    echo ERROR: Failed to download update package.
    pause
    exit /b 1
)

:: Prepare temp folder
mkdir "%TEMPX7DIR%"

:: Extract ZIP to TEMP
echo.
echo Extracting update package...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Path '%TEMPZIP%' -DestinationPath '%TEMPX7DIR%' -Force"

if not exist "%TEMPX7DIR%\RetroX7-main\RetroX7" (
    echo ERROR: Expected RetroX7 folder structure not found.
    pause
    exit /b 1
)

:: Copy files (SAFE UPDATE)
echo.
echo Updating RetroX7 files...
echo Existing files will be replaced if needed.
echo Extra files will be preserved.
echo.

xcopy "%TEMPX7DIR%\RetroX7-main\RetroX7\*" "%BASEDIR%\" /E /I /Y >nul

:: Update version.txt
echo.
echo Updating version file...
curl.exe -s -L "%GITHUB_VERSION_URL%" > "%VERSION_FILE%"

:: Recreate symbolic links (POST-UPDATE)
echo.
echo Recreating symbolic links...
echo.

if exist "%SYMLINK_SCRIPT%" (
    call "%SYMLINK_SCRIPT%"
    echo Symbolic links recreated successfully.
) else (
    echo WARNING: Symbolic link script not found:
    echo %SYMLINK_SCRIPT%
)

:: Cleanup TEMP (post-update)
echo.
echo Cleaning temporary files...
echo.

rmdir /s /q "%TEMPX7DIR%"
del /f /q "%TEMPZIP%"

echo.
echo RetroX7 update completed successfully!
echo.
echo Relaunching RetroX7...
timeout /t 2 >nul

start "" "C:\RetroX7\scripts\run.bat"
exit