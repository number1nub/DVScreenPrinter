#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3

if (isAdmin:=CheckCredentials(%true%))
	if (%true% != "silent")
		TrayTip, DVScreenPrinter, `nRunning as Admin..., 1, 1

global version, s:=new xml("settings", A_AppData "\DVScreenPrinter\settings.xml")

version = 2.2.6
s.fileExists ? UpdateSettings() : DefaultSettings()
if (!FileExist(A_ScriptDir "\gdiplus.dll") && A_IsCompiled) {
	FileInstall, C:\Windows\System32\gdiplus.dll, %A_ScriptDir%\gdiplus.dll
}
TrayMenu()
RegisterHotkeys()
CheckUpdate()
return



Activate(win="A", wait="", timeout:=2, silent:="") {
	if (WinExist(wName:="ahk_id " win))
		WinActivate, %wName%
	else if (WinExist(wName:=win))
		WinActivate, %wName%
	if (wait) {
		WinWaitActive, %wName%,, % timeout
		if (ErrorLevel && !silent)
			m("Couldn't activate window:", wName, "ico:!")
	}
}

BackupSettings(silent:="") {	
	prevBUpath := Format("{1}\{2}", s.get("//backup/@dir", A_ScriptDir), s.get("//backup/@name", TimeStamp() "_DVScreenPrinter.xml"))
	FileSelectFile, backupPath, S 24, %prevBUpath%, Select where the backup should be saved:, Backup File (*.xml;*.bak)
	if (ErrorLevel || !backupPath || backupPath=s.file)
		return
	if (FileExist(backupPath))
		FileDelete, %backupPath%
	SplitPath, backupPath, oName, oDir
	s.add2("backup", {dir:oDir, name:oName, time:TimeStamp("yyyyMMddHHmmss")})
	s.save(1)
	FileCopy, % s.file, %backupPath%, 1
	if (ErrorLevel || !FileExist(backupPath))
		return
	if (!silent)
		m(RegExReplace(A_ScriptName, "\.(ahk|exe)\s*$") " settings file successfully exported", "ico:i")
	return 1
}

Capture() {
	wList := GetWinList()
	if (wList.MaxIndex() < 1)
		return m("No DataViewer chart windows found!", "ico:!")
	
	BL:=A_BatchLines, save:=s.ea("//save"), opts:=s.ea("//options")
	SetBatchLines, -1
	If (!pToken := Gdip_Startup()) {
		m("GDIPlus Failed to start!", "Please ensure that gdiplus.dll is on your system.", "title:GDIPlus Error", "ico:!")
		ExitApp
	}
	WinRestore, ahk_group DVWins
	winCount := 0
	for c, v in wList {
		if (!FileExist(sDir:=Tags(save.dir, v)))
			FileCreateDir, %sDir%
		if (FileExist(fName:=sDir "\" Tags(save.name, v) "." save.ext)) {
			if (!opts.overwrite) {
				if ((ans:=m("Overwrite existing file?", "`n""" fName """?", "`n<Cancel> will abort capturing.", "`n(You can disable this prompt in settings)", "btn:ync", "ico:?")) = "NO")
					continue
				else if (ans = "CANCEL")
					break
			}
			FileDelete, %fName%
		}
		pBitmap := Gdip_BitmapFromHWND(v.id)
		Gdip_SaveBitmapToFile(pBitmap, fName)
		Gdip_DisposeImage(pBitmap)
		winCount++
	}
	Gdip_Shutdown(pToken)
	SetBatchLines, %BL%
	if (winCount > 0) {
		if (opts.closeAfterCapture)
			WinClose, ahk_group DVWins
		if (m(winCount " of " wList.MaxIndex() " windows captured. " (opts.promptOpenDir ? "Open output folder?`n`n(You can disable this prompt in settings)" : ""), "title:DataViewer Capture Complete!","ico:i", opts.promptOpenDir ? "btn:yn" : "") = "YES")
			Run, % "explore " sDir
	}
}

CheckCredentials(info:="") {
	if (!A_IsAdmin) {
		if (info != "admin") {
			Run, *runas "%A_ScriptFullPath%" admin
			ExitApp
		}
		ans := CMBox("Currently NOT running with admin privileges...`n`nAttempt to re-launch as admin?", "Yes, Reload as Admin|No, Continue|Cancel && Exit", {ico:"?"})
		if (Instr(ans, "Exit"))
			ExitApp
		else if (InStr(ans, "Yes,")) {
			Run, *RunAs "%A_ScriptFullPath%" admin
			ExitApp
		}
		return
	}
	return 1
}

