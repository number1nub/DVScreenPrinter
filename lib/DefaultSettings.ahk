DefaultSettings() {
	;File Save
	save := s.add2("save", {dir:"$appDir\Captures\$rssNum", name:"$windowName - $fileName", ext:"PNG"})
	
	;Capture Options
	opts := s.add2("options", {overwrite:0, promptOpenDir:1, closeAfterCapture:0})
	
	;Extensions
	exts := s.under(opts, "extensions")
	for c, v in ["JPG","GIF","PNG","BMP","TIFF"]
		s.under(exts, "ext",, v)
	
	;Hotkeys
	hk := s.add2("hotkeys")
	s.under(hk, "cmd",{name:"Capture",description:"Main Capture Hotkey"}, "^1")
	s.under(hk, "cmd", {name:"EditSettings",description:"Open Settings Editor"}, "+^s")
	s.under(hk, "cmd", {name:"CloseDVWins",description:"Close all DV Windows"})
	
	;Tray DoubleClick
	s.add2("trayclick", {default:"Edit settings"}, "Edit Settings|Capture Screens|Close All DV Windows")	
	s.save(1)
}