DefaultSettings() {
	static hkList:={ Capture:       {desc:"Capture DV Wins",   hk:"^1"}
				   , EditSettings:  {desc:"Edit Settings",     hk:"^+s"}
				   , CloseDVWins:   {desc:"Close all DV Wins", hk:"^!1"}
				   , OpenCaptureDir:{desc:"Open Captures Dir", hk:""}}
	
	;File Save
	save := s.add2("save", {dir:"$appDir\Captures\RSS $rssNum", name:"$windowName - $fileName", ext:"PNG"})
	
	;Capture Options
	opts := s.add2("options", {overwrite:0, promptOpenDir:1, closeAfterCapture:0})
	
	;Extensions
	exts := s.under(opts, "extensions")
	for c, v in ["JPG","GIF","PNG","BMP","TIFF"]
		s.under(exts, "ext",, v)
	
	;Hotkeys
	tkList:=""
	hk := s.add2("hotkeys")
	for c, v in hkList {
		s.under(hk, "cmd", {name:c, description:v.desc}, v.hk)
		tkList .= (tkList ? "|" : "") v.desc 
	}
	
	;Tray DoubleClick
	s.add2("trayclick", {default:"Edit Settings"}, tkList)
	
	;Style
	style := s.add2("style", {background:"F5F5F5", control:"White", color:"Blue", font:"Segoe UI"})
	s.under(style, "header", {size:10})
	s.under(style, "label", {size:8})
	
	s.save(1)
}