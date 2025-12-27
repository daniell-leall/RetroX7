@echo off
setlocal EnableDelayedExpansion
title RetroBat :: Reset to Default (Verbose)

:: CORE PATHS
set "RETROBAT_ROOT=C:\RetroBat"
set "RETROBAT_ROMS=%RETROBAT_ROOT%\roms"
set "RETROBAT_BIOS=%RETROBAT_ROOT%\bios"

:: EmulationStation config (FILE)
set "RETROBAT_ES_CONFIG=%RETROBAT_ROOT%\emulationstation\.emulationstation\es_settings.cfg"

:: EmulationStation music (FOLDER)
set "RETROBAT_ES_MUSIC=%RETROBAT_ROOT%\emulationstation\.emulationstation\music"

set "BACKUP_SUFFIX=_backup"

:: Console list (somente para restaurar backups)
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

:: RESET RetroBat (Verbose)
cls
echo ===============================================
echo Restoring default RetroBat structure
echo ===============================================
echo.

:: Remove ROM symlinks
echo Removing ROM symbolic links...
for /d %%D in ("%RETROBAT_ROMS%\*") do (
    fsutil reparsepoint query "%%D" >nul 2>&1
    if not errorlevel 1 (
        echo   Removing link: %%D
        rmdir "%%D"
    )
)

:: Restore ROM folders from backup
echo.
echo Restoring ROM folders from backups...
for /f "usebackq tokens=1 delims==" %%A in ("%CONSOLE_LIST%") do (
    if exist "%RETROBAT_ROMS%\%%A%BACKUP_SUFFIX%" (
        echo   Restoring folder: %%A
        ren "%RETROBAT_ROMS%\%%A%BACKUP_SUFFIX%" "%%A"
    ) else (
        if not exist "%RETROBAT_ROMS%\%%A" (
            echo   Creating folder: %%A
            mkdir "%RETROBAT_ROMS%\%%A"
        )
    )
)

:: Restore BIOS from backup
echo.
if exist "%RETROBAT_BIOS%%BACKUP_SUFFIX%" (
    echo Restoring BIOS folder...
    rmdir "%RETROBAT_BIOS%" 2>nul
    ren "%RETROBAT_BIOS%%BACKUP_SUFFIX%" "bios"
    echo   BIOS restored successfully.
) else (
    echo BIOS backup not found, skipping.
)

:: Restore EmulationStation config file
echo.
echo Restoring EmulationStation configuration file...

:: Remove symlink if it exists
if exist "%RETROBAT_ES_CONFIG%" (
    fsutil reparsepoint query "%RETROBAT_ES_CONFIG%" >nul 2>&1
    if not errorlevel 1 (
        echo   Removing symbolic link: es_settings.cfg
        del "%RETROBAT_ES_CONFIG%"
    )
)

:: Restore backup if it exists
if exist "%RETROBAT_ES_CONFIG%%BACKUP_SUFFIX%" (
    echo   Restoring es_settings.cfg from backup
    ren "%RETROBAT_ES_CONFIG%%BACKUP_SUFFIX%" "es_settings.cfg"
    echo   EmulationStation config restored successfully.
) else (
    echo   es_settings.cfg backup not found, skipping.
)

:: Restore EmulationStation music folder
echo.
echo Restoring EmulationStation music folder...

:: Remove symlink if it exists
if exist "%RETROBAT_ES_MUSIC%" (
    fsutil reparsepoint query "%RETROBAT_ES_MUSIC%" >nul 2>&1
    if not errorlevel 1 (
        echo   Removing symbolic link: music
        rmdir "%RETROBAT_ES_MUSIC%"
    )
)

:: Restore backup if it exists
if exist "%RETROBAT_ES_MUSIC%%BACKUP_SUFFIX%" (
    echo   Restoring music folder from backup
    ren "%RETROBAT_ES_MUSIC%%BACKUP_SUFFIX%" "music"
    echo   Music folder restored successfully.
) else (
    echo   Music backup not found, skipping.
)

echo.
echo Reset completed successfully.
timeout /t 3 >nul
exit /b
