Restore(win) {
	if (WinExist(wName:="ahk_id " win))
		WinRestore, %wName%
	else if (WinExist(win))
		WinRestore, %win%
}