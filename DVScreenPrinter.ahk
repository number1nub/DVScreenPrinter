#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 3
OnExit("Exit")

global s:=new xml("settings", A_AppData "\DVScreenPrinter\settings.xml")

if (!s.fileExists)
	DefaultSettings()
;else
;UpdateSettings()
if (FileExist("minicap"))
	FileDelete, minicap
TrayMenu()
if (!FileExist(A_ScriptDir "\gdiplus.dll") && A_IsCompiled)
	FileInstall, gdiplus.dll, %A_ScriptDir%\gdiplus.dll
RegisterHotkeys()
CheckUpdate()
return


#Include <Activate>
#Include <BackupSettings>
#Include <Capture>
#Include <CheckUpdate>
#Include <class Xml>
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
#Include <ssn>
#Include <Tags>
#Include <TimeStamp>
#Include <TrayMenu>
#Include <TrayTip>
#Include <UpdateSettings>