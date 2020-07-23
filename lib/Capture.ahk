Capture() {
	wList := GetWinList()
	if (wList.MaxIndex() < 1)
		return m("No DataViewer chart windows found!", "ico:!")
	
	BL:=A_BatchLines, save:=s.ea("//save"), opts:=s.ea("//options")
	SetBatchLines, -1
	If (!pToken := Gdip_Startup()) {
		m("GDIPlus Failed to start!", "Please ensure that gdiplus.dll is on your system.", "title:GDIPlus Error", "ico:!")
		ExitApp
	}
	WinRestore, ahk_group DVWins
	winCount := 0
	for c, v in wList {
		if (!FileExist(sDir:=Tags(save.dir, v)))
			FileCreateDir, %sDir%
		if (FileExist(fName:=sDir "\" Tags(save.name, v) "." save.ext)) {
			if (!opts.overwrite) {
				if ((ans:=m("Overwrite existing file?", "`n""" fName """?", "`n<Cancel> will abort capturing.", "`n(You can disable this prompt in settings)", "btn:ync", "ico:?")) = "NO")
					continue
				else if (ans = "CANCEL")
					break
			}
			FileDelete, %fName%
		}
		pBitmap := Gdip_BitmapFromHWND(v.id)
		Gdip_SaveBitmapToFile(pBitmap, fName)
		Gdip_DisposeImage(pBitmap)
		winCount++
	}
	Gdip_Shutdown(pToken)
	SetBatchLines, %BL%
	if (winCount > 0) {
		if (opts.closeAfterCapture)
			WinClose, ahk_group DVWins
		if (m(winCount " of " wList.MaxIndex() " windows captured. " (opts.promptOpenDir ? "Open output folder?`n`n(You can disable this prompt in settings)" : ""), "title:DataViewer Capture Complete!","ico:i", opts.promptOpenDir ? "btn:yn" : "") = "YES")
			Run, % "explore " sDir
	}
}