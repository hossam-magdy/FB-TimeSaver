# FB-TimeSaver
An AutoHotKey script that periodically checks facebook account for any new messages, friend requests or notifications and notifies the user by desktop tooltip and/or sound.

toDo
=====================
- Detect wrong login attempt & reask the for user & pass (even if saved / dev_user is used)
- Ask to save user & pass ONLY after successful login
- ~ At saving credentials: auto-save user/email, but ask for pass
- Logout option : (logoutURL) var is ready
- Option to alert at which of the three (Notif, Messages, FriendReq)
- ~ Option of Notification ACKNOWLEDGMENT
- More than one login simultaneously (SingleInstance OFF)
- xXx Use "Microsoft.XmlHttp" OR "InternetExplorer.Application" instead of "WinHttp.WinHttpRequest"
	if (window.XMLHttpRequest) var http = new XMLHttpRequest();
	else var http = new ActiveXObject("microsoft.xmlhttp");
	// OR ComObjCreate("InternetExplorer.Application")
- (done) Option/Ask to save user+pass for future logins
- (done) Extract INTEGER of Notif, Messages, FriendReq
- (done) Alert for the only INCREMENT of notifications, not decrement
