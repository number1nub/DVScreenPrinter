EditSettings() {
	static ext, dir, fName, overwrite, mainHotkey, setHotkey, promptOpen, dClickAction
	save:=s.ea("//save"), opts:=s.ssn("//options"), hotkeys:=[]
	
	while, ext:=s.sn("//extensions/ext").item(A_Index-1)
		extList .= (extList ? "|" : "") ext.text
	while hk:=s.sn("//hotkeys/cmd").item(A_Index-1), ea:=s.ea(hk)
		hotkeys[ea.name] := hk.text
	
	Gui, 1:Default
	Gui, +AlwaysOnTop +ToolWindow
	Gui, Font, s11 cBlue, Segoe UI
	Gui, Color, White
	Gui, Add, Text, xm ym, Output File Type:
	Gui, Add, DropDownList, yp-2 x+5 w100 vext, % RegExReplace(StrReplace(extList, save.ext, save.ext "|"), "\|$", "||")
	Gui, Add, Text, y+15 xm, Output Directory
	Gui, Font, s9 italic
	Gui, Add, Text, y+5 xm, (Available tags:  $windowName, $rssNum, $fileName, $filePath, $date, $time)
	Gui, Font, s11 norm
	Gui, Add, Edit, y+5 w550 h30 cBlack vdir, % save.dir
	Gui, Add, Button, x+1 yp-1 w45 h31 gselDir, ...
	Gui, Add, Text, y+15 xm, Output File Name Template
	Gui, Font, s9 italic
	Gui, Add, Text, y+5 xm, (Available tags:  $windowName, $rssNum, $fileName, $filePath, $date, $time)
	Gui, Font, s11 norm
	Gui, Add, Edit, y+5 w600 h30 cBlack vfName, % save.name
	Gui, Add, Checkbox, % "y+20 xm voverwrite" (s.ea("//options").overwrite ? " Checked" : ""), Automatically Overwrite Files
	Gui, Add, Checkbox, % "y+10 xm vpromptOpen" (s.ea("//options").promptOpenDir ? " Checked" : ""), Prompt to Open Dir After Capture
	Gui, Add, Text, y+20 xm, Double-click Tray Icon Action:
	Gui, Add, DropDownList, x+5 yp-2 vdClickAction, % RegExReplace(StrReplace(s.ssn("//trayclick").text, s.ssn("//trayclick/@default").text, s.ssn("//trayclick/@default").text "|"), "\|$", "||")
	Gui, Add, Text, y+20 xm, Main Capture Hotkey
	Gui, Add, Hotkey, x+5 cBlack vmainHotkey, % hotkeys.Capture
	Gui, Add, Text, y+15 xm, Open Settings Hotkey
	Gui, Add, Hotkey, x+5 cBlack vsetHotkey, % hotkeys.EditSettings
	Gui, Show,, DV Screen Printer Options
	return
	
	selDir:
	Gui, Submit, Nohide
	Gui +OwnDialogs
	FileSelectFolder, selDir, *%dir%, 3, Select default directory in which to save screen captures
	if (ErrorLevel || !selDir)
		return
	GuiControl,, Edit1, %selDir%
	return
	
	GuiEscape:
	GuiClose:
	Gui, Submit, NoHide
	if (!mainHotkey) {
		m("You must assign a main capture hotkey!","ico:!")
		return
	}
	s.add2("save", {dir:RegExReplace(dir, "\\$"), ext:Format("{1:U}",ext), name:fName})
	;for c, v in {dir:RegExReplace(dir, "\\$"), ext:Format("{1:U}",ext), name:fName}
	;s.ssn("//save").setAttribute(c, v)
	for c, v in {overwrite:overwrite, promptOpenDir:promptOpen}
		s.ssn("//options/@" c).text := v
	for c, v in {Capture:mainHotkey, EditSettings:setHotkey}
		s.ssn("//hotkeys/cmd[@name='" c "']").text := v
	s.ssn("//trayclick/@default").text := dClickAction
	s.save(1)
	TrayTip, DV Screen Printer, `nSettings saved..., .5, 1
	Gui, Destroy
	if (s.ssn("//hotkeys/cmd[@name='Capture']").text!=mainHotkey || s.ssn("//hotkeys/cmd[@name='EditSettings']").text!=setHotkey) {
		s.save(1)
		sleep 2000
		Reload
	}
	Menu, Tray, Default, %dClickAction%
	TrayTip()
	return
}






