CheckForUpdate() {
	if (!CheckUpdate())
		m("No update available.", "ico:i")
}
CheckUpdate(_ReplaceCurrentScript:=1, _SuppressMsgBox:=0, _CallbackFunction:="", ByRef _Information:="") {
	Static Update_URL  := "http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.text"
		 , Download_URL := "http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.exe"
		 , Retry_Count := 2
		 , Script_Name := "DVScreenPrinter"
	
	if (!Version)
		return
	if (!Script_Name) {
		SplitPath, A_ScriptFullPath,,,, scrName
		Script_Name := scrName
	}
	Random, Filler, 10000000, 99999999	
	Version_File := A_Temp "\" Filler ".ini", Temp_FileName:=A_Temp "\" Filler ".tmp", VBS_FileName:=A_Temp "\" Filler ".vbs"
	Loop, %Retry_Count% {
		_Information := ""
		UrlDownloadToFile,%Update_URL%,%Version_File%
		Loop, Read, %Version_File%
		{
			UDVersion := A_LoopReadLine ? A_LoopReadLine : "N/A"
			break
		}
		if (UDVersion = "N/A") {
			FileDelete,%Version_File%
			if (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			else
				Sleep, 500
			Continue
		}
		if (UDVersion > Version) {
			FileRead, changeLog, %Version_File%
			if (_SuppressMsgBox != 1 && _SuppressMsgBox != 3)
				if (m("There is a new version of " Script_Name " available.", "Current version: " Version, "New version: " UDVersion, "Change Log:", "", changeLog, "", "Would you like to download it now?", "title:New version available", "btn:yn", "ico:i") = "Yes")
					MsgBox_Result := 1
			if (_SuppressMsgBox || MsgBox_Result) {
				URL := Download_URL
				SplitPath, URL,,, Extension					
				if (Extension = "ahk" && A_AHKPath = "")
					_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
				else if (Extension != "exe" && Extension != "ahk")
					_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
				else {
					IniRead,MD5,%Version_File%,Info,MD5,N/A
					Loop, %Retry_Count% {
						UrlDownloadToFile,%URL%,%Temp_FileName%
						if (FileExist(Temp_FileName)) {
							if (MD5 = "N/A") {
								_Information.="The version info file doesn't have a valid MD5 key.", Success:= True
								Break
							}
							else {
								Ptr:=A_PtrSize?"Ptr":"UInt", H:=DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0), DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize), FileSize:=FileSize = -1 ? 0 : FileSize
								if (FileSize != 0) {
									VarSetCapacity(Data,FileSize,0), DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0), DllCall("CloseHandle",Ptr,H), VarSetCapacity(MD5_CTX,104,0), DllCall("advapi32\MD5Init",Ptr,&MD5_CTX), DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize), DllCall("advapi32\MD5Final",Ptr,&MD5_CTX), FileMD5:=""
									Loop, % StrLen(Hex:="123456789ABCDEF0")
										N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
									VarSetCapacity(Data,FileSize,0), VarSetCapacity(Data,0)
									if (FileMD5 != MD5) {
										FileDelete,%Temp_FileName%
										if (A_Index = Retry_Count)
											_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
										else
											Sleep, 500
										Continue
									}
									else
										Success := True
								}
								else
									DllCall("CloseHandle",Ptr,H), Success := True									
							}
						}
						else {
							if (A_Index = Retry_Count)
								_Information .= "Unable to download the latest version of the file from " URL "."
							else
								Sleep, 500
							Continue
						}
					}
				}
			}
		}
		else
			_Information .= "No update was found."
		FileDelete, %Version_File%
		Break
	}	
	if (_ReplaceCurrentScript && Success) {
		SplitPath, URL,,, Extension
		Process, Exist
		MyPID := ErrorLevel
		VBS_P1 =
		(LTrim Join`r`n
			On Error Resume Next
			Set objShell = CreateObject("WScript.Shell")
			objShell.Run "TaskKill /F /PID %MyPID%", 0, 1
			Set objFSO = CreateObject("Scripting.FileSystemObject")
		)
		if (A_IsCompiled) {
			SplitPath, A_ScriptFullPath,, Dir,, Name
			VBS_P2 =
			(LTrim Join`r`n
				Finished = False
				Count = 0
				Do Until (Finished = True Or Count = 5)
					Err.Clear
					objFSO.CopyFile "%Temp_FileName%", "%Dir%\%Name%.%Extension%", True
					if (Err.Number = 0) then
						Finished = True
						objShell.Run """%Dir%\%Name%.%Extension%"""
					else
						WScript.Sleep(1000)
						Count = Count + 1
					End if
				Loop
				objFSO.DeleteFile "%Temp_FileName%", True
			)
			Return_Val := Temp_FileName
		}
		else {
			if (Extension = "ahk") {
				FileMove,%Temp_FileName%,%A_ScriptFullPath%,1
				if (Errorlevel)
					_Information .= "Error (" Errorlevel ") unable to replace current script with the latest version."
				else {
					VBS_P2 =
					(LTrim Join`r`n
						objShell.Run """%A_ScriptFullPath%"""
					)
					Return_Val :=  A_ScriptFullPath
				}
			}
			else if (Extension = "exe") {
				SplitPath, A_ScriptFullPath,, FDirectory,, FName
				FileMove, %Temp_FileName%, %FDirectory%\%FName%.exe, 1
				FileDelete, %A_ScriptFullPath%
				VBS_P2 =
				(LTrim Join`r`n
					objShell.Run """%FDirectory%\%FName%.exe"""
				)
				Return_Val :=  FDirectory "\" FName ".exe"
			}
			else {
				FileDelete,%Temp_FileName%
				_Information .= "The downloaded file is not an .EXE or an .AHK file type. Replacing the current script is not supported."
			}
		}
		VBS_P3 =
		(LTrim Join`r`n
			objFSO.DeleteFile "%VBS_FileName%", True
		)
		if (_SuppressMsgBox < 2) {
			if (InStr(VBS_P2, "Do Until (Finished = True Or Count = 5)")) {
				VBS_P3.="`r`nif (Finished=False) Then", VBS_P3.="`r`nWScript.Echo ""Update failed.""", VBS_P3.="`r`nelse"
				if (Extension != "exe")
					VBS_P3 .= "`r`nobjFSO.DeleteFile """ A_ScriptFullPath """"
				VBS_P3.="`r`nWScript.Echo ""Update completed successfully.""", VBS_P3.="`r`nEnd if"
			}
			else
				VBS_P3 .= "`r`nWScript.Echo ""Update complected successfully."""
		}
		FileDelete, %VBS_FileName%
		FileAppend, %VBS_P1%`r`n%VBS_P2%`r`n%VBS_P3%, %VBS_FileName%
		if (_CallbackFunction != "") {
			if (IsFunc(_CallbackFunction))
				%_CallbackFunction%()
			else
				_Information .= "The callback function is not a valid function name."
		}
		RunWait, %VBS_FileName%, %A_Temp%, VBS_PID
		Sleep, 2000
		Process, Close, %VBS_PID%
		_Information := "Error (?) unable to replace current script with the latest version.`r`nPlease make sure your computer supports running .vbs scripts and that the script isn't running in a pipe."
	}
	_Information := _Information ? _Information : "None"
	Return Return_Val
}

