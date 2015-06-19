CheckCredentials(attempts:="", silent:="") {
	if (!A_IsAdmin) {
		if (!attempts && silent) {
			Run, *runas "%A_ScriptFullPath%" 1
			ExitApp
		}
		else if (attempts) {
			ans := CMBox("Currently NOT running with admin privileges...`n`nAttempt to re-launch with administrator privileges?"
				   , "Yes, Reload as Admin|No, Continue|Cancel && Exit", {ico:"i"})
		}
		if (Instr(ans, "No, Continue"))
			return
		else if (InStr(ans, "Yes, Reload"))
			Run *RunAs "%A_ScriptFullPath%" 1
		ExitApp
	}
}