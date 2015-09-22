TrayTip() {
	static Version	
	;auto_version
	
	txt := "DV Screen Printer " (Version ? "v" Version " ":"") (A_IsAdmin ? "(Admin) ":"") "`n"
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		txt .= hk.text ? "<" ConvertHotkey(hk.text) "> - " ea.description "`n" : ""
	txt .= "`nD-Click Icon: " s.ea("//trayclick").default
	Menu, Tray, Tip, % txt
}