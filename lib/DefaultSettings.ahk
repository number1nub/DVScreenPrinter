DefaultSettings() {
	opts := s.add2("options", {overwrite:0, promptOpenDir:1})
	exts := s.under(opts, "extensions")
	for c, v in ["JPG","GIF","PNG","BMP","TIFF"]
		s.under(exts, "ext",, v)
	save := s.add2("save", {dir:A_ScriptDir "\Captures\$rssNum\$fileName", name:"$windowName", ext:"PNG"})
	hk := s.add2("hotkeys")
	s.under(hk, "cmd",{name:"Capture"}, "^1")
	s.under(hk, "cmd", {name:"EditSettings"}, "+^s")
	s.add2("trayclick", {default:"Edit settings"}, "Edit Settings|Capture Screens")
	s.add2("version",, StrReplace(";auto_version", "Version="))
	s.save(1)
}