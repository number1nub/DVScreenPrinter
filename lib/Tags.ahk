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
		return RegExReplace(StrReplace(str, "\\", "\"), "\\$")
	}
	
	tags := { date:       TimeStamp()
			, fileName:   info.filename
			, filePath:   info.filepath
			, rssNum:     RegExMatch(info.filepath, "i)RSS[-|_|\s]*?(\d{4})", m) ? m1 : "RSS????"
			, time:       TimeStamp("h:mm tt")
			, windowName: info.name
			, appDir:     A_ScriptDir }
	
	for c, v in tags
		str := RegExReplace(str, "i)\$" c, v)
	return RegExReplace(RegExReplace(str, "\\$"), "\.\w{2,4}")
}