class xml
{
	keep:=[]
	
	__New(param*) {
		root:=param.1, file:=param.2
		file:=file ? file : root ".xml"
		temp:=ComObjCreate("MSXML2.DOMDocument")
		temp.setProperty("SelectionLanguage", "XPath")
		this.xml:=temp, this.fileExists:=false
		if FileExist(file) {
			FileRead, info, %file%
			if (!info) {
				this.xml := this.CreateElement(temp, root)
				FileDelete, %file%
			}
			else
				this.fileExists:=true, temp.loadxml(info), this.xml:=temp
		}
		else
			this.xml := this.CreateElement(temp, root)
		this.file := file
		xml.keep[root] := this
	}
	
	__Get(x="") {
		return this.xml.xml
	}
	
	CreateElement(doc, root) {
		return doc.AppendChild(this.xml.CreateElement(root)).parentnode
	}
	
	search(node, find, return="") {
		found:=this.xml.SelectNodes(node "[contains(.,'" RegExReplace(find,"&","')][contains(.,'") "')]")
		while,ff:=found.item[A_Index-1]
			if (ff.text = find) {
				if (return)
					return ff.SelectSingleNode("../" return)
				return ff.SelectSingleNode("..")
			}
	}
	
	lang(info) {
		info:= info="" ? "XPath" : "XSLPattern"
		this.xml.temp.setProperty("SelectionLanguage", info)
	}
	
