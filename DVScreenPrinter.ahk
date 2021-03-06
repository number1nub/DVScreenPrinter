#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3

if (isAdmin:=CheckCredentials(%true%))
	if (%true% != "silent")
		TrayTip, DVScreenPrinter, `nRunning as Admin..., 1, 1

global version, s:=new xml("settings", A_AppData "\DVScreenPrinter\settings.xml")

version = ;auto_version
s.fileExists ? UpdateSettings() : DefaultSettings()
if (!FileExist(A_ScriptDir "\gdiplus.dll") && A_IsCompiled) {
	FileInstall, C:\Windows\System32\gdiplus.dll, %A_ScriptDir%\gdiplus.dll
}
TrayMenu()
RegisterHotkeys()
CheckUpdate()
return



#Include <Activate>
#Include <BackupSettings>
#Include <Capture>
#Include <CheckCredentials>
#Include <CheckUpdate>
#Include <class Xml>
#Include <CloseDVWins>
#Include <CMBox>
#Include <ConvertHotkey>
#Include <DefaultSettings>
#Include <EditSettings>
#Include <Exit>
#Include <Gdi>
#Include <GetWinList>
#Include <Hotkeys>
#Include <ImportSettings>
#Include <m>
#Include <OpenCaptureDir>
#Include <RegisterHotkeys>
#Include <Reload>
#Include <Restore>
#Include <SettingHeader>
#Include <Tags>
#Include <TimeStamp>
#Include <TrayMenu>
#Include <TrayTip>
#Include <UpdateSettings>