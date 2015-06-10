TrayMenu() {
	Menu, DefaultAHK, Add
	Menu, DefaultAHK, Delete
	Menu, DefaultAHK, Standard
	Menu, Tray, NoStandard
	Menu, Tray, Add, Edit Settings, EditSettings
	Menu, Tray, Add, Capture Screens, Capture
	Menu, Tray, Add, Open Captures Folder, MenuAction
	Menu, Tray, Add, Close all DV Windows, MenuAction
	Menu, Tray, Add
	Menu, Tray, Add, Backup/Export Settings, MenuAction
	Menu, Tray, Add, Import Settings from File, MenuAction
	;Menu, Tray, Add, Open Captures Folder, MenuAction
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :DefaultAHK
	}
	Menu, Tray, Add
	Menu, Tray, Add, Check for Update, CheckForUpdate
	Menu, Tray, Add
	Menu, Tray, Add, Reload
	Menu, Tray, Add, Exit
	Menu, Tray, Default, % s.ssn("//trayclick/@default").text
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else {
		if (!FileExist(ico:=A_ScriptDir "\DVScreenPrinter.ico"))
			URLDownloadToFile, http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.ico, %ico%
		Menu, Tray, Icon, % FileExist(ico) ? ico : ""
	}
	TrayTip()
}