	unique(info) {
		if (info.check&&info.text)
			return
		if info.under{
			if (info.check)
				find := info.under.SelectSingleNode("*[@" info.check "='" info.att[info.check] "']")
			if (info.Text)
				find := this.cssn(info.under,"*[text()='" info.text "']")
			if (!find)
				find := this.under(info.under,info.path,info.att)
			for a, b in info.att
				find.SetAttribute(a, b)
		}
		else {
			if (info.check)
				find := this.ssn("//" info.path "[@" info.check "='" info.att[info.check] "']")
			else if (info.text)
				find := this.ssn("//" info.path "[text()='" info.text "']")
			if (!find)
				find := this.add({path:info.path,att:info.att,dup:1})
			for a, b in info.att
				find.SetAttribute(a,b)
		}
		if (info.text)
			find.text := info.text
		return find
	}
	
	add2(path, att:="", text:="", dup:=0, list:="") {
		p:="/", dup1:=this.ssn("//" path)?1:0, next:=this.ssn("//" path), last:=SubStr(path,InStr(path,"/",0,0)+1)
		if (!next.xml) {
			next := this.ssn("//*")
			Loop, Parse, path, /
				last:=A_LoopField, p.="/" last, next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
		}
		if (dup&&dup1)
			next := next.parentnode.appendchild(this.xml.CreateElement(last))
		for a, b in att
			next.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			next.SetAttribute(b, att[b])
		if (text)
			next.text := text
		return next
	}
	
	add(info) {
		path:=info.path, p:="/", dup:=this.ssn("//" path)?1:0
		if (next:=this.ssn("//" path) ? this.ssn("//" path) : this.ssn("//*"))
			Loop, Parse, path, /
				last:=A_LoopField, p.="/" last, next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
		if (info.dup && dup)
			next := next.parentnode.appendchild(this.xml.CreateElement(last))
		for a, b in info.att
			next.SetAttribute(a, b)
		for a, b in StrSplit(info.list, ",")
			next.SetAttribute(b, info.att[b])
		if (info.text)
			next.text := info.text
		return next
	}
	
	find(info) {
		if (info.att.1 && info.text)
			return m("You can only search by either the attribut or the text, not both","ico:!")
		search := info.path ? "//" info.path : "//*"
		for a, b in info.att
			search .= "[@" a "='" b "']"
		if (info.text)
			search .= "[text()='" info.text "']"
		current := this.ssn(search)
		return current
	}
	
	under(under, node:="", att:="", text:="", list:="") {
		if (!node)
			node:=under.node, att:=under.att, list:=under.list, under:=under.under
		new := under.appendchild(this.xml.createelement(node))
		for a, b in att
			new.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			new.SetAttribute(b, att[b])
		if (text)
			new.text := text
		return new
	}
	
	ssn(node) {
		return this.xml.SelectSingleNode(node)
	}
	
	sn(node) {
		return this.xml.SelectNodes(node)
	}
	
	Get(path, default) {
		return value := this.ssn(path).text!="" ? this.ssn(path).text : default
	}
	
	Transform(Loop:=1){
		static
		if(!IsObject(XSL)) {
			XSL:=ComObjCreate("MSXML2.DOMDocument")
			XSL.LoadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>")
			Style:=null
		}
		Loop,%Loop%
			this.XML.TransformNodeToObject(XSL,this.XML)
	}
	
	save(x*) {
		if (x.1=1)
			this.Transform()
		filename := this.file ? this.file : x.1.1
		SplitPath, filename,, fDir
		if (!FileExist(fDir))
			FileCreateDir, %fDir%
		file := fileopen(filename, "rw", "Utf-8")
		file.seek(0)
		file.write(this[])
		file.length(file.position)
	}
	
	remove(rem) {
		if (!IsObject(rem))
			rem := this.ssn(rem)
		rem.ParentNode.RemoveChild(rem)
	}
	
	ea(path) {
		list:=[]
		if (nodes:=path.nodename)
			nodes := path.SelectNodes("@*")
		else if (path.text)
			nodes := this.sn("//*[text()='" path.text "']/@*")
		else if (!IsObject(path))
			nodes := this.sn(path "/@*")
		else
			for a, b in path
				nodes := this.sn("//*[@" a "='" b "']/@*")
		while, (n:=nodes.item[A_Index-1])
			list[n.nodename] := n.text
		return list
	}
}

CloseDVWins() {
	WinGet, ID, List	
	Loop, %ID% {
		ID := ID%A_Index%
		WinGetTitle, Title, ahk_id %ID%
		if RegExMatch(title, "TerraVici DataViewer \d+\.\d+")
			WinClose, ahk_id %id%
	}
}

