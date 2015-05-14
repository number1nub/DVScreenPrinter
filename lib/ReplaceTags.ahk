ReplaceTags(str, win:="") {
	FormatTime, date, A_Now, yyyy-MM-dd
	FormatTime, time, A_Now, h:mm tt
	fName := win.fileName
	tags := {windowName: win.name
		   , filePath: win.filepath
		   , fileName: win.filename
		   , rssNum: RegExMatch(win.filepath,"i)(RSS[-|_|\s]?\d{4})",m) ? m1 : "RSS????"
		   , date: date
		   , time: time}
	;~ , RSS: RegExMatch(win.filepath,"i)(?<=\\|_)(RSS\d+)(?=\\|_)",m) ? m1 : RSS
	;~ , date: win ? date : ""
	;~ , time: win ? time : ""}
	
	for c, v in tags
		str := RegExReplace(str, "i)\$" c, v)	
	return RegExReplace(RegExReplace(str, "\\$"), "\.\w{2,4}")
}