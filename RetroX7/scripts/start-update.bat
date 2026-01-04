@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Start Update

:: ================= CONFIGURAÇÃO =================
set "BASEDIR=C:\RetroX7"
set "VERSION_FILE=%BASEDIR%\version.txt"
set "TEMPZIP=%TEMP%\RetroX7_update.zip"
set "TEMPX7DIR=%TEMP%\RetroX7_update"
set "GITHUB_ZIP_URL=https://github.com/daniell-leall/RetroX7/archive/refs/heads/main.zip"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/refs/heads/main/RetroX7/version.txt"
set "SYMLINK_SCRIPT=%BASEDIR%\scripts\create-symlinks.bat"

cls
echo ==================================================
echo                RetroX7 Update
echo ==================================================
echo.

:: ================= PRE-CLEAN =================

if exist "%TEMPZIP%" del /f /q "%TEMPZIP%"
if exist "%TEMPX7DIR%" rmdir /s /q "%TEMPX7DIR%"

:: ================= DOWNLOAD =================

echo Downloading update package...
curl.exe -L --progress-bar -o "%TEMPZIP%" "%GITHUB_ZIP_URL%"

if not exist "%TEMPZIP%" (
    echo ERROR: Failed to download update package.
    pause
    exit /b 1
)

:: ================= EXTRACT =================

mkdir "%TEMPX7DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Path '%TEMPZIP%' -DestinationPath '%TEMPX7DIR%' -Force"

if not exist "%TEMPX7DIR%\RetroX7-main\RetroX7" (
    echo ERROR: Invalid update package structure.
    pause
    exit /b 1
)

:: ================= UPDATE FILES =================

echo Updating RetroX7 files...
xcopy "%TEMPX7DIR%\RetroX7-main\RetroX7\*" "%BASEDIR%\" /E /I /Y >nul

:: ================= VERSION =================

curl.exe -s -L "%GITHUB_VERSION_URL%" > "%VERSION_FILE%"

:: ================= SYMLINKS =================

if exist "%SYMLINK_SCRIPT%" (
    call "%SYMLINK_SCRIPT%"
    echo Symbolic links recreated successfully.
) else (
    echo WARNING: Symbolic link script not found.
)

:: ================= CLEANUP =================

rmdir /s /q "%TEMPX7DIR%"
del /f /q "%TEMPZIP%"

:: ================= FINAL =================

cls
echo ==================================================
echo            RetroX7 Update Completed
echo ==================================================
echo.
echo The update was installed successfully.
echo.
echo IMPORTANT: Please restart RetroX7 to apply changes.
echo.
pause
exit
