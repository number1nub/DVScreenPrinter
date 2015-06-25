UpdateSettings() {
	static Version
	
	extList := "JPG,GIF,PNG,BMP,TIFF"
	tkList := "Open Settings Editor|Capture DV Screens|Close all DV Windows"
	hkList := {Capture:"Capture DV Screens"
			 , EditSettings:"Open Settings Editor"
			 , CloseDVWins:"Close all DV Windows"}
	
	;Extensions
	if (s.sn("//options/extensions/*").Length != StrSplit(extList, ",").MaxIndex()) {
		exts := s.ssn("//options/extensions")
		exts.ParentNode.RemoveChild(exts)
		opts:=s.ssn("//options"), exts:=s.under(opts, "extensions")
		for c, v in StrSplit(extList, ",")
			s.under(exts, "ext",, v)
	}
	;TrayClick
	if (s.ssn("//trayclick").text != tkList)
		s.ssn("//trayclick").text := tkList
	tDefault:=s.ssn("//trayclick/@default").text
	if tDefault not in % StrReplace(tkList, "|", ",")
		s.ssn("//trayclick/@default").text := StrSplit(tkList,"|")[1]
	;Hotkeys
	curHks:=[]
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk) {
		curHks[ea.name] := hk.text
		if (!ea.description || ea.description != hkList[ea.name])
			s.ssn("//hotkeys/cmd[@name='" ea.name "']/@description").text := hkList[ea.name]			 
	}
	
	;GUI Style
	if (!s.ssn("//style/header/@size").text) {
		style := s.add2("style", {background:"F5F5F5", control:"White", color:"Blue", font:"Segoe UI"})
		s.under(style, "header", {size:10})
		s.under(style, "label", {size:8})
	}
	s.save(1)
}