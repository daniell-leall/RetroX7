@echo off
echo Disconnecting RetroX7 network...

:: Encerra rclone (ajuste o nome se necessário)
taskkill /F /IM rclone.exe >nul 2>&1

echo Network disconnected.
exit /b
