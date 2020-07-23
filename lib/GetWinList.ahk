GetWinList() {
	winList:=[], TMM:=A_TitleMatchMode
	filter := "(?P<Name>.+?)(?: - TerraVici DataViewer)? - (?P<File>.+)"
	ignore := "TerraVici DataViewer \d+\.\d+'"
	SetTitleMatchMode, Regex
	WinGet, ID, List, ahk_class HwndWrapper\[DataViewer\.exe
	Loop, % ID {
		this := ID%A_Index%
		WinGetTitle, Title, ahk_id %this%
		if (RegExMatch(Title, "i)" filter, m) && !RegExMatch(title, ignore)) {
			SplitPath, mFile,, fDir,, fName
			winList[A_Index] := {title:Title, id:this, name:mName, filepath:mFile, filename:fName, filedir:fDir}
			GroupAdd, DVWins, ahk_id %this%
		}
	}
	SetTitleMatchMode, %TMM%
	return winList
}