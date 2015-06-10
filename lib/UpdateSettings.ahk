UpdateSettings() {	
	extList := "JPG,GIF,PNG,BMP,TIFF"
	tkList := "Edit Settings|Capture Screens|Close all DV Windows"	
	
	; Extensions
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
	
	s.save(1)
}