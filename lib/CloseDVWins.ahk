CloseDVWins() {
	WinGet, ID, List	
	Loop, %ID% {
		ID := ID%A_Index%
		WinGetTitle, Title, ahk_id %ID%			
		if RegExMatch(title, "TerraVici DataViewer \d+\.\d+")
			WinClose, ahk_id %id%
	}
}