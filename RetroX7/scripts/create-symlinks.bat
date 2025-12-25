@echo off
setlocal EnableDelayedExpansion
title RetroX7 :: Create Symbolic Links

:: =====================================================
:: PATH CONFIGURATION
:: =====================================================
set "RETROBAT_ROOT=C:\RetroBat"
set "RETROBAT_ROMS=%RETROBAT_ROOT%\roms"
set "RETROBAT_BIOS=%RETROBAT_ROOT%\bios"

set "BACKUP_SUFFIX=_backup"

set "SOURCE_BASE=C:\RetroX7\mnt\sftpgo\3. Platforms"
set "SOURCE_BIOS=C:\RetroX7\mnt\sftpgo\1. Retrobat - Core & Scripts\bios"

:: --- EmulationStation settings (FILE) ---
set "RETROBAT_ES_CONFIG=%RETROBAT_ROOT%\emulationstation\.emulationstation\es_settings.cfg"
set "SOURCE_ES_CONFIG=C:\RetroX7\mnt\sftpgo\1. Retrobat - Core & Scripts\config\es_settings.cfg"

:: =====================================================
:: CONSOLE DEFINITIONS
:: =====================================================
set "CONSOLE_LIST=%TEMP%\retro_x7_consoles.txt"

(
echo nes=Nintendo - NES\roms
echo snes=Nintendo - SNES\roms
echo n64=Nintendo - N64\roms
echo gba=Nintendo - GBA\roms
echo gbc=Nintendo - GBC\roms
echo mastersystem=Sega - Master System\roms
echo megadrive=Sega - Genesis\roms
echo gamegear=Sega - Game Gear\roms
echo sega32x=Sega - 32X\roms
echo psx=Sony - PS1\isos
echo ps2=Sony - PS2\isos
echo psp=Sony - PSP\isos
echo atari2600=Atari - 2600\roms
echo dos=Microsoft - DOS\exes
echo dreamcast=Sega - Dreamcast\roms
echo saturn=Sega - Saturn\roms
echo neogeo=SNK - Neo Geo\roms
) > "%CONSOLE_LIST%"

:: =====================================================
:: CREATE ROM LINKS
:: =====================================================
cls
echo ===============================================
echo Creating ROM symbolic links
echo Source: %SOURCE_BASE%
echo Destination: %RETROBAT_ROMS%
echo ===============================================
echo.

for /f "usebackq tokens=1,2 delims==" %%A in ("%CONSOLE_LIST%") do (
    set "RETRO_FOLDER=%%A"
    set "TARGET_PATH=%SOURCE_BASE%\%%B"
    set "DEST=%RETROBAT_ROMS%\!RETRO_FOLDER!"

    if exist "!DEST!" (
        call :IS_SYMLINK "!DEST!"
        if errorlevel 1 (
            if not exist "!DEST!!BACKUP_SUFFIX!" (
                ren "!DEST!" "!RETRO_FOLDER!!BACKUP_SUFFIX!"
            )
        )
    )

    if exist "!DEST!" (
        call :IS_SYMLINK "!DEST!"
        if not errorlevel 1 rmdir "!DEST!"
    )

    mklink /D "!DEST!" "!TARGET_PATH!" >nul
    echo Linked ROMs: !RETRO_FOLDER!
)

:: =====================================================
:: CREATE BIOS LINK
:: =====================================================
echo.
echo Creating BIOS symbolic link
echo Source: %SOURCE_BIOS%
echo Destination: %RETROBAT_BIOS%
echo.

set "DEST=%RETROBAT_BIOS%"
set "SRC=%SOURCE_BIOS%"

if exist "%DEST%" (
    call :IS_SYMLINK "%DEST%"
    if errorlevel 1 (
        if not exist "%DEST%%BACKUP_SUFFIX%" (
            ren "%DEST%" "bios%BACKUP_SUFFIX%"
        )
    )
)

if exist "%DEST%" (
    call :IS_SYMLINK "%DEST%"
    if not errorlevel 1 rmdir "%DEST%"
)

mklink /D "%DEST%" "%SRC%" >nul
echo Linked BIOS directory

:: =====================================================
:: CREATE EMULATIONSTATION CONFIG FILE LINK
:: =====================================================
echo.
echo Creating EmulationStation config symbolic link
echo Source: %SOURCE_ES_CONFIG%
echo Destination: %RETROBAT_ES_CONFIG%
echo.

set "DEST=%RETROBAT_ES_CONFIG%"
set "SRC=%SOURCE_ES_CONFIG%"

if exist "%DEST%" (
    call :IS_SYMLINK "%DEST%"
    if errorlevel 1 (
        if not exist "%DEST%%BACKUP_SUFFIX%" (
            ren "%DEST%" "es_settings.cfg%BACKUP_SUFFIX%"
        )
    )
)

if exist "%DEST%" (
    call :IS_SYMLINK "%DEST%"
    if not errorlevel 1 del "%DEST%"
)

mklink "%DEST%" "%SRC%" >nul
echo Linked EmulationStation config file

echo.
echo All symbolic links created successfully.
timeout /t 3 >nul
exit /b

:: =====================================================
:: SYMBOLIC LINK DETECTION
:: =====================================================
:IS_SYMLINK
fsutil reparsepoint query "%~1" >nul 2>&1
exit /b %errorlevel%
