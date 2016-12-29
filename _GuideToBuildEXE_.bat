@echo off
SETLOCAL
SET Ahk2Exe=.\Ahk2Exe.exe
if not exist "%Ahk2Exe%" SET Ahk2Exe=.\AutoHotkey\Ahk2Exe.exe
if not exist "%Ahk2Exe%" SET Ahk2Exe=.\.AutoHotkey\Ahk2Exe.exe
if exist "%Ahk2Exe%" (
	taskkill /F /IM FB_TimeSaver.exe >nul 2>&1
	"%Ahk2Exe%" /in FB_TimeSaver.ahk /out FB_TimeSaver.exe
	start "" FB_TimeSaver.exe
	::echo Done.
	::pause
	exit
) else (
	if exist ".\Ahk2Exe_AIO.exe" (
		start "" ".\Ahk2Exe_AIO.exe"
		exit
	) else (
		echo.
		echo Download Ahk2Exe "recommended this version", to build the exe file, :
		echo    Page:     https://github.com/hossam-magdy/FB-TimeSaver/releases/tag/Ahk2Exe-AIO
		echo Direct link: https://github.com/hossam-magdy/FB-TimeSaver/archive/Ahk2Exe-AIO.zip
		::start "" "https://github.com/hossam-magdy/FB-TimeSaver/releases/tag/Ahk2Exe-AIO"
		::start "" "https://github.com/hossam-magdy/FB-TimeSaver/archive/Ahk2Exe-AIO.zip"
		echo.
	)
)
