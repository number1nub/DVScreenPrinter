ImportSettings() {
	IniRead, lastBUDir, %strIniFile%, Backup, BackupDir, % ""
	IniRead, lastBUName, %strIniFile%, Backup, BackupName, % ""
	lastBUDir := s.ssn("//backup/@dir").text
	lastBUName := s.ssn("//backup/@name").text
	Gui +OwnDialogs
	FileSelectFile, loadPath, 3, % lastBUDir (lastBUName ? "\" lastBUName : ""), Select file to be imported:, Menu Backup (*.xml;*.bak)
	if (ErrorLevel || !FileExist(loadPath))
		return
	if (m("Would you like to backup your current settings file before importing?", "ico:?") = "Yes") {
		if (!BackupSettings(1))
			if (m("File backup failed...`n`nContinue with import anyway?", "ico:!") = "NO")
				return
	}
	FileMove, % s.file, % s.file ".bak", 1
	FileCopy, %loadPath%, % s.file, 1
	if (ErrorLevel) {
		if (!FileExist(strIniFile)) {
			FileCopy, % s.file ".bak", % s.file, 1
			return
		}
	}
	m("Settings successfully imported from " loadPath, "ico:i")
	Reload()
}