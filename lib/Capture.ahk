Capture() {
	wList := GetWinList("(?P<Name>.+) - TerraVici DataViewer - (?P<File>.+)")
	if (wList.MaxIndex() < 1)
		return m("No DataViewer chart windows found!", "ico:!")
	
	BL:=A_BatchLines, save:=s.ea("//save"), opts:=s.ea("//options")
	SetBatchLines, -1
	If (!pToken := Gdip_Startup()) {
		m("GDIPlus Failed to start!", "Please ensure that gdiplus.dll is on your system.", "title:GDIPlus Error", "ico:!")
		ExitApp
	}
	WinRestore, ahk_group DVWins
	for c, v in wList {
		if (!FileExist(sDir:=Tags(save.dir, v)))
			FileCreateDir, %sDir%
		if (FileExist(fName:=sDir "\" Tags(save.name, v) "." save.ext)) {
			if (!opts.overwrite)
				if (m("Overwrite existing file """ fName """?", "(You can disable this prompt in settings)", "btn:yn", "ico:?") != "YES")
					continue
			FileDelete, %fName%
		}
		pBitmap := Gdip_BitmapFromHWND(v.id)
		Gdip_SaveBitmapToFile(pBitmap, fName)
		Gdip_DisposeImage(pBitmap)
	}
	Gdip_Shutdown(pToken)
	if (opts.closeAfterCapture)
		WinClose, ahk_group DVWins
	SetBatchLines, %BL%
	if (m(wList.MaxIndex() " windows captured. " (opts.promptOpenDir ? "Open output folder?`n`n(You can disable this prompt in settings)" : ""), "title:DataViewer Capture Complete!","ico:i", opts.promptOpenDir ? "btn:yn" : "") = "YES")
		Run, % "explore " sDir
}