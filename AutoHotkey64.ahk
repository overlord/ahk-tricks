#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
; ----------------------------------!---------------------------------------------
SendMode("Input")          ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir) ; Ensures a consistent starting directory.
; ----------------------------------!---------------------------------------------
INI := A_ScriptDir . "\config.ini"
if !FileExist(INI) {
	MsgBox("Config not found: " . INI, "Error", 16)
	ExitApp()
}
; --
LOGIN_SHORT := IniRead(INI, "Credentials", "Login")
LOGIN_LONG  := IniRead(INI, "Credentials", "Domain") . "\" . LOGIN_SHORT
PASS        := IniRead(INI, "Credentials", "Pass")
VPNCODE     := IniRead(INI, "Credentials", "VpnCode")
; --
PORTABLE_DIR   := IniRead(INI, "Paths", "PortableDir")
PROJECTS_DIR   := IniRead(INI, "Paths", "ProjectsDir")
WORK_NOTES_DIR := IniRead(INI, "Paths", "WorkNotesDir")
USER_DIR       := EnvGet("USERPROFILE")
; ----------------------------------!---------------------------------------------
; ^ Ctrl, ! Alt, + Shift, # Win
; ------------------------------
#1::ActivateOrMinimizeMany(["devenv.exe", "code.exe"])
#2::ActivateOrMinimizeMany(["sublime_text.exe", "code.exe"], PORTABLE_DIR . "\Sublime Text\sublime_text.exe")
#3::ActivateOrMinimizeMany(["ssms.exe", "dbeaver.exe"])
#4::ActivateOrMinimizeMany(["sublime_merge.exe", "sourcetree.exe"], PORTABLE_DIR . "\Sublime Merge\sublime_merge.exe")
#5::ActivateOrMinimize("RoslynPad.exe", PORTABLE_DIR . "\RoslynPad\RoslynPad.exe")
; ------------------------------
; сраная тильда ~ и её сканкод SC029 (для потомков)
#SC029::ActivateOrMinimize("mstsc.exe", "mstsc.exe")
^+SC029::SendText("@")
; ------------------------------
#F1::Run(WORK_NOTES_DIR . "\#work.txt")
#F2::Run(WORK_NOTES_DIR . "\#think-CUST-INV.txt")
#F3::Run(WORK_NOTES_DIR . "\#think-POE-PolicyEngine-BLK-M2M.txt")
#F4::Run(WORK_NOTES_DIR . "\#think-FORIS.txt")
#F5::Run(WORK_NOTES_DIR . "\#think-PROD.txt")
#F6::Run(WORK_NOTES_DIR . "\#think-TIAM.txt")
#F12::Run(PORTABLE_DIR . "\AutoHotkey\AutoHotkey64.ahk")
#N::Run(USER_DIR . "\.nuget\packages")
#P::Run(PROJECTS_DIR)
; ------------------------------
#C::ActivateOrMinimizeConsole()
+#C::NewConsole()
#V::PasteCredentials()
^+#P::PastePass()
; ------------------------------
#D::ActivateOrMinimizeMany(["Rocket.Chat.exe"])
#F::ActivateOrMinimizeMany(["TeleLink.exe", "МТС Линк.exe"])
#Q::ActivateOrMinimizeMany(["launcher.exe", "Opera.exe", "Chrome.exe"])
#S::ActivateOrMinimizeMany(["lync.exe", "Skype.exe"])
#T::ActivateOrMinimizeMany(["max.exe", "Telegram.exe"])
#W::ActivateOrMinimize("outlook.exe")
; ------------------------------
; ремапинг верхних кнопок клавиатуры
; Volume_Mute::Send("{PrintScreen}")
; Volume_Down::Send("{ScrollLock}")
; Volume_Up::Send("{Pause}")
Volume_Mute::PrintScreen
Volume_Down::ScrollLock
Volume_Up::Pause
; ----------------------------------!---------------------------------------------
SendTab() {
	Sleep(200)
	Send("{tab}")
	Sleep(200)
}
; ------------------------------
; !_! Специальный метод посимвольной вставки - применяется для вставки кредов на странных формах
SendByChar(s_text, delay := 25) {
	Sleep(200)
	Loop Parse, s_text {
		Sleep(delay)
		SendInput(A_LoopField)
	}
}
; ------------------------------
ActivateOnly(exe) {
	h_title := "ahk_exe " . exe
	if WinExist(h_title) {
		if not WinActive(h_title) {
			WinActivate(h_title)
		}
		return true
	}
	return false
}
; ------------------------------
ActivateOrMinimize(exe, run_exe := "") {
	h_title := "ahk_exe " . exe

	if WinActive(h_title) {
		WinMinimize(h_title)
		return true
	}

	if WinExist(h_title) {
		WinActivate(h_title)
		; WinMaximize(h_title)
		return true
	}

	if run_exe != "" {
		Run(run_exe)
		return true
	}

	return false
}
; ------------------------------
ActivateOrMinimizeMany(executables, run_exe := "") {
	for exe in executables {
		if ActivateOrMinimize(exe)
			return true
	}

	if run_exe != "" {
		Run(run_exe)
		return true
	}

	return false
}
; ------------------------------
GetCurrentPath(default_path) {
		if WinGetClass("A") != "CabinetWClass"
				return default_path
		shell := ComObject("Shell.Application") ; Получаем путь активного окна Explorer через COM
		currentPath := default_path
		for window in shell.Windows {
				if window.HWND = WinGetID("A") {
						currentPath := window.Document.Folder.Self.Path
						break
				}
		}
		return currentPath
}
; ------------------------------
ActivateOrMinimizeConsole() {
	if not ActivateOrMinimizeMany(["wt.exe", "WindowsTerminal.exe", "mintty.exe", "ConEmu64.exe", "cmd.exe", "powershell.exe"]) {
		currentPath := GetCurrentPath(PROJECTS_DIR)
		SetWorkingDir(currentPath)
		Run(PORTABLE_DIR . "\WindowsTerminal\WindowsTerminal.exe")
	}
}
; ------------------------------
NewConsole() {
	currentPath := GetCurrentPath(PROJECTS_DIR)
	SetWorkingDir(currentPath)
	Run(PORTABLE_DIR . "\WindowsTerminal\WindowsTerminal.exe")
}
; ------------------------------
PasteCredentials() {
	KeyWait("LWin", "L")
	title := WinGetTitle("A")
	if InStr(title, "Cisco AnyConnect |") {
		ControlSetText(LOGIN_SHORT, "Edit1", "A")
		ControlSetText(VPNCODE, "Edit2", "A")
		ControlSend("{enter}", "Edit2", "A")
	} else if InStr(title, "Безопасность Windows") {
		Send(LOGIN_LONG)
		SendTab()
		SendByChar(PASS)
	} else if InStr(title, "Cisco AnyConnect Login") {
		Send(LOGIN_SHORT)
		SendTab()
		SendByChar(PASS)
	} else if InStr(title, "Citrix Workspace") {
		Send(LOGIN_SHORT)
		SendTab()
		SendByChar(PASS)
		SendTab()
		Send(VPNCODE)
		SendTab()
	} else {
		; MsgBox("Active Window: " . title)
		Send(LOGIN_LONG)
		SendTab()
		SendByChar(PASS)
	}
}
; ------------------------------
PastePass() {
	KeyWait("LWin", "L")
	Send(PASS)
}
