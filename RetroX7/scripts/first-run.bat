@echo off
setlocal EnableExtensions DisableDelayedExpansion

title RetroX7 - Configuration

:: Paths
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
echo RetroX7 - Configuration
echo ==================================================
echo.

:: Username
set /p RX_USER=Username: 

:: Password (visível no CMD)
set /p RX_PASS=Password: 

:: Gravar senha temporariamente
echo %RX_PASS%>"%TMPPASS%"

:: Limpar variável e reler do arquivo
set RX_PASS=
set /p RX_PASS=<"%TMPPASS%"

:: Criacao do rclone config
cls
echo Criando configuracao do rclone...
"%RCLONEDIR%\rclone.exe" config create SFTPGo webdav url "https://retrox7.darkwebhub.store" vendor "other" user "%RX_USER%" pass "%RX_PASS%"
if errorlevel 1 (
    echo ERRO: falha ao criar configuracao do rclone.
    del "%TMPPASS%" >nul 2>&1
    exit /b
)

:: Teste de autenticacao
cls
echo Testando conexao com o servidor...
"%RCLONEDIR%\rclone.exe" lsd SFTPGo:
if errorlevel 1 (
    echo ERRO: falha na autenticacao.
    del "%CONFIGFILE%" >nul 2>&1
    del "%TMPPASS%" >nul 2>&1
    exit /b
)

:: Marcar como configurado
echo configured > "%CONFIGFLAG%"

:: Cleanup
del "%TMPPASS%" >nul 2>&1
set RX_PASS=

cls
echo ==================================================
echo CONFIGURACAO CONCLUIDA COM SUCESSO
echo ==================================================
echo Arquivo .configured criado em:
echo %CONFIGFLAG%
exit /b
