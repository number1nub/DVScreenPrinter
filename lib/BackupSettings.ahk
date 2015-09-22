BackupSettings(silent:="") {	
	prevBUpath := Format("{1}\{2}", s.get("//backup/@dir", A_ScriptDir), s.get("//backup/@name", TimeStamp() "_DVScreenPrinter.xml"))
	FileSelectFile, backupPath, S 24, %prevBUpath%, Select where the backup should be saved:, Backup File (*.xml;*.bak)
	if (ErrorLevel || !backupPath || backupPath=s.file)
		return
	if (FileExist(backupPath))
		FileDelete, %backupPath%
	SplitPath, backupPath, oName, oDir
	s.add2("backup", {dir:oDir, name:oName, time:TimeStamp("yyyyMMddHHmmss")})
	s.save(1)
	FileCopy, % s.file, %backupPath%, 1
	if (ErrorLevel || !FileExist(backupPath))
		return
	if (!silent)
		m(RegExReplace(A_ScriptName, "\.(ahk|exe)\s*$") " settings file successfully exported", "ico:i")
	return 1
}