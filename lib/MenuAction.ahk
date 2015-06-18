MenuAction(){
	if (A_ThisMenuItem = "Open Captures Folder") {
		dir := Tags(s.ssn("//save/@dir").text, "strip")
		Run, explore "%dir%"
	}
	else if (A_ThisMenuItem = "Close all DV Windows")
		CloseDVWins()
	else if (A_ThisMenuItem = "Backup/Export Settings")
		BackupSettings()
	else if (A_ThisMenuItem = "Import Settings from File")
		ImportSettings()
	else
		m("Not yet implemented...", "ico:i")
}