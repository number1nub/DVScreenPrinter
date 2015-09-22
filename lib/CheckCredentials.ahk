CheckCredentials(info:="") {
	if (!A_IsAdmin) {
		if (info != "admin") {
			Run, *runas "%A_ScriptFullPath%" admin
			ExitApp
		}
		ans := CMBox("Currently NOT running with admin privileges...`n`nAttempt to re-launch as admin?", "Yes, Reload as Admin|No, Continue|Cancel && Exit", {ico:"?"})
		if (Instr(ans, "Exit"))
			ExitApp
		else if (InStr(ans, "Yes,")) {
			Run, *RunAs "%A_ScriptFullPath%" admin
			ExitApp
		}
		return
	}
	return 1
}