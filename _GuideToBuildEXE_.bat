@echo off

echo to build the exe file, download Ahk2Exe (recommended this version):
echo Download page: https://github.com/hossam-magdy/FB-TimeSaver/releases/tag/Ahk2Exe-AIO
echo Direct link:   https://github.com/hossam-magdy/FB-TimeSaver/archive/Ahk2Exe-AIO.zip
::start "" "https://github.com/hossam-magdy/FB-TimeSaver/releases/tag/Ahk2Exe-AIO"
::start "" "https://github.com/hossam-magdy/FB-TimeSaver/archive/Ahk2Exe-AIO.zip"


::taskkill /F /IM FB_TimeSaver.exe >nul 2>&1

::".\Ahk2Exe.exe" /in FB_TimeSaver.ahk /out FB_TimeSaver.exe

::start "" FB_TimeSaver.exe

::::echo Done.
::::pause
