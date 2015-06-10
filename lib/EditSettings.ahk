EditSettings() {
	static ext, dir, fName, overwrite, mainHotkey, setHotkey, promptOpenDir, closeAfterCapture, dClickAction, hotkeys
	
	;Register Hotkeys
	save:=s.ea("//save"), opts:=s.ea("//options"), hotkeys:=[]
	while hk:=s.sn("//hotkeys/cmd").item[A_Index-1], ea:=s.ea(hk)
		hotkeys[ea.name]:=hk.text
	
	;Get available tags and extensions
	for c, v in Tags()		
		tagList .= (tagList ? ", ":"") "$" v
	while, ext:=s.sn("//extensions/ext").item[A_Index-1]
		extList .= (extList ? "|" : "") ext.text
	
	Gui, 1:Default
	Gui, +AlwaysOnTop +ToolWindow
	hFontSize := 11
	stFontSize := 9
	Gui, Font, % "cBlue s" hFontSize, Segoe UI
	Gui, Color, White, White	
	
	Header("Capture File Type",, "xm ym")
	;Output Extension
	;~ Label("Output File Type: ")
	Gui, Add, DropDownList, xm+1 y+5 w150 vext, % RegExReplace(StrReplace(extList, save.ext, save.ext "|"), "\|$", "||")	
	
	;Output Folder Name
	Header("Capture Save Root Folder", "(Available tags: " tagList ")")	
	Gui, Add, Edit, y+5 w550 h30 cBlack vdir, % save.dir
	Gui, Add, Button, x+1 yp-1 w45 h31 gselDir, ...
	
	;Output File Name
	Header("Output File Name Template", "(Available tags: " tagList ")")
	Gui, Add, Edit, y+5 w600 h30 cBlack vfName, % save.name
	
	;Overwrite, Prompting & Window Close Options
	Header("Capture Settings:")
	Gui, Add, Checkbox, % "y+10 xm voverwrite" (s.ea("//options").overwrite ? " Checked" : ""), Automatically Overwrite Files
	Gui, Add, Checkbox, % "y+10 xm vpromptOpenDir" (s.ea("//options").promptOpenDir ? " Checked" : ""), Prompt to Open Dir After Capture
	Gui, Add, Checkbox, % "y+10 xm vcloseAfterCapture" (s.ea("//options").closeAfterCapture ? " Checked" : ""), Close DataViewer Windows After Capture
	;~ Gui, Font, norm
	
	Header("Application Settings:")
	
	;Double-Click Tray Icon Action
	Gui, Add, Text, xm y+20, Double-click Tray Icon Action
	Gui, Add, DropDownList, xm y+5 w400 vdClickAction, % RegExReplace(StrReplace(s.ssn("//trayclick").text, s.ssn("//trayclick/@default").text, s.ssn("//trayclick/@default").text "|"), "\|$", "||")
	
	;Capture Hotkey
	Gui, Add, Text, y+20 xm, Main Capture Hotkey
	Gui, Add, Hotkey, x+5 cBlack vmainHotkey, % hotkeys.Capture
	
	;Settings Hotkey
	Gui, Add, Text, y+15 xm, Open Settings Hotkey
	Gui, Add, Hotkey, x+5 cBlack vsetHotkey, % hotkeys.EditSettings
	
	Gui, Show,, DV Screen Printer Options
	return
	
	
	selDir:
	Gui, Submit, Nohide
	Gui +OwnDialogs
	Gui +OwnDialogs
	FileSelectFolder, selDir, % "*" Tags(dir,"strip"), 3, Select default directory in which to save screen captures
	if (ErrorLevel || !selDir)
		return
	GuiControl,, Edit1, %selDir%
	return
	
	
	GuiEscape:
	GuiClose:
	Gui, Submit, NoHide	
	if (!mainHotkey || !setHotkey) {
		m("You must assign values to all hotkeys!","ico:!")
		return
	}
	chg:=false, rel:=false
	osave:=s.ea("//save"), otdk:=s.ea("//trayclick"), oopt:=s.ea("//options")
	
	;Save info
	dir:=RegExReplace(dir, "\\$"), ext:=Format("{1:U}",ext)
	s.add2("save", {dir:dir, ext:ext, name:fName})
	if !(dir = osave.dir && ext=osave.ext && name=osave.name)
		chg:=1
	;Options
	s.add2("options", {overwrite:overwrite, promptOpenDir:promptOpenDir, closeAfterCapture:closeAfterCapture})
	if !(overwrite=oopt.overwrite && promptOpenDir=oopt.promptOpenDir && closeAfterCapture=oopt.closeAfterCapture)
		chg:=1
	;Hotkeys
	for c, v in {Capture:mainHotkey, EditSettings:setHotkey}
		s.ssn("//hotkeys/cmd[@name='" c "']").text := v
	if !(mainHotkey=hotkeys.Capture && setHotkey=hotkeys.EditSettings)
		chg:=1, rel:=1
	;Tray DClick Action
	s.ssn("//trayclick/@default").text := dClickAction
	if !(dClickAction=otdk)
		chg:=1, rel:=1
	s.save(1)
	Gui, Destroy
	
	if (chg)
		TrayTip, DV Screen Printer, `nSettings saved..., .5, 1
	if (rel) {
		sleep 500
		Reload
	}
	Menu, Tray, Default, %dClickAction%
	TrayTip()
	return
}

Header(txt, subTxt:="", opts:="") {	
	Gui, Font, % "bold s" hFontSize+3
	Gui, Add, Text, % opts ? opts : "xm y+20", %txt%
	Gui, Font, % "norm s" hFontSize
	if (subTxt) {
		Gui, Font, % "italic s" stFontSize
		Gui, Add, Text, y+5 xm, %subTxt%
		Gui, Font, % "norm s" hFontSize
	}	
}
Label(txt) {
	Gui, Add, Text, xm+10 y+20, %txt%
}