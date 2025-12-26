@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Clean rclone Cache

:: ===============================
:: Paths
:: ===============================
set "BASEDIR=C:\RetroX7"
set "CACHE_DIR=%BASEDIR%\rclone\cache"
set "KEEP_FILE=version.txt"  :: troque pelo nome do arquivo que quer manter

cls
echo ==================================================
echo        Cleaning rclone Cache
echo ==================================================
echo.

if exist "%CACHE_DIR%" (
    echo Removing files from cache, keeping %KEEP_FILE%...
    for %%F in ("%CACHE_DIR%\*") do (
        if /I not "%%~nxF"=="%KEEP_FILE%" (
            del /f /q "%%F" 2>nul
        )
    )
    echo Cache cleaned successfully.
) else (
    echo Cache folder not found.
)

echo.
pause
exit /b
