@echo off
setlocal EnableExtensions EnableDelayedExpansion

title RetroX7 - Clean rclone Cache

set "BASEDIR=C:\RetroX7"
set "CACHE_DIR=%BASEDIR%\rclone\cache"
set "KEEP_FILE=.gitkeep"

cls
echo ==================================================
echo        Cleaning Cache
echo ==================================================
echo.

if not exist "%CACHE_DIR%" (
    echo Cache folder not found.
    goto END
)

echo Removing all cache contents, keeping %KEEP_FILE%...
echo.

:: Remove files (except .gitkeep)
for %%F in (%CACHE_DIR%\*) do (
    if exist "%%F" (
        if /I not "%%~nxF"=="%KEEP_FILE%" (
            del /f /q "%%F" >nul 2>&1
        )
    )
)

:: Remove directories
for /d %%D in (%CACHE_DIR%\*) do (
    rd /s /q "%%D" >nul 2>&1
)

echo Cache cleaned successfully.

:END
echo.
timeout /t 3 >nul
exit /b
