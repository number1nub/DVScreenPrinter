TrayMenu() {
	Menu, AhkStdMenu, Add
	Menu, AhkStdMenu, Delete
	Menu, AhkStdMenu, Standard
	Menu, Tray, NoStandard
	
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		Menu, Tray, Add, % ea.description "`t(" ConvertHotkey(hk.text) ")", % ea.name ;#[TODO: Change hotkey CMD descriptions & tray default actions to match]
	
	;~ Menu, Tray, Add, Edit Settings, EditSettings
	;~ Menu, Tray, Add, Capture Screens, Capture
	;~ Menu, Tray, Add, Open Captures Folder, MenuAction
	;~ Menu, Tray, Add
	;~ Menu, Tray, Add, Close all DV Windows, MenuAction
	Menu, Tray, Add
	Menu, Tray, Add, Export Settings to File, MenuAction
	Menu, Tray, Add, Import Settings from File, MenuAction
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :AhkStdMenu
	}
	Menu, Tray, Add
	Menu, Tray, Add, Check for Update, CheckForUpdate
	Menu, Tray, Add
	Menu, Tray, Add, Reload
	Menu, Tray, Add, Exit
	tDefault := s.ssn("//trayclick/@default").text
	Menu, Tray, Default, % tDefault "`t(" ConvertHotkey(s.ssn("//hotkeys/cmd[@description='" tDefault "']").text) ")"
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else {
		if (!FileExist(ico:=A_ScriptDir "\DVScreenPrinter.ico"))
			URLDownloadToFile, http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.ico, %ico%
		Menu, Tray, Icon, % FileExist(ico) ? ico : ""
	}
	TrayTip()
}