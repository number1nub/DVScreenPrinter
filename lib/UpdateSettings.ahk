UpdateSettings() {
	static Version
	
	extList := "JPG,GIF,PNG,BMP,TIFF"
	tkList := "Edit Settings|Capture Screens|Close all DV Windows"	
	hkList := {Capture:"Main Capture Hotkey"
			 , EditSettings:"Open Settings Editor"
			 , CloseDVWins:"Close all DV Windows"}
	
	;Extensions
	if (s.sn("//options/extensions/*").Length != StrSplit(extList, ",").MaxIndex()) {
		exts := s.ssn("//options/extensions")
		exts.ParentNode.RemoveChild(exts)
		opts := s.ssn("//options")
		exts := s.under(opts, "extensions")
		for c, v in StrSplit(extList, ",")
			s.under(exts, "ext",, v)
	}
	
	;TrayClick
	if (s.ssn("//trayclick").text != tkList)
		s.ssn("//trayclick").text := tkList
	
	;Hotkeys
	if (!s.ssn("//hotkeys/cmd[1]/@description").text) {
		curHks:=[]
		while hk:=s.sn("//hotkeys/cmd").item[A_Index-1], ea:=s.ea(hk)
			curHks[ea.name]:=hk.text
		hks := s.ssn("//hotkeys"), hks.parentNode.removeChild(hks)
		hks := s.add2("hotkeys")
		for c, v in hkList
			s.under(hks, "cmd", {name:c, description:v}, curHks[c])
	}
	s.save(1)
}