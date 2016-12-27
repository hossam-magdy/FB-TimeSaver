#Persistent
#SingleInstance FORCE
#MaxMem 5
;#MaxHotkeysPerInterval 10000
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Download:
; AHK & Ahk2Exe:			https://autohotkey.com/download/1.1/
; * The NEW Ahk2Exe.exe:	https://fincs.ahk4.net/files/					(size > 800 KB: supports "Directives": http://fincs.ahk4.net/Ahk2ExeDirectives.htm)
; MPRESS (compress exe):	https://autohotkey.com/mpress/mpress_web.htm	(put mpress.exe with Ahk2exe.exe)
; SciTE4AutoHotkey:			https://fincs.ahk4.net/scite4ahk/
;@Ahk2Exe-SetDescription	FB-TimeSaver
;@Ahk2Exe-SetName			FB-TimeSaver
;@Ahk2Exe-SetVersion		1.20160303
;@Ahk2Exe-SetCopyright		Copyrigh © 2016 by Hossam Magdy
;@Ahk2Exe-UseResourceLang	0x0409
;@Ahk2Exe-SetMainIcon		icon.ico
;;@Ahk2Exe-AddResource		icon_alert.ico (not yet supported from fincs: https://fincs.ahk4.net/Ahk2ExeDirectives.htm)

;******* TODO : 
;- Save tmp to Env
;- SingleInstance OFF
;- Logout option : (logoutURL) car is ready
;- Get # of Not,Mes,Fr & operate based on it
;- xXx Use "Microsoft.XmlHttp" OR "InternetExplorer.Application" instead of "WinHttp.WinHttpRequest"
;if (window.XMLHttpRequest) var http = new XMLHttpRequest();
;else var http = new ActiveXObject("microsoft.xmlhttp");
; OR ComObjCreate("InternetExplorer.Application")
;*******

Restart:
Menu, TRAY, Icon, *, 1, 1

DEBUG						:= 0
IsDeveloper					:= 1
IniSettings_File			=%A_ScriptDir%\FB_TimeSaver.ini

IniRead, Alert_Sound,		%IniSettings_File%, Settings, Alert_Sound, 0
IniRead, Alert_TrayTip,		%IniSettings_File%, Settings, Alert_TrayTip, 1
IniRead, Alert_TrayIcon,	%IniSettings_File%, Settings, Alert_TrayIcon, 1
IniRead, CheckEvery,		%IniSettings_File%, Settings, CheckEvery, 30
IniRead, Sound_Notify,		%IniSettings_File%, Settings, Sound_Notify, FB_TimeSaver_SoundNotify.wav

AppLogDirectory				=%A_ScriptDir%
AskRememberBrowser			:= 1
deviceSavedAsRecognized		:= -1 ; Default value (-1: no dev recog , 0: dev not saved , 1: dev saved)
lastCheck					:= 0

TrayTipDefault				:= "FB Time Saver"
;TimeFormat					:= DEBUG ? "hh:mm:sstt" : "hh:mmtt"
TimeFormat					:= DEBUG ? "HH:mm:ss" : "HH:mm"
DateFormat					:= "ddd yyyy-MM-dd"
DateTimeFormat				=%DateFormat% %TimeFormat%
InputBoxWidth				:= 335
InputBoxHeight				:= 180


Menu, TRAY, NoStandard
Menu, TRAY, DeleteAll
Menu, TRAY, Add, Exit, MenuHandler


;NotMes := checkNotificationsAndMessages(clipboard)
;MsgBox, %NotMes%

FirstPhase := 1
MinutesCaseSince := 0


;tmp:=getPeriod(20150519234430, 20150520001530, 1, 1)
;MsgBox, %tmp%
;ExitApp


HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
HttpObj.SetTimeouts(10000,10000,10000,10000) ;Set timeouts to x seconds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; SIGNING IN - SECURITY CHECKS - REDIRECTS ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckLogIn:
;MsgBox, Checking Log In State
Resp := ""
HttpObj.Open("GET","https://mbasic.facebook.com/")
setRequestHeaders(HttpObj)
try HttpObj.Send()
getResponseHeaders(HttpObj)
try Resp := HttpObj.ResponseText
;MsgBox, %Resp%
;FileAppend, %Resp%, %AppLogDirectory%\Resp.htm
analysis := analyseResponse(Resp)
;MsgBox, %analysis%
if(analysis=="Empty"){
	Goto, CheckPoint_RememberBrowser_Request
}else if(analysis=="Login"){
	Goto, Login
}else if(analysis=="SecurityCode"){
	Goto, CheckPoint_SecurityCode
}else if(analysis=="CheckPoint_RememberBrowser"){
	Goto, CheckPoint_RememberBrowser
}else if(analysis=="Redirecting"){
	Goto, Redirecting
}else if(analysis=="LoggedIn"){
	Goto, LoggedIn
}
;MsgBox, All known possibilites are passed`r`n Analysis: %analysis% | Resp is Unknown : %Resp%
Goto, CheckLogIn


Login:
if(IsDeveloper){
	email := "dev_mail"
	password := "dev_pass"
}else{
	InputBox, email,Login , Username`, Email or Phone, , InputBoxWidth, InputBoxHeight, , , , 30
	InputBox, password, Login, Password, HIDE, InputBoxWidth, InputBoxHeight, , , 
}
loginURL := "https://mbasic.facebook.com/login.php"
lsd  := getFormHiddenVal(Resp, "lsd")
m_ts := getFormHiddenVal(Resp, "m_ts")
li   := getFormHiddenVal(Resp, "li")
loginBody := "lsd=" lsd "&m_ts=" m_ts "&li=" li "&login=Log In&email=" email "&pass=" password "&persistent=1"
;MsgBox, %loginBody%
;MsgBox, %Resp%
Login_Request:
Resp := ""
HttpObj.Open("POST",loginURL)
setRequestHeaders(HttpObj)
try HttpObj.Send(loginBody)
getResponseHeaders(HttpObj)
try Resp := HttpObj.ResponseText
;MsgBox, %Resp%
;FileAppend, %Resp%, %AppLogDirectory%\Resp.htm
analysis := analyseResponse(Resp)
;MsgBox, %analysis%
if(analysis=="Empty"){
	Goto, CheckPoint_RememberBrowser_Request
}else if(analysis=="Login"){
	MsgBox, 16, FB Time Saver, Sorry: Incorrect email or password, 60
	Goto, Login
}else if(analysis=="SecurityCode"){
	Goto, CheckPoint_SecurityCode
}else if(analysis=="CheckPoint_RememberBrowser"){
	Goto, CheckPoint_RememberBrowser
}else if(analysis=="Redirecting"){
	Goto, Redirecting
}else if(analysis=="LoggedIn"){
	Goto, LoggedIn
}
;MsgBox, All known possibilites are passed`r`n Analysis: %analysis% | Resp is Unknown : %Resp%
Goto, CheckLogIn


Redirecting:
;MsgBox, Redirecting to %redirectToURL%
Resp := ""
HttpObj.Open("GET",redirectToURL)
setRequestHeaders(HttpObj)
try HttpObj.Send(loginBody)
getResponseHeaders(HttpObj)
try Resp := HttpObj.ResponseText
;MsgBox, %Resp%
;FileAppend, %Resp%, %AppLogDirectory%\Resp.htm
analysis := analyseResponse(Resp)
;MsgBox, %analysis%
if(analysis=="Empty"){
	Goto, CheckPoint_RememberBrowser_Request
}else if(analysis=="Login"){
	Goto, Login
}else if(analysis=="SecurityCode"){
	Goto, CheckPoint_SecurityCode
}else if(analysis=="CheckPoint_RememberBrowser"){
	Goto, CheckPoint_RememberBrowser
}else if(analysis=="Redirecting"){
	Goto, Redirecting
}else if(analysis=="LoggedIn"){
	Goto, LoggedIn
}
;MsgBox, All known possibilites are passed`r`n Analysis: %analysis% | Resp is Unknown : %Resp%
Goto, CheckLogIn


CheckPoint_SecurityCode:
SecurityCode:
SecurityCode1:
checkpointURL := "https://mbasic.facebook.com/login/checkpoint/"
InputBox, approvals_code, Security Code, Security Code is required :, , InputBoxWidth, InputBoxHeight
lsd := getFormHiddenVal(Resp, "lsd")
nh  := getFormHiddenVal(Resp, "nh")
loginBody := "lsd=" lsd "&approvals_code=" approvals_code "&codes_submitted=0&submit[Submit Code]=Submit code&nh=" nh 
;MsgBox, %loginBody%
CheckPoint_SecurityCode_Request:
Resp := ""
HttpObj.Open("POST",checkpointURL)
setRequestHeaders(HttpObj)
try HttpObj.Send(loginBody)
getResponseHeaders(HttpObj)
;MsgBox, Code response :
try Resp := HttpObj.ResponseText
;MsgBox, %Resp%
;FileAppend, %Resp%, %AppLogDirectory%\Resp.htm
analysis := analyseResponse(Resp)
;MsgBox, %analysis%
if(analysis=="Empty"){
	Goto, CheckPoint_RememberBrowser_Request
}else if(analysis=="Login"){
	Goto, Login
}else if(analysis=="SecurityCode"){
	MsgBox, 16, FB Time Saver, Sorry: Incorrect security code, 60
	Goto, CheckPoint_SecurityCode
}else if(analysis=="CheckPoint_RememberBrowser"){
	Goto, CheckPoint_RememberBrowser
}else if(analysis=="Redirecting"){
	Goto, Redirecting
}else if(analysis=="LoggedIn"){
	Goto, LoggedIn
}
;MsgBox, All known possibilites are passed`r`n Analysis: %analysis% | Resp is Unknown : %Resp%
Goto, CheckLogIn


CheckPoint_RememberBrowser: ;;;;;;;;;;;;;;;; REMEMBER BROWSER
checkpointURL := "https://mbasic.facebook.com/login/checkpoint/"
if(AskRememberBrowser){
	MsgBox, 4, FB Time Saver, Remember {FB TimeSaver} such that`r`nyou do not have to enter security code again ?, 60
	IfMsgBox Yes
	{
		name_action_selected := "save_device"
		deviceSavedAsRecognized := 1
	}
	IfMsgBox Timeout
	{
		name_action_selected := "save_device"
		deviceSavedAsRecognized := 1
	}
	IfMsgBox No
	{
		name_action_selected := "dont_save"
		deviceSavedAsRecognized := 0
	}
}else{
	name_action_selected := "save_device"
}
lsd := getFormHiddenVal(Resp, "lsd")
nh  := getFormHiddenVal(Resp, "nh")
loginBody := "lsd=" lsd "&name_action_selected=" name_action_selected "&codes_submitted=0&submit[Continue]=Continue&nh=" nh 
;MsgBox, %loginBody%
CheckPoint_RememberBrowser_Request:
Resp := ""
try HttpObj.Open("POST",checkpointURL)
setRequestHeaders(HttpObj)
try HttpObj.Send(loginBody)
getResponseHeaders(HttpObj)
;MsgBox, Code response :
try Resp := HttpObj.ResponseText
;MsgBox, %Resp%
;FileAppend, %Resp%, %AppLogDirectory%\Resp.htm
analysis := analyseResponse(Resp)
;MsgBox, %analysis%
if(analysis=="Empty"){
	Goto, CheckPoint_RememberBrowser_Request
}else if(analysis=="Login"){
	Goto, Login
}else if(analysis=="SecurityCode"){
	Goto, CheckPoint_SecurityCode
}else if(analysis=="CheckPoint_RememberBrowser"){
	Goto, CheckPoint_RememberBrowser
}else if(analysis=="Redirecting"){
	Goto, Redirecting
}else if(analysis=="LoggedIn"){
	Goto, LoggedIn
}
;MsgBox, All known possibilites are passed`r`n Analysis: %analysis% | Resp is Unknown : %Resp%
Goto, CheckLogIn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; SIGNING IN - SECURITY CHECKS - REDIRECTS ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


LoggedIn:
NotMesOld := ""

;PassBy:
;PassBy := 0

;SetTimer, Check, 15000

Menu, TRAY, Tip , %TrayTipDefault%
Menu, TRAY, NoStandard
Menu, TRAY, DeleteAll
Menu, TRAY, Add, About, MenuHandler
Menu, TRAY, Add, Show status and Recheck, MenuHandler
Menu, TRAY, Add, Alert: TrayTip , MenuHandler
if( Alert_TrayTip ){
	Menu, TRAY, Check, Alert: TrayTip, MenuHandler
}
Menu, TRAY, Add, Alert: TrayIcon, MenuHandler
if( Alert_TrayIcon ){
	Menu, TRAY, Check, Alert: TrayIcon, MenuHandler
}
Menu, TRAY, Add, Alert: Sound, MenuHandler
if( Alert_Sound ){
	Menu, TRAY, Check, Alert: Sound, MenuHandler
}
Menu, TRAY, Add, Set CheckEvery, MenuHandler
Menu, TRAY, Add, Reset all, MenuHandler
Menu, TRAY, Add, Exit, MenuHandler

Goto, SkipMenuHandler
MenuHandler:
if ( A_ThisMenuItem=="About" ){
	MsgBox, 64, FB Time Saver, { FB Time Saver v1.20150926 }`r`n`r`n`r`nAre you spending much time browing the facebook news feed or checking if a friend sent you a message ?`r`n`r`nThis desktop software can check your account frequently for you & if you have any Notifications, Messages or FriendRequests it can inform you by:`r`n- TrayTip desktop notification (Hotkey: LeftWin + LeftShift)`r`n- Sound alert`r`n- Tray icon`r`nYou can also switch them off, if you want.`r`n`r`nSave your time (sorry facebook).`r`n`r`n`r`nDeveloped by:`r`nHossam Magdy`r`nhossam.magdy@ieee.org
} else if ( A_ThisMenuItem=="Show status and Recheck" ){
	show_fbStatus()
} else if ( A_ThisMenuItem=="Alert: TrayTip" ){
	if( Alert_TrayTip==1 ){
		Alert_TrayTip := 0
		Menu, TRAY, Uncheck, Alert: TrayTip, MenuHandler
	}else{
		Alert_TrayTip := 1
		Menu, TRAY, Check, Alert: TrayTip, MenuHandler
	}
} else if ( A_ThisMenuItem=="Alert: TrayIcon" ){
	if( Alert_TrayIcon==1 ){
		Alert_TrayIcon := 0
		Menu, TRAY, Uncheck, Alert: TrayIcon, MenuHandler
		Menu, TRAY, Icon, *, 1, 1
	}else{
		Alert_TrayIcon := 1
		Menu, TRAY, Check, Alert: TrayIcon, MenuHandler
	}
} else if ( A_ThisMenuItem=="Alert: Sound" ){
	if( Alert_Sound==1 ){
		Alert_Sound := 0
		Menu, TRAY, Uncheck, Alert: Sound, MenuHandler
	}else{
		Alert_Sound := 1
		Menu, TRAY, Check, Alert: Sound, MenuHandler
	}
} else if ( A_ThisMenuItem=="Set CheckEvery" ){
	tmp := Round(CheckEvery)
	InputBox, inputVar, CheckEvery = ?? sec, Now checking every ~%tmp% sec`r`nenter a new value [from 30 to 3600 sec], , InputBoxWidth, InputBoxHeight
	inputVar := Round(inputVar)
	;Transform, inputVar, Round, %inputVar%, 2
	if( inputVar>=30 && inputVar<=3600 ){
		CheckEvery := inputVar
	}else{
		MsgBox, 48, FB Time Saver, Sorry: the entered value is not acceptable or out-of-range, 60
	}
} else if ( A_ThisMenuItem=="Reset all" ){
	;IniDelete, %IniSettings_File%, Settings, last_L
	MsgBox, 4, FB Time Saver, Are you sure you want to reset all settings (use it if problems encountered)?, 60
	IfMsgBox Yes
	{
		FileDelete, %IniSettings_File%
		Goto, Restart
	}
	;FileDelete, %LogData_File%
	Goto, CheckLogIn
} else if ( A_ThisMenuItem=="Exit" ){
	ExitApp
}
IniWrite, %Alert_Sound%,		%IniSettings_File%, Settings, Alert_Sound
IniWrite, %Alert_TrayTip%,		%IniSettings_File%, Settings, Alert_TrayTip
IniWrite, %Alert_TrayIcon%,		%IniSettings_File%, Settings, Alert_TrayIcon
IniWrite, %CheckEvery%,			%IniSettings_File%, Settings, CheckEvery
IniWrite, %Sound_Notify%,		%IniSettings_File%, Settings, Sound_Notify
FileSetAttrib, +H+S, %IniSettings_File%
;Goto, Check
SkipMenuHandler:



Check:
	ActTTip := ""

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	checkNotificationsAndMessagesRequest:
	Resp := ""
	HttpObj.Open("GET","https://mbasic.facebook.com/menu/bookmarks")
	setRequestHeaders(HttpObj)
	try HttpObj.Send()
	getResponseHeaders(HttpObj)
	try Resp := HttpObj.ResponseText
	if(Strlen(Resp)==0){
		Sleep, ( 2000 )
		Goto, checkNotificationsAndMessagesRequest
	}
	Resp := UnHTML(Resp)
	NotMes := checkNotificationsAndMessages(Resp)
	if( NotMes != NotMesOld && StrLen(NotMes)>0 ){
		if( Alert_Sound ){
			SoundPlay, %Sound_Notify%
		}
		if( Alert_TrayTip ){
			TrayTip, %email%, %NotMes%, 15, 1
		}
		Sleep, ( 1000 )
	}
	NotMesOld := NotMes
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	ActToolTipF := ""
	FormatTime, TimeNow, , hh:mm:ss tt
	;ActToolTipF = @ %TimeNow%`r`n%NotMes%`r`n%ActToolTipF%
	ActToolTipF = %NotMes%`r`n%ActToolTipF%
	ActToolTipF := Trim(ActToolTipF,"`r`n ")

	;Menu, TRAY, Tip , %ActToolTipF%
	;if(StrLen(NotMes)>0){
	;	ActTTip = %NotMes%`r`n%ActTTip%
	;	TrayTip = @ %TimeNow%`r`n%NotMes%
	;	Menu, TRAY, Tip , %TrayTip%
	;}else{
	;	Menu, TRAY, Tip , %TrayTipDefault%
	;}

	;if(GetKeyState("LCtrl")==1 && GetKeyState("LShift")==1){
	;	ToolTip, %ActToolTipF%
	;	Sleep, ( 5000 )
	;	ToolTip
	;}else{
	;	ToolTip
	;}
	;MsgBox, Here2:%ActToolTipF%
	;CaseOld := CaseNew
	if(FirstPhase==1){
		FirstPhase := 0
		if( Alert_Sound ){
			SoundPlay, %Sound_Notify%
		}
		if( Alert_TrayTip ){
			TrayTip, ,FB Time Saver is started%A_SPACE%, 15
		}
		;Sleep, ( 3000 )
		;ToolTip
		;MsgBox, ,FB Time Saver,FB Time Saver is started
	}
	
	FormatTime, TimeNow, , %TimeFormat%
	;Menu, TRAY, Tip , Last check @ %TimeNow%
	Menu, TRAY, Tip , @ %TimeNow%`r`n%ActToolTipF%
	
	if( Alert_TrayIcon ){
		if( StrLen(NotMes)>0 )
			Menu, TRAY, Icon, %A_ScriptFullPath%, 2, 1
		else
			Menu, TRAY, Icon, *, 1, 1
	}
	
	Sleep, ( CheckEvery*1000 )
	ActTTip := " "

Goto, Check ; the INFINITE LOOP

~LWin & ~LShift::
	;ToolTip, Checking ..., 0, 0
	;Sleep, ( 1000 )
	;MsgBox, Here1
	;Tips:
	;MsgBox, Here2
	;if(GetKeyState("LCtrl")==1 && GetKeyState("LShift")==1 && GetKeyState("LAlt")==1){
	;}
	show_fbStatus()
	;ToolTip
	;Goto, Check
Return
Goto, Check


Exit:
ExitApp


Sleeper( min ) {
	Loop, min
	{
		Sleep, 1000
	}

}


show_fbStatus() {
	global ActToolTipF
	global TimeNow
	global email
	StringReplace, tmpX, ActToolTipF, `t, %A_SPACE%, 1
	tmpX := Trim(tmpX,"`r`n`t ")
	TrayTip, %email% @ %TimeNow%, %tmpX%, 15, 1
	;ToolTip, %ActToolTipF%, 0, 0
	Sleep, 500
	;Goto, Tips
}


UnHTML( HTML ) {
	HTML := StrReplace( HTML, "&amp;", "&")
	HTML := StrReplace( HTML, "&nbsp;", " ")
	HTML := StrReplace( HTML, "<span", " <span")
	HTML := StrReplace( HTML, "<div", "<br /><div")
	HTML := StrReplace( HTML, "<br>", "`r`n")
	HTML := StrReplace( HTML, "<br />", "`r`n")
	HTML := RegExReplace( HTML, "(<br />|<br>)", "`r`n")
	HTML := RegExReplace( HTML, "<style(.*)</style>", "")
	HTML := RegExReplace( HTML, "<([^>]+)>", "")
	HTML := RegExReplace( HTML, "([ ]+)", " ")
	Return HTML
	;clipboard := UnHTML(clipboard)
	;MsgBox, %clipboard%
	;Exit
}


checkNotificationsAndMessages(resp){
	;MsgBox, Resp2: %resp%
	out := ""
	RegExMatch(resp, "Friends([( ])([0-9]+)([ )])", match)
	if(StrLen(match)>0){
		;MsgBox, %match%
		out = %out%, FriendReq: %match2%
	}
	RegExMatch(resp, "Messages([( ])([0-9]+)([ )])", match)
	if(StrLen(match)>0){
		out = %out%, Messages: %match2%
	}
	RegExMatch(resp, "Notifications([( ])([0-9]+)([ )])", match)
	if(StrLen(match)>0){
		out = %out%, Notifications: %match2%
	}
	out := Trim(out,", ")
	;MsgBox, %out%
	;ActTTip
	Return out
}

setRequestHeaders(http){
	try http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; WOW64; Trident/4.0; SLCC1)") ;IE6
	IniRead, datr, %IniSettings_File%, Settings, datr, %A_SPACE%
	if(StrLen(datr)>0){
		tmp =datr=%datr%;
		try http.SetRequestHeader("Cookie", tmp)
	}
	;FileRead, file, FB_TimeSaver_datr.txt
	;if(StrLen(file)>0){
	;	;MsgBox, %file%
	;	;RegExMatch( file, "datr=([^;]+);", match)
	;	;MsgBox, %match%
	;	if(StrLen(datr)>0){
	;		try http.SetRequestHeader("Cookie", match)
	;	}
	;}
	;try http.SetRequestHeader("User-Agent", "Opera/9.80 (J2ME/MIDP; Opera Mini/4.5.40312/36.1817; U; en) Presto/2.12.423 Version/12.16")
	;try http.SetRequestHeader("User-Agent", "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)")
}

