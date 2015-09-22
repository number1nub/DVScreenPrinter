RegisterHotkeys() {
	while hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=s.ea(hk)
		Hotkeys(hk.text, ea.name, "!DV Screen Printer Options")
}