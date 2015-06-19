EditSettings() {
	static
	
	style := s.ea("//style")
	
	Gui, 1:Default
	Gui, +AlwaysOnTop ;+ToolWindow
	Gui, Font, % "c" style.color " s" s.get("//style/header/@size", 10), % style.font
	Gui, Color, % style.background, % style.control
	
	;Output Extension
	save:=s.ea("//save")
	extList := ""
	while, ext:=s.sn("//extensions/ext").item[A_Index-1]
		extList .= (extList ? "|" : "") ext.text
	SettingHeader("Capture File Type:",, "xm ym")
	Gui, Add, DropDownList, x+10 yp+1 w150 vext, % RegExReplace(StrReplace(extList, save.ext, save.ext "|"), "\|$", "||")	
	
	;Output Folder Name
	tagList := ""
	for c, v in Tags()
		tagList .= (tagList ? ", ":"") "$" v
	SettingHeader("Capture Save Root Folder", "(Available tags: " tagList ")")	
	Gui, Add, Edit, y+5 w550 h30 cBlack vdir, % save.dir
	Gui, Add, Button, x+1 yp-1 w45 h31 gselDir, ...
	
	;Output File Name
	SettingHeader("Output File Name Template", "(Available tags: " tagList ")")
	Gui, Add, Edit, y+5 w600 h30 cBlack vfName, % save.name
	
	;Overwrite, Prompting & Window Close Options
	opts:=s.ea("//options")
	SettingHeader("Capture Settings:")
	Gui, Add, Checkbox, % "y+5 xm voverwrite" (opts.overwrite ? " Checked" : ""), Automatically Overwrite Files
	Gui, Add, Checkbox, % "y+5 xm vpromptOpenDir" (opts.promptOpenDir ? " Checked" : ""), Prompt to Open Dir After Capture
	Gui, Add, Checkbox, % "y+5 xm vcloseAfterCapture" (opts.closeAfterCapture ? " Checked" : ""), Close DataViewer Windows After Capture
	
	;Double-Click Tray Icon Action
	tdkAct := s.get("//trayclick/@default","EditSettings")
	SettingHeader("Double-Click Tray Icon Action:")
	Gui, Add, DropDownList, x+10 yp+1 w300 vdClickAction, % RegExReplace(StrReplace(s.ssn("//trayclick").text, tdkAct, tdkAct "|"), "\|$", "||")
	
	;Hotkeys
	hotkeys := []
	while hk:=s.sn("//hotkeys/cmd").item[A_Index-1], ea:=s.ea(hk)
		hotkeys[ea.name] := {value:hk.text, description:ea.description}	
	SettingHeader("Hotkey Settings")
	for c, v in hotkeys {
		Gui, Add, Text, y+10 xm, % hotkeys[c].description ": "
		Gui, Add, Hotkey, x+5 yp-2 border cBlack v%c%HK, % hotkeys[c].value
	}
	
	Gui, Show,, % RegExReplace(A_ScriptName,"\.(ahk|exe)$") " Options"
	return
	
	
	selDir:
	Gui, Submit, Nohide
	Gui +OwnDialogs
	FileSelectFolder, selDir, % "*" Tags(dir,"strip"), 3, Select default directory in which to save screen captures
	if (ErrorLevel || !selDir)
		return
	GuiControl,, Edit1, %selDir%
	return
	
	
	GuiEscape:
	GuiClose:
	Gui, Submit, NoHide	
	if (!CaptureHK && hotkeys.Capture.value && m("You don't have a main capture hotkey assigned.`n", "Continue and disable capture hotkey?","ico:?","btn:yn")!="YES")
		return
	Gui, Destroy
	chg:=false, rel:=false
	;
	;Save info
	for c, v in {dir:RegExReplace(dir,"\\$"), ext:Format("{1:U}",ext), name:fName} {
		s.ssn("//save/@" c).text := v
		if (save[c] != v)
			chg:=1
	}
	;
	;Options
	for c, v in {overwrite:overwrite, promptOpenDir:promptOpenDir, closeAfterCapture:closeAfterCapture} {
		s.ssn("//options/@" c).text := v
		if (opts[c] != v)
			chg:=1
	}	
	;
	;Hotkeys
	for c, v in {Capture:CaptureHK, EditSettings:EditSettingsHK, CloseDVWins:CloseDVWinsHK} {
		s.ssn("//hotkeys/cmd[@name='" c "']").text := v
		if (v != hotkeys[c].value)
			rel:=1
	}
	;
	;Tray DClick Action
	s.ssn("//trayclick/@default").text := dClickAction
	if (dClickAction != tdkAct)
		rel:=1
	
	s.save(1)
	if (chg || rel)
		TrayTip, DV Screen Printer, `nSettings saved..., .5, 1
	if (rel) {
		sleep 500
		Reload
	}
	Menu, Tray, Default, %dClickAction%
	TrayTip()
	return
}