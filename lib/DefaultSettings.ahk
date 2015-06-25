DefaultSettings() {
	;File Save
	save := s.add2("save", {dir:"$appDir\Captures\RSS $rssNum", name:"$windowName - $fileName", ext:"PNG"})
	
	;Capture Options
	opts := s.add2("options", {overwrite:0, promptOpenDir:1, closeAfterCapture:0})
	
	;Extensions
	exts := s.under(opts, "extensions")
	for c, v in ["JPG","GIF","PNG","BMP","TIFF"]
		s.under(exts, "ext",, v)
	
	;Hotkeys
	hk := s.add2("hotkeys")
	s.under(hk, "cmd",{name:"Capture",description:"Capture DV Screens"}, "^1")
	s.under(hk, "cmd", {name:"EditSettings",description:"Open Settings Editor"}, "+^s")
	s.under(hk, "cmd", {name:"CloseDVWins",description:"Close all DV Windows"})
	
	;Tray DoubleClick
	s.add2("trayclick", {default:"Open Settings Editor"}, "Open Settings Editor|Capture DV Screens|Close all DV Windows")
	
	;Style
	style := s.add2("style", {background:"F5F5F5", control:"White", color:"Blue", font:"Segoe UI"})
	s.under(style, "header", {size:10})
	s.under(style, "label", {size:8})
	
	s.save(1)
}