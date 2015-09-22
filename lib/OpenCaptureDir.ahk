OpenCaptureDir() {
	dir := Tags(s.ssn("//save/@dir").text, "strip")
	if (FileExist(dir))
		Run, explore "%dir%"
	else
		m("Unable to locate/open capture folder.", "ico:!")
}