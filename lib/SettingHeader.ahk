SettingHeader(txt, subTxt:="", opts:="") {
	hdrFont := s.get("//style/header/@size", 10)
	Gui, Font, % "bold s" hdrFont+3
	Gui, Add, Text, % opts ? opts : "xm y+15", %txt%
	Gui, Font, % "norm s" hdrFont
	if (subTxt) {
		Gui, Font, % "italic s" s.get("//style/label/@size", 8)
		Gui, Add, Text, y+5 xm, %subTxt%
		Gui, Font, % "norm s" hdrFont
	}
}