; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn     ; Enable warnings to assist with detecting common errors.
; #WinActivateForce

SendMode("Input")          ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir) ; Ensures a consistent starting directory.

; ----------------------------------!---------------------------------------------
LOGIN_SHORT := "-----"
LOGIN_LONG := "admsk\" . LOGIN_SHORT
PASS := "-----"
VPNCODE := "-----"
; ------------------------------
PORTABLE_DIR := "D:\Portable"
PROJECTS_DIR := "D:\Projects"
WORK_NOTES_DIR := "D:\Work-Notes"
USER_DIR := EnvGet("USERPROFILE")

; ----------------------------------!---------------------------------------------
#1::ActivateOnly("devenv.exe")
#2::ActivateOrMinimizeMany("sublime_text.exe code.exe", PORTABLE_DIR . "\Sublime Text\sublime_text.exe")
#3::ActivateOrMinimizeMany("ssms.exe dbeaver.exe")
#4::ActivateOrMinimizeMany("sublime_merge.exe sourcetree.exe", PORTABLE_DIR . "\Sublime Merge\sublime_merge.exe")
#5::ActivateOrMinimize("RoslynPad.exe", PORTABLE_DIR . "\RoslynPad\RoslynPad.exe")
; ------------------------------
#`::ActivateOrMinimize("mstsc.exe", "mstsc.exe")
#F1::Run(WORK_NOTES_DIR . "\#work.txt")
#F2::Run(WORK_NOTES_DIR . "\#think-POE-Policy-Engine.txt")
#F3::Run(WORK_NOTES_DIR . "\#think-Woody-Dispatcher.txt")
#F4::Run(WORK_NOTES_DIR . "\#think-TIAM.txt")
#F5::Run(PORTABLE_DIR . "\AutoHotkey\AutoHotkey64.ahk")
#N::Run(USER_DIR . "\.nuget\packages")
; ------------------------------
#C::ActivateOrMinimizeConsole()
+#C::NewConsole()
#D::ActivateOrMinimizeMany("Rocket.Chat.exe")
#Q::ActivateOrMinimizeMany("launcher.exe Opera.exe Chrome.exe")
#S::ActivateOrMinimize("Skype.exe")
#T::ActivateOrMinimizeMany("Telegram.exe")
#W::ActivateOrMinimize("outlook.exe")
#V::PasteCredentials()
; ------------------------------
#X:: { ; test
  Loop Parse, "Azaza  Za", " " {
    MsgBox(A_LoopField)
  }
}

; ------------------------------
; фикс верхних кнопок клавиатуры
Volume_Mute::Send("{PrintScreen}")
+Volume_Mute::Send("+{PrintScreen}")
Volume_Down::Send("{ScrollLock}")
Volume_Up::Send("{Pause}")
+Volume_Up::Send("+{Pause}")

; ----------------------------------!---------------------------------------------
SendTab() {
  Sleep(200)
  Send("{tab}")
  Sleep(200)
}
; ------------------------------
SendByChar(s_text) {
  Sleep(200)
  Loop Parse, s_text, "" {
    Sleep(25)
    Send(A_LoopField)
  }
}
; ------------------------------
PasteString(s_text) {
  saved := ClipboardAll()
  A_Clipboard := s_text
  ; MsgBox(A_Clipboard)
  SendInput("^v")
  A_Clipboard := saved
  saved := ""
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

  if not (run_exe = "") {
    Run(run_exe)
    return true
  }

  return false
}
; ------------------------------
ActivateOrMinimizeMany(executables, run_exe := "") {
  Loop Parse, executables, " " {
    if ActivateOrMinimize(A_LoopField)
      return true
  }

  if not (run_exe = "") {
    Run(run_exe)
    return true
  }

  return false
}
; ------------------------------
GetCurrentPath(default_path) {
  explorerClass := WinGetClass("A")
  if (explorerClass = "CabinetWClass") {
    currentPath := WinGetTitle("ahk_class " . explorerClass)
  } else {
    currentPath := default_path
  }
  ; MsgBox("Path: " . currentPath) ; !!! DEBUG
  return currentPath
}
; ------------------------------
ActivateOrMinimizeConsole() {
  if not ActivateOrMinimizeMany("wt.exe WindowsTerminal.exe mintty.exe ConEmu64.exe cmd.exe powershell.exe") {
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
