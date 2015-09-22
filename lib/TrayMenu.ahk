TrayMenu() {
	Menu, AhkStdMenu, Add
	Menu, AhkStdMenu, Delete
	Menu, AhkStdMenu, Standard
	Menu, Tray, NoStandard
	
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		Menu, Tray, Add, % ea.description (hk.text ? "`t(" ConvertHotkey(hk.text) ")" : ""), % ea.name
	
	Menu, Tray, Add
	Menu, Tray, Add, Export Settings to File, BackupSettings
	Menu, Tray, Add, Import Settings from File, ImportSettings
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :AhkStdMenu
	}
	Menu, Tray, Add
	Menu, Tray, Add, Check for Update, CheckForUpdate
	Menu, Tray, Add
	Menu, Tray, Add, Reload
	Menu, Tray, Add, Exit
	
	tDefault   := s.ssn("//trayclick/@default").text
	tDefaultHK := s.ssn("//hotkeys/cmd[@description='" tDefault "']").text
	Menu, Tray, Default, % tDefault (tDefaultHK ? "`t(" ConvertHotkey(tDefaultHK) ")" : "")
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else {
		if (!FileExist(ico:=A_ScriptDir "\DVScreenPrinter.ico"))
			URLDownloadToFile, http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.ico, %ico%
		Menu, Tray, Icon, % FileExist(ico) ? ico : ""
	}
	TrayTip()
}