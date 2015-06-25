TrayTip() {
	txt := StrReplace("DV Screen Printer v;auto_version " (A_IsAdmin?"(admin) ":"") "is running...`n`n", "Version=")
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		txt .= "<" ConvertHotkey(hk.text) "> - " ea.description "`n"
	txt .= "`nD-Click Icon: " s.ea("//trayclick").default
	Menu, Tray, Tip, % txt
}