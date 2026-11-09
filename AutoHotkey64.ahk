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
; ideApps := AppSwitcher(["devenv.exe", "code.exe"])
; editorApps := AppSwitcher(["sublime_text.exe", "code.exe"], PORTABLE_DIR . "\Sublime Text\sublime_text.exe")
; sqlApps := AppSwitcher(["ssms.exe", "plsqldev.exe", "dbeaver.exe"])
; gitApps := AppSwitcher(["sublime_merge.exe", "sourcetree.exe"], PORTABLE_DIR . "\Sublime Merge\sublime_merge.exe")
; --
; #1::ideApps.Toggle()
; #2::editorApps.Toggle()
; #3::sqlApps.Toggle()
; #4::gitApps.Toggle()
; --
$#1::ActivateOrMinimize(["devenv.exe", "code.exe"])
$#2::ActivateOrMinimize(["sublime_text.exe", "code.exe"], PORTABLE_DIR . "\Sublime Text\sublime_text.exe")
$#3::ActivateOrMinimize(["dbeaver.exe", "ssms.exe"])
$#4::ActivateOrMinimize(["sublime_merge.exe", "sourcetree.exe"], PORTABLE_DIR . "\Sublime Merge\sublime_merge.exe")
$#5::ActivateOrMinimize(["plsqldev.exe"])
; ------------------------------
; сраная тильда ~ и её сканкод SC029 (для потомков)
#SC029::ActivateOrMinimize(["mstsc.exe"], "mstsc.exe")
^+SC029::SendText("@")
; ------------------------------
#F1::MyRun(WORK_NOTES_DIR . "\#work.txt")
#F2::MyRun(WORK_NOTES_DIR . "\#think-CUST-INV.txt")
#F3::MyRun(WORK_NOTES_DIR . "\#think-POE-PolicyEngine-BLK-M2M.txt")
#F4::MyRun(WORK_NOTES_DIR . "\#think-FORIS.txt")
#F5::MyRun(WORK_NOTES_DIR . "\#think-PROD.txt")
#F6::MyRun(WORK_NOTES_DIR . "\#think-TIAM.txt")
#F12::MyRun(PORTABLE_DIR . "\AutoHotkey\AutoHotkey64.ahk")
#N::MyRun(USER_DIR . "\.nuget\packages")
#P::MyRun(PROJECTS_DIR)
; ------------------------------
#C::ActivateOrMinimizeConsole()
+#C::NewConsole()
#V::PasteCredentials()
^+#P::PastePass()
; ------------------------------
#D::ActivateOrMinimize(["Rocket.Chat.exe"])
#F::ActivateOrMinimize(["TeleLink.exe", "МТС Линк.exe"])
#Q::ActivateOrMinimize(["launcher.exe", "Opera.exe", "Chrome.exe"])
#S::ActivateOrMinimize(["lync.exe", "Skype.exe"])
#T::ActivateOrMinimize(["max.exe", "Telegram.exe"])
#W::ActivateOrMinimize(["outlook.exe"])
; ------------------------------
; ремапинг верхних кнопок клавиатуры
; Volume_Mute::Send("{PrintScreen}")
; Volume_Down::Send("{ScrollLock}")
; Volume_Up::Send("{Pause}")
Volume_Mute::PrintScreen
Volume_Down::ScrollLock
Volume_Up::Pause
; ----------------------------------!---------------------------------------------
Class AppSwitcher {
	__New(executables, run_exe := "", timeout := 300) {
		this.executables := executables
		this.run_exe := run_exe
		this.timeout := timeout
		this.last_exe := ""
		this.waiting := false ; признак ожидания второго нажатия

		; Важно: привязываем метод к контексту 'this', чтобы SetTimer корректно работал с объектом
		this.callback := this.Invoke1.Bind(this)
	}

	; Главная точка входа при нажатии на хоткей
	Toggle() {
		if this.waiting {
			this.waiting := false
			SetTimer(this.callback, 0)
			this.Invoke2()
		} else {
			this.all_exe := ExistingAll(this.executables)

			if this.all_exe.Length < 1 {
				(this.run_exe != "") && MyRun(this.run_exe)
				return
			}

			this.active_exe := ActiveFirst(this.executables)

			this.waiting := true
			SetTimer(this.callback, -this.timeout)
		}
	}

	Invoke1() { ; Одиночное нажатие (срабатывает по таймеру)
		this.waiting := false

		if this.active_exe != "" {
			this.last_exe := this.active_exe
			MyMinimize(this.active_exe)
		}
		else {
			(this.last_exe = "") && this.last_exe := this.all_exe[1]
			MyActivate(this.last_exe)
		}
	}

	Invoke2() { ; Двойное нажатие (срабатывает мгновенно, если успели нажать второй раз)
		this.waiting := false

		if this.active_exe != "" {
			this.last_exe := this.active_exe
			MyMinimize(this.active_exe)
		}

		i := IndexOf(this.all_exe, this.last_exe)
		i := (i > 0 && i < this.all_exe.Length) ? i + 1 : 1
		this.last_exe := this.all_exe[i]

		(this.last_exe != this.active_exe) && MyActivate(this.last_exe)
	}
}
; ----------------------------------!---------------------------------------------
; !_! Специальный метод посимвольной вставки - применяется для вставки кредов на странных формах
SendByChar(s_text, delay := 25) {
	Sleep(200)
	Loop Parse, s_text {
		Sleep(delay)
		SendInput(A_LoopField)
	}
}
; --
SendTab(delay := 200) {
	Sleep(delay)
	Send("{tab}")
	Sleep(delay)
}
; ------------------------------
IndexOf(items, item) {
	for idx, str in items {
		if (str = item) {
			return idx
		}
	}
	return 0 ; не найдено
}
; ------------------------------
ActiveFirst(executables) {
	for exe in executables {
		if WinActive("ahk_exe " . exe) {
			return exe
		}
	}
	return ""
}
; --
IsActiveAny(executables) {
	return ActiveFirst(executables) != ""
}
; --
ExistingAll(executables) {
	found := []
	for exe in executables {
		if WinExist("ahk_exe " . exe) {
			found.Push(exe)
		}
	}
	return found
}
; --
ExistingFirst(executables) {
	found := ExistingAll(executables)
	if found.Length > 0 {
		return found[1] ; первый
	}
	return ""
}
; ------------------------------
MyMinimize(exe) {
	WinMinimize("ahk_exe " . exe)
}
; --
MyActivate(exe) {
	WinActivate("ahk_exe " . exe)
}
; --
MyRun(exe) {
	try {
		Run(exe)
		return true
	} catch as err {
		MsgBox("Failed to run: " . exe . "`n" . err.Message, "Error", 16)
		return false
	}
}
; ------------------------------
ActivateOnly(exe) {
	existing := ExistingFirst([exe])
	h_title := "ahk_exe " . exe
	if existing != "" {
		active_exe := ActiveFirst([exe])
		if active_exe = "" {
			MyActivate(exe)
		}
		return true
	}
	return false
}
; --
ActivateOrMinimize(executables, run_exe := "") {
	active_exe := ActiveFirst(executables)
	if active_exe != "" {
		MyMinimize(active_exe)
		return true
	} else {
		existing := ExistingFirst(executables)
		if existing != "" {
			MyActivate(existing)
			return true
		}
		else if run_exe != "" {
			return MyRun(run_exe)
		}
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
	shell := ""
	return currentPath
}
; ------------------------------
ActivateOrMinimizeConsole() {
	if not ActivateOrMinimize(["wt.exe", "WindowsTerminal.exe", "mintty.exe", "ConEmu64.exe", "cmd.exe", "powershell.exe"]) {
		NewConsole()
	}
}
; ------------------------------
NewConsole() {
	currentPath := GetCurrentPath(PROJECTS_DIR)
	SetWorkingDir(currentPath)
	MyRun(PORTABLE_DIR . "\WindowsTerminal\WindowsTerminal.exe")
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
	KeyWait("LWin")
	KeyWait("Ctrl")
	KeyWait("Shift")
	SendText(PASS)
}
