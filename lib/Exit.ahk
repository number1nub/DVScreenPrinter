Exit(reason, code:="", noSave:="") {
	if (code && !noSave)
		s.save(1)
	ExitApp
}