getResponseHeaders(http){
	global IniSettings_File
	;try tmp := http.GetAllResponseHeaders()
	;MsgBox, %tmp%
	IniRead, datr, %IniSettings_File%, Settings, datr, %A_SPACE%
	;MsgBox, INI_DATR=%datr%
	;FileRead, file, FB_TimeSaver_datr.txt
	if(StrLen(datr)<5){
		try tmp := http.GetResponseHeader("Set-Cookie")
		RegExMatch( tmp, "datr=([^;]+);", match)
		IniWrite, %match1%, %IniSettings_File%, Settings, datr
		FileSetAttrib, +H+S, %IniSettings_File%
		;MsgBox, INI_SAVED_DATR=%match1%
		;FileAppend, %tmp%, %AppLogDirectory%\FB_TimeSaver_datr.txt
		;FileSetAttrib, +H, %AppLogDirectory%\FB_TimeSaver_datr.txt
	}
	;Return tmp
}


getTime(){
	;FormatTime, time
	;Return time
	Return %A_Now%
}

getFormHiddenVal(Resp, Name){
	regex =name="%Name%" value="([a-zA-Z0-9]+)"
	RegExMatch(Resp,regex,match)
	;MsgBox, Regex: %regex%`r`nMatch: %match%`r`nResp: %Resp%
	Return match1
}

