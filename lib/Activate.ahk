Activate(win="A", wait="", timeout:=2, silent:="") {
	if (WinExist(wName:="ahk_id " win))
		WinActivate, %wName%
	else if (WinExist(wName:=win))
		WinActivate, %wName%
	if (wait) {
		WinWaitActive, %wName%,, % timeout
		if (ErrorLevel && !silent)
			m("Couldn't activate window:", wName, "ico:!")
	}
}