CMBox(msg, btns, opts:="") {
	optVal:=4096, iconVal:={"x":16,"?":32,"!":48,"i":64}, btnVal:={2:4, 3:2}
	btns:=IsObject(btns) ? btns : StrSplit(btns, "|")
	optVal+=iconVal[opts.ico] + btnVal[btns.MaxIndex()]
	SetTimer, ChangeButtons, 5
	MsgBox, % optVal, % mTitle:=opts.title?opts.title:A_ScriptName, % msg
	IfMsgBox, Yes
		return btns[1]
	else IfMsgBox, OK
		return btns[1]	
	else IfMsgBox, No
		return btns[2]
	else IfMsgBox, Retry
		return btns[2]
	else IfMsgBox, Ignore
		return btns[3]
	
	ChangeButtons:
	IfWinNotExist, %mTitle%
		return
	SetTimer, ChangeButtons, off
	bGap:=3, wGap:=10, charW:=8, nx:=[]
	WinGetPos,,, ww
	ControlGetPos,,, cw1,, Button1
	ControlGetPos,,, cw2,, Button2
	ControlGetPos,,, cw3,, Button3
	req:=[StrLen(btns[1])*charW, StrLen(btns[2])*charW, StrLen(btns[3])*charW]
		, nw:=[cw1<req[1]?req[1]:cw1, cw2<req[2]?req[2]:cw2, cw3<req[3]?req[3]:cw3]
		, nww:=nw[1]+nw[2]+nw[3]+(5*wGap)+(bGap*btns.MaxIndex()-bGap)
		, nx.Push((nww>ww?nww:ww-bGap)-3*(bGap*btns.MaxIndex()-bGap)-nw[1]-nw[2]-nw[3])
		, nx.Push(nx[1]+nw[1]+bGap, nx[1]+nw[1]+bGap+nw[2]+bGap)	
	WinMove,,,,, % nww>ww?nww:ww
	ControlMove, Button1, % nx[1],, % nw[1]
	ControlMove, Button2, % nx[2],, % nw[2]
	ControlMove, Button3, % nx[3],, % nw[3]
	ControlSetText, Button1, % btns[1]
	ControlSetText, Button2, % btns[2]
	ControlSetText, Button3, % btns[3]	
	return
}

ConvertHotkey(key) {
	StringUpper,key,key
	for a,b in [{Shift:"+"},{Ctrl:"^"},{Alt:"!"}]
		for c,d in b
			key:=RegExReplace(key,"\" d,c "+")
	return key
}

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
	
	Gui, Show,, % RegExReplace(A_ScriptName,"\.(ahk|exe)$") (version ? " v" version : "") " Options"
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
		TrayTip, DV Screen Printer, `nSettings saved..., .75, 1
	if (rel) {
		sleep 750
		Run, "%A_ScriptFullPath%" silent
		ExitApp
	}
	dClickActionXtra := (dClickHK:=s.ssn("//hotkeys/cmd[@description='" dClickAction "']").text) ? "`t(" ConvertHotkey(dClickHK) ")" : ""
	Menu, Tray, Default, % dClickAction dClickActionXtra
	TrayTip()
	return
}

Exit() {
	ExitApp
}

Gdip_Startup() {
	if (!DllCall("GetModuleHandle", "str", "gdiplus"))
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, 16, 0), si:=Chr(1)
	DllCall("gdiplus\GdiplusStartup", "uint*", pToken, "uint", &si, "uint", 0)
	return pToken
}

GetDC(hwnd=0) {
	return DllCall("GetDC", "uint", hwnd)
}

ReleaseDC(hdc, hwnd=0) {
	return DllCall("ReleaseDC", "uint", hwnd, "uint", hdc)
}

