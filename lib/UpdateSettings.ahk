UpdateSettings() {
	;if (s.ssn("//version").text <= 1.9) {	
	; Save & Options
	save := s.ea("//save")
	if (ow:=save.overwrite || prompt:=s.promptOpenDir) {
		m("ues")
		dir:=save.dir, ext:=save.ext, s.remove("//save")
		save := s.add2("save",{dir:dir, ext:Format("{1:U}", ext), name:"$windowName"})
	}
	if (!opts:=s.ea("//options")) {
		opts := s.add2("options", {overwrite:ow, promptOpenDir:prompt})
	}
	else if (!opts.overwrite || !opts.promptOpenDir)
		opts.setAttribute("overwrite", ow), opts.setAttribute("promptOpenDir", prompt)
	
	; Hotkeys
	if (caphk:=s.ea("//hotkey").main) {
		sethk:=s.ea("//hotkey").settings
		s.remove("//hotkey")
		s.add2("hotkeys/cmd", {name:"Capture"}, caphk)
		s.add2("hotkeys/cmd", {name:"EditSettings"}, sethk)
	}
	
	; Extensions
	if (s.ssn("//settings/extensions")) {
		s.remove("//extensions")
		extensions := s.under(opts, "extensions")
		for c, v in ["JPG","GIF","PNG","BMP","TIFF"]
			s.under(extensions, "ext",, v)
	}
	s.ssn("//save").setAttribute("ext", Format("{1:U}", s.ea("//save").ext))
	s.save(1)
	
	;}
	
}