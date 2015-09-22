#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3

if (isAdmin:=CheckCredentials(%true%))
	if (%true% != "silent")
		TrayTip, DVScreenPrinter, `nRunning as Admin..., 1, 1

global s:=new xml("settings", A_AppData "\DVScreenPrinter\settings.xml")

s.fileExists ? UpdateSettings() : DefaultSettings()
if (!FileExist(A_ScriptDir "\gdiplus.dll") && A_IsCompiled)
	FileInstall, gdiplus.dll, %A_ScriptDir%\gdiplus.dll
TrayMenu()
RegisterHotkeys()
CheckUpdate()
return



#Include lib\Activate.ahk
#Include lib\BackupSettings.ahk
#Include lib\Capture.ahk
#Include lib\CheckCredentials.ahk
#Include lib\CheckUpdate.ahk
#Include lib\class Xml.ahk
#Include lib\CloseDVWins.ahk
#Include lib\CMBox.ahk
#Include lib\ConvertHotkey.ahk
#Include lib\DefaultSettings.ahk
#Include lib\EditSettings.ahk
#Include lib\Exit.ahk
#Include lib\Gdi.ahk
#Include lib\GetWinList.ahk
#Include lib\Hotkeys.ahk
#Include lib\ImportSettings.ahk
#Include lib\m.ahk
#Include lib\OpenCaptureDir.ahk
#Include lib\RegisterHotkeys.ahk
#Include lib\Reload.ahk
#Include lib\Restore.ahk
#Include lib\SettingHeader.ahk
#Include lib\Tags.ahk
#Include lib\TimeStamp.ahk
#Include lib\TrayMenu.ahk
#Include lib\TrayTip.ahk
#Include lib\UpdateSettings.ahk