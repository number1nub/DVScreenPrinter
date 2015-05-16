Tags(str:="", info:="") {
	static tagList := ["date", "fileName", "filePath", "rssNum", "time", "windowName"]
	
	if !(str && info)
		return tagList
	else if (info = "strip")
		for c, v in tagList
			if RegExMatch(str, "i)^(.*)\$" v, m_)
				return m_1
	
	tags := { date:       TimeStamp()
			, fileName:   info.filename
			, filePath:   info.filepath
			, rssNum:     RegExMatch(info.filepath, "i)(RSS[-|_|\s]?\d{4})", m) ? m1 : "RSS????"
			, time:       TimeStamp("h:mm tt")
			, windowName: info.name }
	
	for c, v in tags
		str := RegExReplace(str, "i)\$" c, v)
	return RegExReplace(RegExReplace(str, "\\$"), "\.\w{2,4}")
}