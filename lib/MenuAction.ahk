MenuAction(){
	if (A_ThisMenuItem = "Open Captures Folder") {
		dir := ReplaceTags(s.ssn("//save/@dir").text)
		Run, explore "%dir%"
	}
	else if (A_ThisMenuItem = "Backup/Export Settings") {
		BackupSettings()
	}
	else if (A_ThisMenuItem = "Import Settings from File") {
		ImportSettings()
	}
}