@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: Configurações
set "BASEDIR=C:\RetroX7"
set "VERSION_FILE=%BASEDIR%\version.txt"
set "TEMP_REMOTE_VERSION=%TEMP%\retrox7_remote_version.txt"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/daniell-leall/RetroX7/refs/heads/main/RetroX7/version.txt"

:: Argumento opcional
set "ACTION=%1"

:: Pega versões
if exist "%VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%VERSION_FILE%"
) else (
    set LOCAL_VERSION=0.0.0
)

curl.exe -s -L "%GITHUB_VERSION_URL%" > "%TEMP_REMOTE_VERSION%"
set /p REMOTE_VERSION=<"%TEMP_REMOTE_VERSION%"
del "%TEMP_REMOTE_VERSION%"

:: Se for "show", apenas imprime versões
if /I "%ACTION%"=="show" (
    echo Local version : %LOCAL_VERSION%
    echo Remote version: %REMOTE_VERSION%
    echo.
    if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
        echo You already have the latest version.
    ) else (
        echo A new version is available.
    )
    exit /b
)

:: Retorna status para run.bat
if "%LOCAL_VERSION%"=="%REMOTE_VERSION%" (
    exit /b 0
) else (
    exit /b 10
)
