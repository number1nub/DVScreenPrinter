RegisterHotkeys() {
	while hk:=s.sn("//hotkeys/cmd").item(A_Index-1), ea:=s.ea(hk)
		Hotkeys(hk.text, ea.name, "!DV Screen Printer Options")	
}