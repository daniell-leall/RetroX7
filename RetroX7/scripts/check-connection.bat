@echo off
setlocal EnableExtensions DisableDelayedExpansion

title RetroX7 - Connection Check

:CHECK_CONNECTION
cls
echo ==================================================
echo           RetroX7 - Connection Check
echo ==================================================
echo.

:: Internet connectivity check
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Write-Host ' Checking internet connectivity...' -NoNewline; Invoke-WebRequest -Uri 'https://1.1.1.1' -Method Head -TimeoutSec 5 -UseBasicParsing | Out-Null; Start-Sleep -Seconds 1; Write-Host ' OK' -ForegroundColor Green; exit 0 } catch { Start-Sleep -Seconds 1; Write-Host ' ERROR' -ForegroundColor Red; exit 1 }; exit $LASTEXITCODE"
set INTERNET_EXITCODE=%ERRORLEVEL%
if %INTERNET_EXITCODE% neq 0 goto INTERNET_ERROR

echo.

:: Server availability check
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Write-Host ' Checking RetroX7 service availability...' -NoNewline; Invoke-WebRequest -Uri 'https://retrox7.darkwebhub.store' -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop | Out-Null; Start-Sleep -Seconds 1; Write-Host ' OK' -ForegroundColor Green; exit 0 } catch { if ($_.Exception.Response) { Start-Sleep -Seconds 1; Write-Host ' OK' -ForegroundColor Green; exit 0 } else { Start-Sleep -Seconds 1; Write-Host ' ERROR' -ForegroundColor Red; exit 1 } }; exit $LASTEXITCODE"
set SERVER_EXITCODE=%ERRORLEVEL%
timeout /t 1 >nul
if %SERVER_EXITCODE% neq 0 goto SERVER_ERROR

echo.
echo ==================================================
echo               Connection successful
echo ==================================================
timeout /t 2 >nul
exit /b 0

:INTERNET_ERROR
echo.
echo ==================================================
echo              NO INTERNET CONNECTION
echo ==================================================
echo.
echo  RetroX7 requires an active internet connection.
echo  Without internet access, the system cannot operate.
echo.
echo  You can try reconnecting or exit the application.
echo.
echo   [1] Try again
echo   [0] Exit
echo.
choice /c 10 /n /m ">> Select an option: "
if errorlevel 2 goto EXIT_ERROR
if errorlevel 1 goto CHECK_CONNECTION

:SERVER_ERROR
echo.
echo ==================================================
echo             RETROX7 SERVER UNAVAILABLE
echo ==================================================
echo.
echo  Internet connection is active, but the RetroX7
echo  service could not be reached.
echo.
echo  You can try reconnecting or exit the application.
echo.
echo   [1] Retry Now
echo   [0] Exit
echo.
choice /c 10 /n /m ">> Select an option: "
if errorlevel 2 goto EXIT_ERROR
if errorlevel 1 goto CHECK_CONNECTION

:EXIT_ERROR
cls
echo ==================================================
echo               CONNECTION REQUIRED
echo ==================================================
echo.
echo  RetroX7 cannot operate because it cannot establish
echo  a connection to the required services.
echo.
echo  Please check your internet connection or wait until
echo  the RetroX7 service is available, then try again.
echo.
timeout /t 5 >nul
exit /b 1
