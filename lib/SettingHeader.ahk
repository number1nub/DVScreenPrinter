SettingHeader(txt, subTxt:="", opts:="") {
	Gui, Font, % "bold s" hdrFont+3
	Gui, Add, Text, % opts ? opts : "xm y+20", %txt%
	Gui, Font, % "norm s" hdrFont
	if (subTxt) {
		Gui, Font, % "italic s" subFont
		Gui, Add, Text, y+5 xm, %subTxt%
		Gui, Font, % "norm s" hdrFont
	}	
}