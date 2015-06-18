GetWinList(filter="", ignore="") {
	winList:=[]
	filter := filter ? filter : "(?P<Name>.+) - TerraVici DataViewer - (?P<File>.+)"
	Ignore := ignore ? ignore : "TerraVici DataViewer \d+\.\d+"
	WinGet, ID, List
	Loop, % ID {
		ID:=ID%A_Index%
		WinGetTitle, Title, ahk_id %ID%
		if (RegExMatch(Title,"i)" filter, m) && !RegExMatch(Title, ignore)) {
			SplitPath, mFile,, fDir,, fName
			winList.Push({title:Title, id:id, name:mName, filepath:mFile, filename:fName, filedir:fDir})
			GroupAdd, DVWins, ahk_id %ID%
		}
	}
	return winList
}