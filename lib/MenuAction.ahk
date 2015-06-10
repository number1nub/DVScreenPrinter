MenuAction(){
	if (A_ThisMenuItem = "Open Captures Folder") {
		dir := Tags(s.ssn("//save/@dir").text, "strip")
		Run, explore "%dir%"
	}
	else if (A_ThisMenuItem = "Close all DV Windows") {	
		WinGet, ID, List	
		Loop, %ID% {
			ID := ID%A_Index%
			WinGetTitle, Title, ahk_id %ID%			
			if RegExMatch(title, "TerraVici DataViewer \d+\.\d+")
				WinClose, ahk_id %id%
		}
	}
	else if (A_ThisMenuItem = "Backup/Export Settings")
		BackupSettings()
	else if (A_ThisMenuItem = "Import Settings from File")
		ImportSettings()
}