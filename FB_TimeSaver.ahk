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
;- Logout option : (logoutURL) var is ready
;- Get # of Not,Mes,Fr & operate based on it
;- xXx Use "Microsoft.XmlHttp" OR "InternetExplorer.Application" instead of "WinHttp.WinHttpRequest"
;if (window.XMLHttpRequest) var http = new XMLHttpRequest();
;else var http = new ActiveXObject("microsoft.xmlhttp");
; OR ComObjCreate("InternetExplorer.Application")
;*******

;Restart:
Menu, TRAY, Icon, *, 1, 1

DEBUG						:= 0
IsDeveloper					:= 0		; can login automatically with developer's credentials inserted below
dev_mail					:= "mail@example.com"
dev_pass					:= "mail_pass"
IniSettings_File			:= A_ScriptDir . "\FB_TimeSaver.ini"
Version						:="1.20161228"

Alert_Sound					:= loadValueFromINI("Alert_Sound", "Settings", "0")
Alert_TrayTip				:= loadValueFromINI("Alert_TrayTip", "Settings", "1")
Alert_TrayIcon				:= loadValueFromINI("Alert_TrayIcon", "Settings", "1")
CheckEvery					:= loadValueFromINI("CheckEvery", "Settings", "30")
Notify_Sound				:= loadValueFromINI("Notify_Sound", "Settings", "FB_TimeSaver_SoundNotify.wav")
Notify_Icon					:= loadValueFromINI("Notify_Icon", "Settings", ".\ICON_alert.ico")

AppLogDirectory				:= A_ScriptDir
AskRememberBrowser			:= 1
deviceSavedAsRecognized		:= -1 ; Default value (-1: no dev recog , 0: dev not saved , 1: dev saved)
lastCheck					:= 0

TrayTipDefault				:= "FB Time Saver"
;TimeFormat					:= DEBUG ? "hh:mm:sstt" : "hh:mmtt"
TimeFormat					:= DEBUG ? "HH:mm:ss" : "HH:mm"
DateFormat					:= "ddd yyyy-MM-dd"
DateTimeFormat				:= DateFormat . " " . TimeFormat
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
;global vars:	logoutURI, method, action, query, redirectToURL, email, num_Notifications, num_Messages, num_Friends, 

CheckLogIn:
response_text:=requestTEST("GET", "https://mbasic.facebook.com/")
while(Not isLoggedIn(response_text)){
	analyzeResponse(response_text)
	response_text:=requestTEST(method, action, query)
}
response_text =  ;
method =  ;
action =  ;
query =  ;
Goto, LoggedIn
if(DEBUG)
	MsgBox, LOGGED-IN
;ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; SIGNING IN - SECURITY CHECKS - REDIRECTS ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoggedIn:
NotMesOld := ""

;SetTimer, Check, 15000

setMenuItems()
Goto, SkipMenuHandler
MenuHandler:
menuHandler()
;Goto, Check
SkipMenuHandler:

