#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3

global s:=new xml("settings", A_AppData "\DVScreenPrinter\settings.xml")

info = %1%
CheckCredentials(info, 1)
if (info)
	TrayTip, DVScreenPrinter, `nRunning as Admin..., 1, 1
if (!s.fileExists)
	DefaultSettings()
else
	UpdateSettings()

if (!FileExist(A_ScriptDir "\gdiplus.dll") && A_IsCompiled)
	FileInstall, gdiplus.dll, %A_ScriptDir%\gdiplus.dll
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
#Include <CMBox>
#Include <ConvertHotkey>
#Include <DefaultSettings>
#Include <EditSettings>
#Include <Exit>
#Include <Gdip>
#Include <GetWinList>
#Include <Hotkeys>
#Include <ImportSettings>
#Include <m>
#Include <MenuAction>
#Include <RegisterHotkeys>
#Include <Reload>
#Include <Restore>
#Include <SettingHeader>
#Include <ssn>
#Include <Tags>
#Include <TimeStamp>
#Include <TrayMenu>
#Include <TrayTip>
#Include <UpdateSettings>