Gdip_BitmapFromHWND(hwnd) {
	WinGetPos,,, Width, Height, ahk_id %hwnd%
	hbm := CreateDIBSection(Width, Height)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm)
	DeleteObject(hbm)
	DeleteDC(hdc)
	return pBitmap
}

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75) {
	SplitPath, sOutput,,, Extension
	if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
		return -1
	Extension := "." Extension
	
	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "uint", &ci)
	if !(nCount && nSize)
		return -2
	
	Loop, %nCount%
	{
		Location := NumGet(ci, 76*(A_Index-1)+44)
		if !A_IsUnicode
		{
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			VarSetCapacity(sString, nSize)
			DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
			if !InStr(sString, "*" Extension)
				continue
		}
		else
		{
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			sString := ""
			Loop, %nSize%
				sString .= Chr(NumGet(Location+0, 2*(A_Index-1), "char"))
			if !InStr(sString, "*" Extension)
				continue
		}
		pCodec := &ci+76*(A_Index-1)
		break
	}
	if !pCodec
		return -3
	
	if (Quality != 75)
	{
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
		if Extension in .JPG,.JPEG,.JPE,.JFIF
		{
			DllCall("gdiplus\GdipGetEncoderParameterListSize", "uint", pBitmap, "uint", pCodec, "uint*", nSize)
			VarSetCapacity(EncoderParameters, nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", "uint", pBitmap, "uint", pCodec, "uint", nSize, "uint", &EncoderParameters)
			Loop, % NumGet(EncoderParameters)      ;%
			{
				if (NumGet(EncoderParameters, (28*(A_Index-1))+20) = 1) && (NumGet(EncoderParameters, (28*(A_Index-1))+24) = 6)
				{
					p := (28*(A_Index-1))+&EncoderParameters
					NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20)))
					break
				}
			}      
		}
	}
	
	if (!A_IsUnicode) {
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wOutput, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", &wOutput, "int", nSize)
		VarSetCapacity(wOutput, -1)
		if !VarSetCapacity(wOutput)
			return -4
		E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &wOutput, "uint", pCodec, "uint", p ? p : 0)
	}
	else
		E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &sOutput, "uint", pCodec, "uint", p ? p : 0)
	return E ? -5 : 0
}

PrintWindow(hwnd, hdc, Flags=0) {
	return DllCall("PrintWindow", "uint", hwnd, "uint", hdc, "uint", Flags)
}

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0) {
	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi, 40, 0)
	NumPut(w, bi, 4)
	NumPut(h, bi, 8)
	NumPut(40, bi, 0)
	NumPut(1, bi, 12, "ushort")
	NumPut(0, bi, 16)
	NumPut(bpp, bi, 14, "ushort")
	hbm := DllCall("CreateDIBSection", "uint" , hdc2, "uint" , &bi, "uint" , 0, "uint*", ppvBits, "uint" , 0, "uint" , 0)
	
	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

CreateCompatibleDC(hdc=0) {
	return DllCall("CreateCompatibleDC", "uint", hdc)
}

SelectObject(hdc, hgdiobj) {
	return DllCall("SelectObject", "uint", hdc, "uint", hgdiobj)
}

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0) {
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uint", hBitmap, "uint", Palette, "uint*", pBitmap)
	return pBitmap
}

DeleteObject(hObject) {
	return DllCall("DeleteObject", "uint", hObject)
}

DeleteDC(hdc) {
	return DllCall("DeleteDC", "uint", hdc)
}