num_Notifications:=0
num_Messages:=0
num_Friends:=0
check(){
	global DEBUG
	global num_Notifications
	global num_Messages
	global num_Friends
	global num_Notifications_old
	global num_Messages_old
	global num_Friends_old
	global ToolTipMes
	global CheckEvery
	global NotMes
	global Notify_Icon
	global Alert_TrayIcon
	global Alert_TrayTip
	global Alert_Sound
	global TimeFormat
	global email
	NotMes := ""
	FormatTime, TimeNow, , %TimeFormat%
	if(DEBUG)
		MsgBox, % "Friends:" . num_Friends . ", Messages:" . num_Messages . ", Notifications:" . num_Notifications
	Resp := requestTEST("GET","https://mbasic.facebook.com/settings")
	num_Notifications_old:=num_Notifications
	num_Messages_old:=num_Messages
	num_Friends_old:=num_Friends
	updateNumbers(Resp)
	if(DEBUG)
		MsgBox, % "Friends:" . num_Friends . ", Messages:" . num_Messages . ", Notifications:" . num_Notifications
	if(num_Friends>num_Friends_old)
		NotMes := NotMes . ", Friends:" . num_Friends
	if(num_Messages>num_Messages_old)
		NotMes := NotMes . ", Messages:" . num_Messages
	if(num_Notifications>num_Notifications_old)
		NotMes := NotMes . ", Notifications:" . num_Notifications
	NotMes := Trim(NotMes, ", ")
	if( StrLen(NotMes)>0 ){
		if( Alert_Sound ){
			SoundPlay, %Notify_Sound%
		}
		if( Alert_TrayTip ){
			TrayTip, %email%, %NotMes%, 15, 1
		}
		Sleep, ( 1000 )
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ToolTipMes := "@" . TimeNow . "`r`n" . "Friends:" . num_Friends . ", Messages:" . num_Messages . ", Notifications:" . num_Notifications
	Menu, TRAY, Tip , %email% %ToolTipMes%
	
	if( Alert_TrayIcon ){
		if( StrLen(NotMes)>0 )
			if(FileExist(Notify_Icon))
				Menu, TRAY, Icon, %Notify_Icon%, 1, 1
			else
				Menu, TRAY, Icon, %A_ScriptFullPath%, 2, 1
		else
			Menu, TRAY, Icon, *, 1, 1
	}
	
	Sleep, ( CheckEvery*1000 )
	
}

CheckLoop:
; the INFINITE LOOP
while(1){
	check()
}

~LWin & ~LShift::
	;ToolTip, Checking ..., 0, 0
	;Sleep, ( 1000 )
	;MsgBox, Here1
	;Tips:
	;MsgBox, Here2
	;if(GetKeyState("LCtrl")==1 && GetKeyState("LShift")==1 && GetKeyState("LAlt")==1){
	;}
	show_fbStatus()
	;check()
	;ToolTip
	;Goto, Check
Return


Goto, CheckLoop
Exit:
ExitApp


Sleeper( min ) {
	Loop, min
	{
		Sleep, 1000
	}

}

show_fbStatus() {
	global ToolTipMes
	global TimeNow
	global email
	TrayTip, %email%, %ToolTipMes%, 15, 1
	;ToolTip, %ActToolTipF%, 0, 0
	Sleep, 500
	;Goto, Tips
}

updateNumbers(resp){
	global num_Notifications
	global num_Friends
	global num_Messages
	
	RegExMatch(resp, "<a(?:[^>]*)href=""\/notifications(?:.*?)Notifications(?:(?:[\(| ]+)([0-9]+)(?:[\)| ]+)|)(?:.*?)<\/a>", match)
	num_Notifications := Format("{:u}", match1)
	;MsgBox, num_Notifications: %num_Notifications%

	RegExMatch(resp, "<a(?:[^>]*)href=""\/friends(?:.*?)Friends(?:(?:[\(| ]+)([0-9]+)(?:[\)| ]+)|)(?:.*?)<\/a>", match)
	num_Friends := Format("{:u}", match1)
	;MsgBox, num_Friends: %num_Friends%

	RegExMatch(resp, "<a(?:[^>]*)href=""\/messages(?:.*?)Messages(?:(?:[\(| ]+)([0-9]+)(?:[\)| ]+)|)(?:.*?)<\/a>", match)
	num_Messages := Format("{:u}", match1)
	;MsgBox, num_Messages: %num_Messages%

	out =Friends: %num_Friends%, Messages: %num_Messages%, Notifications: %num_Notifications%
	out := Trim(out,", ")
	;MsgBox, %out%
	;ActTTip
	Return out
}

setRequestHeaders(http){
	global IniSettings_File
	try http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; WOW64; Trident/4.0; SLCC1)") ;IE6
	;datr := loadValueFromINI("datr")
	cookie := loadValueFromINI("cookie")
	try http.SetRequestHeader("Cookie", cookie)
	;if(StrLen(datr)>0){
	;	tmp =datr=%datr%;
	;	try http.SetRequestHeader("Cookie", tmp)
	;}
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
	global DEBUG
	;try tmp := http.GetAllResponseHeaders()
	;MsgBox, %tmp%
	;datr := loadValueFromINI("datr")
	;IniRead, datr, %IniSettings_File%, Settings, datr, %A_SPACE%
	;MsgBox, INI_DATR=%datr%
	;FileRead, file, FB_TimeSaver_datr.txt
	cookie := ";" . Trim(loadValueFromINI("cookie"), "; ") . ";"
	try allHeaders := http.getAllResponseHeaders()
	if(DEBUG)
		MsgBox, http.getAllResponseHeaders = %tmp%
	regex =Set-Cookie: (.*?)=(.*?);
	match_cookie:=""
	Pos:=1
	While (Pos := RegExMatch(allHeaders,regex,match_cookie, Pos + StrLen(match_cookie)))
	{
		if(InStr(cookie, match_cookie1)){
			if(match_cookie2="deleted")
				cookie := RegExReplace( cookie, ";" . match_cookie1 . "=(.*?);", ";")
			else
				cookie := RegExReplace( cookie, ";" . match_cookie1 . "=(.*?);", ";" . match_cookie1 . "=" . match_cookie2 . ";")
		}
		else
			cookie:=cookie . "" . match_cookie1 . "=" . match_cookie2 . ";"
	}
	cookie := Trim(cookie, "; ")
	saveValueToINI("cookie", cookie)
	
	if(DEBUG)
		MsgBox, COOKIES = %cookie%
	;if(StrLen(datr)<5){
	;	try tmp := http.GetResponseHeader("Set-Cookie")
	;	;MsgBox, http.GetResponseHeader = %tmp%
	;	RegExMatch( tmp, "datr=([^;]+);", match)
	;	saveValueToINI("datr", match1)
	;	;MsgBox, INI_SAVED_DATR=%match1%
	;	;FileAppend, %tmp%, %AppLogDirectory%\FB_TimeSaver_datr.txt
	;	;FileSetAttrib, +H, %AppLogDirectory%\FB_TimeSaver_datr.txt
	;}
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

getAttrVal(HTMLCode, attrName){
	regex =%attrName%="(.*?)"
	RegExMatch(HTMLCode,regex,match)
	;MsgBox, Regex: %regex%`r`nMatch: %match%`r`nResp: %Resp%
	Return match1
}

analyzeResponse(Resp){
	;MsgBox, Resp: %Resp%
	global method
	global action
	global query
	query:=""
	
	Pos := RegExMatch(Resp,"<form(.*?)>(.*?)<\/form>",match_form)
	method:=Format("{:U}", getAttrVal(match_form, "method"))
	action:=getAttrVal(match_form, "action")
	start_of_action := SubStr(action, 1, InStr(action, "/"))
	if( start_of_action="/" )
		action:="https://mbasic.facebook.com" . action
	;else
	;	action:=action
	;else if( start_of_action="https:/" Or start_of_action="http:/" )
	;	action:=action

	
	regex =<input(.*?)>
	match_input:=""
	Pos:=1
	While (Pos := RegExMatch(match_form,regex,match_input, Pos + StrLen(match_input)))
	{
		;MsgBox, INPUT: %match_input%
		name:=getAttrVal(match_input, "name")
		type:=Format("{:L}", getAttrVal(match_input, "type"))
		value:=getAttrVal(match_input, "value")
		if( name="email" ){
			if(IsDeveloper){
				value := dev_mail
			}else{
				value:=loadValueFromINI("email")
				if(Not StrLen(value)>0){
					InputBox, value,Login , Username`, Email or Phone, , InputBoxWidth, InputBoxHeight, , , , 30
					MsgBox, 4, Remember account ?, Remember account email/username for future logins ?`r`n(Recommended), 3
					IfMsgBox, Yes
						saveValueToINI("email", value)
					IfMsgBox, Timeout
						saveValueToINI("email", value)
				}
			}
			global email
			email := value
		}else if( name="pass" ){
			if(IsDeveloper){
				value := dev_pass
			}else{
				value:=loadValueFromINI("pass")
				if(Not StrLen(value)>0){
					InputBox, value, Login, Password, HIDE, InputBoxWidth, InputBoxHeight, , , 
					MsgBox, 4, Remember password ?, Remember password for future logins ?`r`n(Choose No: if on shared computer), 10
					IfMsgBox, Yes
						saveValueToINI("pass", value)
					IfMsgBox, Timeout
						saveValueToINI("pass", value)
				}
			}
			
		}else if( name="approvals_code" ){
			InputBox, value, Security Code, Security Code is required :, , InputBoxWidth, InputBoxHeight
		}else{
			if( type="text" )
				InputBox, value, User input required, %name% :, , InputBoxWidth, InputBoxHeight
			if( type="password" )
				InputBox, value, User input required, %name% :, HIDE , InputBoxWidth, InputBoxHeight
		}
		;MsgBox, %name% %type% %value%
		if( Not (type="submit" AND InStr(query, "&submit")>0) And Not InStr(query, "&" . name . "=")>0 ){ ; add only the first "submit" input
			query:=query . "&" name . "=" value
		}
	}
	;MsgBox, QUERY: %query%

	; if(AskRememberBrowser){
	; 	MsgBox, 4, FB Time Saver, Remember {FB TimeSaver} such that`r`nyou do not have to enter security code again ?, 60
	; 	IfMsgBox Yes
	; 	{
	; 		name_action_selected := "save_device"
	; 		deviceSavedAsRecognized := 1
	; 	}
	; 	IfMsgBox Timeout
	; 	{
	; 		name_action_selected := "save_device"
	; 		deviceSavedAsRecognized := 1
	; 	}
	; 	IfMsgBox No
	; 	{
	; 		name_action_selected := "dont_save"
	; 		deviceSavedAsRecognized := 0
	; 	}
	; }else{
	; 	name_action_selected := "save_device"
	; }

	; For the case of selecting a phone
	regex =<select(.*?)\/select>
	match_select:=""
	Pos:=1
	While (Pos := RegExMatch(match_form,regex,match_select, Pos + StrLen(match_select)))
	{
		name:=getAttrVal(match_select, "name")
		RegExMatch(match_select,"<option(.*?)selected(.*?)>",match_option)
		value:=getAttrVal(match_option, "value")
		query:=query . "&" name . "=" value
		;MsgBox, match_option: %match_option%, match_option_val: %match_option_val1%
	}
	
	
	;MsgBox, QUERY: %query%
	;MsgBox, END
	;ExitApp
}

saveValueToINI(name, value, section="Settings"){
	global IniSettings_File
	IniWrite, %value%, %IniSettings_File%, %section%, %name%
	FileSetAttrib, +H+S, %IniSettings_File%
}

loadValueFromINI(name, section="Settings", default=" "){
	global IniSettings_File
	IniRead, value, %IniSettings_File%, %section%, %name%, %default%
	;MsgBox, %value%
	Return value
}

requestTEST(method, URI, body=""){
	global DEBUG
	if(DEBUG){
		;clipboard:=Resp
		MsgBox, METHOD: %method%`r`nURI: %URI%`r`nBODY: %body%
	}
	global HttpObj
	HttpObj.Open(Format("{:U}", method), URI)
	setRequestHeaders(HttpObj)
	try HttpObj.Send(body)
	getResponseHeaders(HttpObj)
	try Resp := HttpObj.ResponseText
	Resp := cleanHTML(Resp)
	if(DEBUG){
		;clipboard:=Resp
		MsgBox, Resp: %Resp%
	}
	Return Resp
}

isLoggedIn(Resp){
	if( InStr(Resp,"logout.php", true) > 0 ){
		global logoutURI
		RegExMatch(Resp,"href=""/logout.php(.*?)""",match)
		;StringReplace, logoutURI, match1, &amp;, &, 1
		logoutURI =https://mbasic.facebook.com/logout.php%match1%
		;MsgBox, logoutURL = %logoutURL%`r`nLoggedIn resp: %Resp%
		;FileAppend, LoggedIn %Resp%, %AppLogDirectory%\Resp.htm
		Return true
	}
	Return false
}

cleanHTML( HTML ) {
	;Return HTML
	HTML := RegExReplace( HTML, "(<style(.*?)<\/style>|([`r`n`t]*))|<img(.*?)>|( (id|class|style)=""(.*?)"")|<([\/]*?)(!DOCTYPE|div|span|ul|li|br|table|tbody|tr|td)(.*?)>", "")
	;HTML := RegExReplace( HTML, "<style(.*?)</style>", "")
	;HTML := RegExReplace( HTML, "(<br />|<br>)", "`r`n")
	HTML := StrReplace( HTML, "&amp;", "&")
	HTML := StrReplace( HTML, "&nbsp;", " ")
	;HTML := StrReplace( HTML, "<span", " <span")
	;HTML := StrReplace( HTML, "<div", "<br /><div")
	
	Return HTML
	;clipboard := cleanHTML(clipboard)
	;MsgBox, %clipboard%
	;Exit
}

setMenuItems(){
	global Alert_TrayTip
	global Alert_TrayIcon
	global Alert_Sound
	Menu, TRAY, Tip , %TrayTipDefault%
	Menu, TRAY, NoStandard
	Menu, TRAY, DeleteAll
	Menu, TRAY, Add, About, MenuHandler
	Menu, TRAY, Add, Show status and Recheck, MenuHandler
	Menu, TRAY, Add, Alert: TrayTip , MenuHandler
	if( Alert_TrayTip ){
		Menu, TRAY, Check, Alert: TrayTip
	}
	Menu, TRAY, Add, Alert: TrayIcon, MenuHandler
	if( Alert_TrayIcon ){
		Menu, TRAY, Check, Alert: TrayIcon
	}
	Menu, TRAY, Add, Alert: Sound, MenuHandler
	if( Alert_Sound ){
		Menu, TRAY, Check, Alert: Sound
	}
	Menu, TRAY, Add, Set CheckEvery, MenuHandler
	Menu, TRAY, Add, Reset all, MenuHandler
	Menu, TRAY, Add, Exit, MenuHandler
}

menuHandler(){
	global Alert_TrayIcon
	global Alert_TrayTip
	global Alert_Sound
	global Notify_Sound
	global Notify_Icon
	global CheckEvery
	global Version
	if ( A_ThisMenuItem=="About" ){
		MsgBox, 64, FB Time Saver, { FB Time Saver v%Version% }`r`n`r`n`r`nAre you spending much time browing the facebook news feed or checking if a friend sent you a message ?`r`n`r`nThis desktop software can check your account frequently for you & if you have any Notifications, Messages or FriendRequests it can inform you by:`r`n- TrayTip desktop notification (Hotkey: LeftWin + LeftShift)`r`n- Sound alert`r`n- Tray icon`r`nYou can also switch them off, if you want.`r`n`r`nSave your time (sorry facebook).`r`n`r`n`r`nDeveloped by:`r`nHossam Magdy`r`nhossam.magdy@ieee.org
	} else if ( A_ThisMenuItem=="Show status and Recheck" ){
		show_fbStatus()
	} else if ( A_ThisMenuItem=="Alert: TrayTip" ){
		if( Alert_TrayTip==1 ){
			Alert_TrayTip := 0
			Menu, TRAY, Uncheck, Alert: TrayTip
		}else{
			Alert_TrayTip := 1
			Menu, TRAY, Check, Alert: TrayTip
		}
	} else if ( A_ThisMenuItem=="Alert: TrayIcon" ){
		if( Alert_TrayIcon==1 ){
			Alert_TrayIcon := 0
			Menu, TRAY, Uncheck, Alert: TrayIcon
			Menu, TRAY, Icon, *, 1, 1
		}else{
			Alert_TrayIcon := 1
			Menu, TRAY, Check, Alert: TrayIcon
		}
	} else if ( A_ThisMenuItem=="Alert: Sound" ){
		if( Alert_Sound==1 ){
			Alert_Sound := 0
			Menu, TRAY, Uncheck, Alert: Sound
		}else{
			Alert_Sound := 1
			Menu, TRAY, Check, Alert: Sound
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
			Run, %A_ScriptFullPath%
			;Goto, Restart
		}
		;FileDelete, %LogData_File%
		;Goto, CheckLogIn
	} else if ( A_ThisMenuItem=="Exit" ){
		ExitApp
	}
	saveValueToINI("Alert_Sound", Alert_Sound)
	saveValueToINI("Alert_TrayTip", Alert_TrayTip)
	saveValueToINI("Alert_TrayIcon", Alert_TrayIcon)
	saveValueToINI("CheckEvery", CheckEvery)
	saveValueToINI("Notify_Sound", Notify_Sound)
	saveValueToINI("Notify_Icon", Notify_Icon)
}
