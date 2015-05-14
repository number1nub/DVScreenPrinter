BackupSettings(silent:="") {
	FormatTime, tstamp, %A_Now%, yyyy-MM-dd H
	lastBUDir := 
	lastBUName := 
	FileSelectFile, backupPath, S 24, % Format("{1}\{2}", s.get("//backup/@dir", A_ScriptDir), s.get("//backup/@name", tstamp "_DVScreenPrinter.xml"))
				  , Select where the backup should be saved:, Backup File (*.xml;*.bak)
	if (ErrorLevel || !backupPath || backupPath=s.file)
		return
	if (FileExist(backupPath))
		FileDelete, %backupPath%
	SplitPath, backupPath, oName, oDir
	FormatTime, tstamp, %A_Now%, yyyy-MM-dd HH:mm:ss
	s.add2("backup", {dir:oDir, name:oName, time:tstamp})
	s.save(1)
	FileCopy, % s.file, %backupPath%, 1
	if (ErrorLevel || !FileExist(backupPath))
		return
	if (!silent)
		m(A_ScriptName " settings file successfully exported", "ico:i")
	return 1
}