Gdip_Shutdown(pToken) {
	DllCall("gdiplus\GdiplusShutdown", "uint", pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
		DllCall("FreeLibrary", "uint", hModule)
	return 0
}

Gdip_DisposeImage(pBitmap) {
	return DllCall("gdiplus\GdipDisposeImage", "uint", pBitmap)
}

GetWinList() {
	winList:=[], TMM:=A_TitleMatchMode
	filter := "(?P<Name>.+?)(?: - TerraVici DataViewer)? - (?P<File>.+)"
	ignore := "TerraVici DataViewer \d+\.\d+'"
	SetTitleMatchMode, Regex
	WinGet, ID, List, ahk_class HwndWrapper\[DataViewer\.exe
	Loop, % ID {
		this := ID%A_Index%
		WinGetTitle, Title, ahk_id %this%
		if (RegExMatch(Title, "i)" filter, m) && !RegExMatch(title, ignore)) {
			SplitPath, mFile,, fDir,, fName
			winList[A_Index] := {title:Title, id:this, name:mName, filepath:mFile, filename:fName, filedir:fDir}
			GroupAdd, DVWins, ahk_id %this%
		}
	}
	SetTitleMatchMode, %TMM%
	return winList
}

Hotkeys(key:="", item:="", win:="") {
	static hkList := []
	if (!key)
		return hkList
	launch := RegExReplace(RegExReplace(item,"&")," ","_")
	if (!launch && ObjHasKey(hkList, key)) {
		Hotkey, %key%, Toggle
		hkList[key].state := hkList[key].state ? 0 : 1
		return
	}
	if (!launch)
		return
	if (win) {		
		if (SubStr(win,1,1) = "!")
			Hotkey, IfWinNotActive, % SubStr(win, 2)
		else
			Hotkey, IfWinActive, %win%
	}
	Hotkey, %key%, %launch%, On
	hkList[key] := {state:1, launch:launch}
	Hotkey, IfWinActive
	return
}

ImportSettings() {
	IniRead, lastBUDir, %strIniFile%, Backup, BackupDir, % ""
	IniRead, lastBUName, %strIniFile%, Backup, BackupName, % ""
	lastBUDir := s.ssn("//backup/@dir").text
	lastBUName := s.ssn("//backup/@name").text
	Gui +OwnDialogs
	FileSelectFile, loadPath, 3, % lastBUDir (lastBUName ? "\" lastBUName:""), Select file to be imported:, Backup File (*.xml;*.bak)
	if (ErrorLevel || !FileExist(loadPath))
		return
	if (m("Would you like to backup your current settings file before importing?", "ico:?", "btn:yn")="YES") {
		if (!BackupSettings(1))
			if (m("File backup failed...`n`nContinue with import anyway?", "ico:!", "btn:yn")="NO")
				return
	}
	FileMove, % s.file, % s.file ".bak", 1
	FileCopy, %loadPath%, % s.file, 1
	if (ErrorLevel) {
		if (!FileExist(strIniFile)) {
			FileCopy, % s.file ".bak", % s.file, 1
			return
		}
	}
	m("Settings successfully imported from " loadPath, "ico:i")
	Reload()
}

m(info*) {
	static icons:={"x":16,"?":32,"!":48,"i":64}, btns:={c:1,oc:1,co:1,ari:2,iar:2,ria:2,rai:2,ync:3,nyc:3,cyn:3,cny:3,yn:4,ny:4,rc:5,cr:5}
	for c, v in info {
		if RegExMatch(v, "imS)^(?:btn:(?P<btn>c|\w{2,3})|(?:ico:)?(?P<ico>x|\?|\!|i)|title:(?P<title>.+)|def:(?P<def>\d+)|time:(?P<time>\d+(?:\.\d{1,2})?|\.\d{1,2}))$", m_) {
			mBtns:=m_btn?1:mBtns, title:=m_title?m_title:title, timeout:=m_time?m_time:timeout
			opt += m_btn?btns[m_btn]:m_ico?icons[m_ico]:m_def?(m_def-1)*256:0
		}
		else
			txt .= (txt ? "`n":"") v
	}
	MsgBox, % (opt+262144), %title%, %txt%, %timeout%
	IfMsgBox, Ok
		return (mBtns ? "OK":"")
	else IfMsgBox, Yes
		return "YES"
	else IfMsgBox, No
		return "NO"
	else IfMsgBox, Cancel
		return "CANCEL"
	else IfMsgBox, Retry
		return "RETRY"
}

OpenCaptureDir() {
	dir := Tags(s.ssn("//save/@dir").text, "strip")
	if (FileExist(dir))
		Run, explore "%dir%"
	else
		m("Unable to locate/open capture folder.", "ico:!")
}

RegisterHotkeys() {
	while hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=s.ea(hk)
		Hotkeys(hk.text, ea.name, "!DV Screen Printer Options")
}

Reload() {
	Reload
	Pause
}

Restore(win) {
	if (WinExist(wName:="ahk_id " win))
		WinRestore, %wName%
	else if (WinExist(win))
		WinRestore, %win%
}

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

Tags(str:="", info:="") {
	static tagList := ["date", "fileName", "filePath", "rssNum", "time", "windowName", "appDir"]
	
	if !(str && info)
		return tagList
	else if (info = "strip") {
		str := StrReplace(str, "$appDir", A_ScriptDir)
		minPos := StrLen(str)
		for c, v in tagList
			if (pos:=InStr(str, "$" v))
				minPos := pos < minPos ? pos-1 : minPos
		str := SubStr(str, 1, minPos)
		str := RegExReplace(StrReplace(str, "\\", "\"), "\\$")
		while (!FileExist(str) && str)
			str := RegExReplace(str, "(.+)\\.+$", "$1")
		return str
	}
	
	tags := { date:       TimeStamp()
			, fileName:   info.filename
			, filePath:   info.filepath
			, rssNum:     RegExMatch(info.filename, "i)((?:RSS[-|_|\s]?\d{3,4}(?:-\d+)?)|(?:(?:CS|SS)[\s-_]?\d{3}))", m) ? m1 : (info.filename ? info.fileName : "Unknown RSS #")
			, time:       TimeStamp("h:mm tt")
			, windowName: info.name
			, appDir:     A_ScriptDir }
	
	for c, v in tags
		str := RegExReplace(str, "i)\$" c, v)
	return RegExReplace(RegExReplace(str, "\\$"), "\.\w{2,4}")
}

TimeStamp(format:="yyyy-MM-dd") {
	FormatTime, tstamp, A_Now, % format
	return tstamp
}

TrayMenu() {
	Menu, AhkStdMenu, Add
	Menu, AhkStdMenu, Delete
	Menu, AhkStdMenu, Standard
	Menu, Tray, NoStandard
	
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		Menu, Tray, Add, % ea.description (hk.text ? "`t(" ConvertHotkey(hk.text) ")" : ""), % ea.name
	
	Menu, Tray, Add
	Menu, Tray, Add, Export Settings to File, BackupSettings
	Menu, Tray, Add, Import Settings from File, ImportSettings
	if (!A_IsCompiled) {
		Menu, Tray, Add
		Menu, Tray, Add, Default AHK Menu, :AhkStdMenu
	}
	Menu, Tray, Add
	Menu, Tray, Add, Check for Update, CheckForUpdate
	Menu, Tray, Add
	Menu, Tray, Add, Reload
	Menu, Tray, Add, Exit
	
	tDefault   := s.ssn("//trayclick/@default").text
	tDefaultHK := s.ssn("//hotkeys/cmd[@description='" tDefault "']").text
	Menu, Tray, Default, % tDefault (tDefaultHK ? "`t(" ConvertHotkey(tDefaultHK) ")" : "")
	
	if (A_IsCompiled)
		Menu, Tray, Icon, %A_ScriptFullPath%, -159
	else {
		if (!FileExist(ico:=A_ScriptDir "\DVScreenPrinter.ico"))
			URLDownloadToFile, http://tv.wsnhapps.com/DVScreenPrinter/DVScreenPrinter.ico, %ico%
		Menu, Tray, Icon, % FileExist(ico) ? ico : ""
	}
	TrayTip()
}

TrayTip() {
	txt := "DV Screen Printer " (Version ? "v" Version " ":"") (A_IsAdmin ? "(Admin) ":"") "`n"
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk)
		txt .= hk.text ? "<" ConvertHotkey(hk.text) "> - " ea.description "`n" : ""
	txt .= "`nD-Click Icon: " s.ea("//trayclick").default
	Menu, Tray, Tip, % txt
}

UpdateSettings() {
	static extList := "JPG,GIF,PNG,BMP,TIFF"
		 , tkList  := "Edit Settings|Capture DV Wins|Close all DV Wins|Open Captures Dir"
		 , hkList  := {Capture:"Capture DV Wins"
					 , EditSettings:"Edit Settings"
					 , CloseDVWins:"Close all DV Wins"
					 , OpenCaptureDir:"Open Captures Dir"}
	
	;Extensions
	if (s.sn("//options/extensions/*").Length != StrSplit(extList, ",").MaxIndex()) {
		exts:=s.ssn("//options/extensions"), exts.ParentNode.RemoveChild(exts), opts:=s.ssn("//options"), exts:=s.under(opts, "extensions")
		for c, v in StrSplit(extList, ",")
			s.under(exts, "ext",, v)
	}
	
	;TrayClick
	if (s.ssn("//trayclick").text != tkList)
		s.ssn("//trayclick").text := Trim(tkList)
	tDefault:=s.ssn("//trayclick/@default").text
	if tDefault not in % StrReplace(tkList, "|", ",")
		s.ssn("//trayclick/@default").text := StrSplit(tkList,"|")[1]
	
	;Hotkeys
	curHks:=[]
	while, hk:=s.sn("//hotkeys/cmd").Item[A_Index-1], ea:=xml.ea(hk) { ;#[TODO: Add hotkeys that don't currently exist]
		curHks[ea.name] := hk.text
		if (!ea.description || ea.description!=hkList[ea.name])
			s.ssn("//hotkeys/cmd[@name='" ea.name "']/@description").text := hkList[ea.name]
	}
	hks := s.ssn("//hotkeys")
	for c, v in hkList
		if (s.ssn("//hotkeys/cmd[@name='" c "']/@description").text != v)
			s.under(hks, "cmd", {description:v, name:c}, curHks[c]?curHks[c]:"", "description,name")
	hks := ""
	
	;GUI Style
	if (!s.ssn("//style/header/@size").text) {
		style := s.add2("style", {background:"F5F5F5", control:"White", color:"Blue", font:"Segoe UI"})
		s.under(style, "header", {size:10})
		s.under(style, "label", {size:8})
	}
	s.save(1)
}