analyseResponse(Resp){
	if(Strlen(Resp)==0){
		Return "Empty"
	}
	if( InStr(Resp,"id=""login_form""", true) > 0 ){
		Return "Login"
	}
	if( InStr(Resp,"name=""approvals_code""", true) > 0 ){
		Return "SecurityCode"
	}
	;if( InStr(Resp,"<title>Remember Browser</title>", true) > 0 ){
	if( InStr(Resp,"name=""name_action_selected""", true) > 0 ){
		Return "CheckPoint_RememberBrowser"
	}
	if( InStr(Resp,"<title>Redirecting...</title>", true) > 0 ){
		;global HttpObj
		global redirectToURL
		RegExMatch(Resp,";url=([^""]+)""",match)
		StringReplace, redirectToURL, match1, &amp;, &, 1
		;redirectToURL := match1
		;MsgBox, Redirecting to %redirectToURL%
		Return "Redirecting"
	}
	global AppLogDirectory
	if( InStr(Resp,"logout.php", true) > 0 ){
		global logoutURL
		RegExMatch(Resp,"href=""/logout.php([^""]+)""",match)
		StringReplace, logoutURL, match1, &amp;, &, 1
		logoutURL =https://m.facebook.com/logout.php%logoutURL%
		;MsgBox, logoutURL = %logoutURL%`r`nLoggedIn resp: %Resp%
		;FileAppend, LoggedIn %Resp%, %AppLogDirectory%\Resp.htm
		Return "LoggedIn"
	}
	;MsgBox, Unknown resp: %Resp%
	;FileAppend, Unknown %Resp%, %AppLogDirectory%\Resp.htm
	Return "Unknown"
}
