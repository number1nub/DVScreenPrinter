TrayTip() {
	Menu, Tray, Tip, % StrReplace("DV Screen Printer v;auto_version " (A_IsAdmin?"(admin) ":"") "is running...`n`n", "Version=")
		 . "<" ConvertHotkey(s.ssn("//hotkeys/cmd[@name='Capture']").text) "> to capture screens`n"
		 . "<" ConvertHotkey(s.ssn("//hotkeys/cmd[@name='EditSettings']").text) "> to open settings`n`n"
		 . "D-Click icon: " s.ssn("//trayclick/@default").text
}