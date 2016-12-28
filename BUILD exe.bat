@echo off

taskkill /F /IM FB_TimeSaver.exe >nul 2>&1

".\.AutoHotKey\Ahk2Exe.exe" /in FB_TimeSaver.ahk /out FB_TimeSaver.exe

::start "" FB_TimeSaver.exe

echo Done.
pause