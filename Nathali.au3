#NoTrayIcon

;threading: https://www.autoitscript.com/forum/topic/184096-authread-multi-thread-emulation-forking-for-autoit/
;imagesearch: https://www.youtube.com/watch?v=Hy-va-155HY
;mousepos: https://www.autoitscript.com/autoit3/docs/functions/MouseGetPos.htm
;pixelgetcolor: https://www.autoitscript.com/autoit3/docs/functions/PixelGetColor.htm
;ini files: https://www.autoitscript.com/autoit3/docs/functions/IniRead.htm
;mysql driver: https://dev.mysql.com/downloads/connector/odbc/3.51.html

#include-once
#include <gen\Nathalib.au3>
#include <ImageSearch.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Date.au3>
#include <Array.au3>
#include <ScreenCapture.au3>
#include <gen\EzMySql.au3>
#include <APIDiagConstants.au3>
#include <Crypt.au3>
#include <StringConstants.au3>
#include <Misc.au3>

Global $Settings_Loaded = False

HotKeySet("{PAUSE}","PauseBot")
HotKeySet("{HOME}","ResumeBot")
HotKeySet("{END}","Quit")
HotKeySet("t","TestFunc")

Global $BotVersion = "1"

Global $DEBUG_MODE = False
Global $mouseXY[2] = MouseGetPos()
Global $FoodXY[2]
Global $BlankRuneXY[2]
Global $FreeHandXY[2]
Global $BattleListXY[2]
Global $DisconnectedXY[2]
Global $CharacterXY[2]
Global $HealthBarXY[2]
Global $MapCrossXY[2]

Global $SSpath = "gen\map.bmp"
Global $SSX1
Global $SSY1
Global $SSWidth = 0
Global $SSWidth = 0

Global Const $clrHealthFull = "0x00BC00"
Global Const $clrHealthGreen = "0x50A150"
Global Const $clrHealthYellow = "0xA1A100"
Global Const $clrHealthRed = "0xBF0A0A"
Global Const $clrAntiCheatYellow = "0xFEF100"
Global Const $clrAntiCheatOrange = "0xFFF200"
Global Const $clrChatRed = "0xF55E5E"
Global Const $clrChatPM = "0x5FF7F7"

Global $ClientProcess
Global $WindowTitle

Global Const $DanceInterval = 1
Global Const $EatInterval = 1

Global $DATEDance = 0
Global $DATEEat = 0
Global $DATESpellCast = 0

Global $Paused = False
Global $DanceCompleted = False
Global $EatCompleted = False
Global $SpellCastCompleted = False

; [0][] = Play Sound [1][] = Logout [2][] = Exit Client [3][] = Pause Bot [4][] = Close Bot

; [][0] = BattleListChanged [][1] = Disconnected [][2] = Attacked [][3] = Elementals
; [][4] = Moved [][5] = OutOfRunes [][6] = BotClosed [][7] = AntiBot
Global $AlertsConfig[5][8]

$SQLDriver = 'MySQL ODBC 3.51 Driver'
$SQLServer = "localhost"
$SQLDatabase = 'nathalibot'
$SQLPort = '3306'
$SQLUser = 'root'
$SQLPassword = 'okxcVz2ZcXY3tgJP'
$MD5Pass = "MD5"
$HWID = _GetHardwareID($UHID_All)
;id,name,userpass,premdays,hwid,group_id

#Region ### LOGIN START ###
$LoginForm = GUICreate("Nathali Bot", 282, 227, 192, 124)
GUISetIcon("C:\Users\kuhi\Desktop\Nathali Bot\bot.ico", -1)
$Username = GUICtrlCreateInput("", 80, 64, 121, 21)
$Password = GUICtrlCreateInput("", 80, 144, 121, 21, $ES_PASSWORD)
$Login = GUICtrlCreateButton("Login", 104, 176, 75, 25)
$LBLUsername = GUICtrlCreateLabel("Username:", 96, 24, 94, 29)
GUICtrlSetFont(-1, 14, 400, 0, "MV Boli")
GUICtrlSetColor(-1, 0x000000)
$LBLPassword = GUICtrlCreateLabel("Password:", 96, 112, 91, 29)
GUICtrlSetFont(-1, 14, 400, 0, "MV Boli")
GUICtrlSetColor(-1, 0x000000)
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Login
			If GUICtrlRead($Username) = "" And GUICtrlRead($Password) = "" Then
				ExitLoop
			EndIf
			If Not _EzMySql_Startup() Then
				MsgBox(0, "Error Starting MySql", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
				Exit
			EndIf

			If Not _EzMySql_Open($SQLServer, $SQLUser, $SQLPassword, $SQLDatabase, $SQLPort) Then
				MsgBox(0, "Error opening Database", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
				Exit
			EndIf

			$query = "SELECT * FROM accounts WHERE name='" & GUICtrlRead($Username) & "' AND userpass='" & GUICtrlRead($Password) & "'"
			If Not _EzMYSql_Query($query) Then
			MsgBox(0, "Query Error", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
				Exit
			EndIf

			For $i = 1 To _EzMySql_Rows() Step 1
				$a1Row = _EzMySql_FetchData()
				;_ArrayDisplay($a1Row)
				;MsgBox(0,"DATA",$a1Row[1])
			Next

			If Not $a1Row[4] Then
				;create hwid
				$query = "UPDATE accounts SET hwid='" & $HWID & "' WHERE name='" & GUICtrlRead($Username) & "' AND userpass='" & GUICtrlRead($Password) & "'"
				If Not _EzMYSql_Query($query) Then
					MsgBox(0, "Query Error", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
					Exit
				EndIf
				MsgBox(0,"HWID","Your HWID has been updated." & @LF & "Bot will be closed.")
				Exit
			EndIf

			If $a1Row[4] = $HWID Then
				ExitLoop
			EndIf

			If Not $a1Row[4] = $HWID Then
				MsgBox(16,"ERROR","Your account is registered on another computer.")
				Exit
			EndIf
	EndSwitch
	If _IsPressed("0D") Then
		If GUICtrlRead($Username) = "" And GUICtrlRead($Password) = "" Then
			ExitLoop
		EndIf
		If Not _EzMySql_Startup() Then
			MsgBox(0, "Error Starting MySql", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
			Exit
		EndIf

		If Not _EzMySql_Open($SQLServer, $SQLUser, $SQLPassword, $SQLDatabase, $SQLPort) Then
			MsgBox(0, "Error opening Database", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
			Exit
		EndIf

		$query = "SELECT * FROM accounts WHERE name='" & GUICtrlRead($Username) & "' AND userpass='" & GUICtrlRead($Password) & "'"
		If Not _EzMYSql_Query($query) Then
		MsgBox(0, "Query Error", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
			Exit
		EndIf

		For $i = 1 To _EzMySql_Rows() Step 1
			$a1Row = _EzMySql_FetchData()
			;_ArrayDisplay($a1Row)
			;MsgBox(0,"DATA",$a1Row[1])
		Next

		If Not $a1Row[4] Then
			;create hwid
			$query = "UPDATE accounts SET hwid='" & $HWID & "' WHERE name='" & GUICtrlRead($Username) & "' AND userpass='" & GUICtrlRead($Password) & "'"
			If Not _EzMYSql_Query($query) Then
				MsgBox(0, "Query Error", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
				Exit
			EndIf
			MsgBox(0,"HWID","Your HWID has been updated." & @LF & "Bot will be closed.")
			Exit
		EndIf

		If $a1Row[4] = $HWID Then
			ExitLoop
		EndIf

		If Not $a1Row[4] = $HWID Then
			MsgBox(16,"ERROR","Your account is registered on another computer.")
			Exit
		EndIf
	EndIf
WEnd
#EndRegion ### END OF LOGIN ###

#Region ### BOT GUI START ### Form=c:\users\kuhi\desktop\nathali bot\form2.kxf
$Form1_1 = GUICreate("Nathali Bot v1", 243, 320, 381, 213)
$Tab1 = GUICtrlCreateTab(16, 16, 217, 257)
$TabSheet1 = GUICtrlCreateTabItem("Runemaker")
$Dance = GUICtrlCreateCheckbox("Dance", 44, 61, 129, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$SpellWords = GUICtrlCreateInput("Spell to cast", 44, 181, 105, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$Interval = GUICtrlCreateInput("Seconds", 156, 181, 57, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$EatFood = GUICtrlCreateCheckbox("Eat Food", 44, 93, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$SpellCaster = GUICtrlCreateCheckbox("Spell caster", 44, 157, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$RuneToHand = GUICtrlCreateCheckbox("Move blank rune to hand", 44, 221, 169, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$FoodName = GUICtrlCreateCombo("Brown Mushroom", 44, 117, 153, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Dragon Ham|Egg|Fire Mushroom|Fish|Ham|Meat|White Mushroom")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$TabSheet2 = GUICtrlCreateTabItem("Alerts")
$chkBattleListChanged = GUICtrlCreateCheckbox("Battle List Changed", 60, 61, 121, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkDisconnected = GUICtrlCreateCheckbox("Disconnected", 60, 77, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkAttacked = GUICtrlCreateCheckbox("Attacked", 60, 93, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkElements = GUICtrlCreateCheckbox("Fire / Energy / Poison", 60, 109, 121, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkMoved = GUICtrlCreateCheckbox("Moved", 60, 125, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkOutOfRunes = GUICtrlCreateCheckbox("Out Of Runes", 60, 141, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkBotClosed = GUICtrlCreateCheckbox("Bot Closed", 60, 157, 97, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$chkAntiBot = GUICtrlCreateCheckbox("AntiBot", 60, 173, 121, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$lblActions = GUICtrlCreateLabel("Actions", 60, 201, 39, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$ActionsCombo = GUICtrlCreateCombo("Play Sound", 60, 221, 121, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Logout|Exit Client|Pause Bot|Close Bot")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlCreateTabItem("")
$Output = GUICtrlCreateLabel("Here will be printed all debug info.", 44, 290, 171, 17)
GUISetState(@SW_SHOW)

GUIDelete($LoginForm)
#EndRegion ### END OF BOT GUI ###

;If Not $a1Row[4] = $HWID Then
	;Exit
;EndIf

;OutputMSG($a1Row[3] & " days left.")

Func CheckBoxIsChecked($control)
 Return BitAnd(GUICtrlRead($control),$GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func TestFunc()
Local $winPos = WinGetPos($WindowTitle)
$clrTest = "0x375916"
If ActivateWindow() Then
	$coords = PixelSearch( 0, 0, $winPos[2], $winPos[3], $clrTest, 2, 1)
EndIf
If not $coords Then
	MsgBox(0,"COORDS","NOT CORDS")
Else
	MouseMove($coords[0], $coords[1])
EndIf
EndFunc

Settings()

#Region ### GUI LOOP START ###
; LOOP ALL CONTROLS
Func BaseLoop()
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit
			Case $chkBattleListChanged
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkBattleListChanged) Then
							$AlertsConfig[0][0] = True
						Else
							$AlertsConfig[0][0] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[1][0] = True
						Else
							$AlertsConfig[1][0] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[2][0] = True
						Else
							$AlertsConfig[2][0] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[3][0] = True
						Else
							$AlertsConfig[3][0] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[4][0] = True
						Else
							$AlertsConfig[4][0] = False
						EndIf
				EndSwitch
			Case $chkDisconnected
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[0][1] = True
						Else
							$AlertsConfig[0][1] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[1][1] = True
						Else
							$AlertsConfig[1][1] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[2][1] = True
						Else
							$AlertsConfig[2][1] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[3][1] = True
						Else
							$AlertsConfig[3][1] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkDisconnected) Then
							$AlertsConfig[4][1] = True
						Else
							$AlertsConfig[4][1] = False
						EndIf
				EndSwitch
			Case $chkAttacked
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkAttacked) Then
							$AlertsConfig[0][2] = True
						Else
							$AlertsConfig[0][2] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkAttacked) Then
							$AlertsConfig[1][2] = True
						Else
							$AlertsConfig[1][2] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkAttacked) Then
							$AlertsConfig[2][2] = True
						Else
							$AlertsConfig[2][2] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkAttacked) Then
							$AlertsConfig[3][2] = True
						Else
							$AlertsConfig[3][2] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkAttacked) Then
							$AlertsConfig[4][2] = True
						Else
							$AlertsConfig[4][2] = False
						EndIf
				EndSwitch
			Case $chkElements
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkElements) Then
							$AlertsConfig[0][3] = True
						Else
							$AlertsConfig[0][3] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkElements) Then
							$AlertsConfig[1][3] = True
						Else
							$AlertsConfig[1][3] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkElements) Then
							$AlertsConfig[2][3] = True
						Else
							$AlertsConfig[2][3] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkElements) Then
							$AlertsConfig[3][3] = True
						Else
							$AlertsConfig[3][3] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkElements) Then
							$AlertsConfig[4][3] = True
						Else
							$AlertsConfig[4][3] = False
						EndIf
				EndSwitch
			Case $chkMoved
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkMoved) Then
							$AlertsConfig[0][4] = True
						Else
							$AlertsConfig[0][4] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkMoved) Then
							$AlertsConfig[1][4] = True
						Else
							$AlertsConfig[1][4] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkMoved) Then
							$AlertsConfig[2][4] = True
						Else
							$AlertsConfig[2][4] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkMoved) Then
							$AlertsConfig[3][4] = True
						Else
							$AlertsConfig[3][4] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkMoved) Then
							$AlertsConfig[4][4] = True
						Else
							$AlertsConfig[4][4] = False
						EndIf
				EndSwitch
			Case $chkOutOfRunes
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkOutOfRunes) Then
							$AlertsConfig[0][5] = True
						Else
							$AlertsConfig[0][5] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkOutOfRunes) Then
							$AlertsConfig[1][5] = True
						Else
							$AlertsConfig[1][5] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkOutOfRunes) Then
							$AlertsConfig[2][5] = True
						Else
							$AlertsConfig[2][5] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkOutOfRunes) Then
							$AlertsConfig[3][5] = True
						Else
							$AlertsConfig[3][5] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkOutOfRunes) Then
							$AlertsConfig[4][5] = True
						Else
							$AlertsConfig[4][5] = False
						EndIf
				EndSwitch
			Case $chkBotClosed
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkBotClosed) Then
							$AlertsConfig[0][6] = True
						Else
							$AlertsConfig[0][6] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkBotClosed) Then
							$AlertsConfig[1][6] = True
						Else
							$AlertsConfig[1][6] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkBotClosed) Then
							$AlertsConfig[2][6] = True
						Else
							$AlertsConfig[2][6] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkBotClosed) Then
							$AlertsConfig[3][6] = True
						Else
							$AlertsConfig[3][6] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkBotClosed) Then
							$AlertsConfig[4][6] = True
						Else
							$AlertsConfig[4][6] = False
						EndIf
				EndSwitch
			Case $chkAntiBot
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If CheckBoxIsChecked($chkAntiBot) Then
							$AlertsConfig[0][7] = True
						Else
							$AlertsConfig[0][7] = False
						EndIf
					Case "Logout"
						If CheckBoxIsChecked($chkAntiBot) Then
							$AlertsConfig[1][7] = True
						Else
							$AlertsConfig[1][7] = False
						EndIf
					Case "Exit Client"
						If CheckBoxIsChecked($chkAntiBot) Then
							$AlertsConfig[2][7] = True
						Else
							$AlertsConfig[2][7] = False
						EndIf
					Case "Pause Bot"
						If CheckBoxIsChecked($chkAntiBot) Then
							$AlertsConfig[3][7] = True
						Else
							$AlertsConfig[3][7] = False
						EndIf
					Case "Close Bot"
						If CheckBoxIsChecked($chkAntiBot) Then
							$AlertsConfig[4][7] = True
						Else
							$AlertsConfig[4][7] = False
						EndIf
				EndSwitch


			Case $ActionsCombo
				Switch GUICtrlRead($ActionsCombo)
					Case "Play Sound"
						If $AlertsConfig[0][0] Then
							GUICtrlSetState($chkBattleListChanged, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBattleListChanged, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][1] Then
							GUICtrlSetState($chkDisconnected, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkDisconnected, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][2] Then
							GUICtrlSetState($chkAttacked, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAttacked, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][3] Then
							GUICtrlSetState($chkElements, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkElements, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][4] Then
							GUICtrlSetState($chkMoved, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkMoved, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][5] Then
							GUICtrlSetState($chkOutOfRunes, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkOutOfRunes, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][6] Then
							GUICtrlSetState($chkBotClosed, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBotClosed, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[0][7] Then
							GUICtrlSetState($chkAntiBot, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAntiBot, $GUI_UNCHECKED)
						EndIf
					Case "Logout"
						If $AlertsConfig[1][0] Then
							GUICtrlSetState($chkBattleListChanged, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBattleListChanged, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][1] Then
							GUICtrlSetState($chkDisconnected, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkDisconnected, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][2] Then
							GUICtrlSetState($chkAttacked, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAttacked, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][3] Then
							GUICtrlSetState($chkElements, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkElements, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][4] Then
							GUICtrlSetState($chkMoved, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkMoved, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][5] Then
							GUICtrlSetState($chkOutOfRunes, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkOutOfRunes, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][6] Then
							GUICtrlSetState($chkBotClosed, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBotClosed, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[1][7] Then
							GUICtrlSetState($chkAntiBot, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAntiBot, $GUI_UNCHECKED)
						EndIf
					Case "Exit Client"
						If $AlertsConfig[2][0] Then
							GUICtrlSetState($chkBattleListChanged, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBattleListChanged, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][1] Then
							GUICtrlSetState($chkDisconnected, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkDisconnected, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][2] Then
							GUICtrlSetState($chkAttacked, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAttacked, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][3] Then
							GUICtrlSetState($chkElements, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkElements, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][4] Then
							GUICtrlSetState($chkMoved, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkMoved, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][5] Then
							GUICtrlSetState($chkOutOfRunes, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkOutOfRunes, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][6] Then
							GUICtrlSetState($chkBotClosed, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBotClosed, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[2][7] Then
							GUICtrlSetState($chkAntiBot, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAntiBot, $GUI_UNCHECKED)
						EndIf
					Case "Pause Bot"
						If $AlertsConfig[3][0] Then
							GUICtrlSetState($chkBattleListChanged, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBattleListChanged, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][1] Then
							GUICtrlSetState($chkDisconnected, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkDisconnected, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][2] Then
							GUICtrlSetState($chkAttacked, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAttacked, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][3] Then
							GUICtrlSetState($chkElements, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkElements, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][4] Then
							GUICtrlSetState($chkMoved, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkMoved, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][5] Then
							GUICtrlSetState($chkOutOfRunes, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkOutOfRunes, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][6] Then
							GUICtrlSetState($chkBotClosed, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBotClosed, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[3][7] Then
							GUICtrlSetState($chkAntiBot, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAntiBot, $GUI_UNCHECKED)
						EndIf
					Case "Close Bot"
						If $AlertsConfig[4][0] Then
							GUICtrlSetState($chkBattleListChanged, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBattleListChanged, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][1] Then
							GUICtrlSetState($chkDisconnected, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkDisconnected, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][2] Then
							GUICtrlSetState($chkAttacked, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAttacked, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][3] Then
							GUICtrlSetState($chkElements, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkElements, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][4] Then
							GUICtrlSetState($chkMoved, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkMoved, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][5] Then
							GUICtrlSetState($chkOutOfRunes, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkOutOfRunes, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][6] Then
							GUICtrlSetState($chkBotClosed, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkBotClosed, $GUI_UNCHECKED)
						EndIf
						If $AlertsConfig[4][7] Then
							GUICtrlSetState($chkAntiBot, $GUI_CHECKED)
						Else
							GUICtrlSetState($chkAntiBot, $GUI_UNCHECKED)
						EndIf
				EndSwitch

		EndSwitch
		If Not $Paused Then
			;LOOP THE BOT
			Alerts()
			Dance()
			eatFood()
			SpellCaster()
		EndIf
	WEnd
EndFunc
BaseLoop()
Exit
#EndRegion ### END OF GUI LOOP ###

; ############
; ### GAME ###
; ############

; ### ALERTS ###
Func Alerts()
;CHECK BATTLE LIST
If $AlertsConfig[0][0] Or $AlertsConfig[1][0] Or $AlertsConfig[2][0] Or $AlertsConfig[3][0] Or $AlertsConfig[4][0] Then
	OutputMSG("Checking battle list.")
	$BattleListFile = "images\Battle List.png"
	If Not FileExists($BattleListFile) Then
		msgbox(16,"ERROR","Can't find \" & $BattleListFile)
		Exit
	EndIf
	If _FindImage($BattleListFile, $BattleListXY[0], $BattleListXY[1]) Then
		OutputMSG("Battle List is clean.")
	Else
		;Battle list changed
		If $AlertsConfig[0][0] Then
			PlaySound("sounds\Battle List.mp3")
		EndIf
		If $AlertsConfig[1][0] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][0] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][0] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][0] Then
			Exit
		EndIf
	EndIf
EndIf

;CHECK DISCONNECTED
If $AlertsConfig[0][1] Or $AlertsConfig[1][1] Or $AlertsConfig[2][1] Or $AlertsConfig[3][1] Or $AlertsConfig[4][1] Then
	OutputMSG("Check if disconnected.")
	$DisconnectedFile = "images\Disconnected.png"
	If Not FileExists($DisconnectedFile) Then
		msgbox(16,"ERROR","Can't find \" & $DisconnectedFile)
		Exit
	EndIf
	If _FindImage($DisconnectedFile, $DisconnectedXY[0], $DisconnectedXY[1]) Then
		OutputMSG("Connection status ONLINE.")
	Else
		;Disconnected
		If $AlertsConfig[0][1] Then
			PlaySound("sounds\Disconnected.mp3")
		EndIf
		If $AlertsConfig[1][1] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][1] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][1] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][1] Then
			Exit
		EndIf
	EndIf
EndIf

;CHECK ATTACKED
If $AlertsConfig[0][2] Or $AlertsConfig[1][2] Or $AlertsConfig[2][2] Or $AlertsConfig[3][2] Or $AlertsConfig[4][2] Then
	OutputMSG("Check if attacked.")
	; Find health and see if changed bar
	$HealthBarFile = "images\Health Bar.png"
	If Not FileExists($HealthBarFile) Then
		MsgBox(16,"ERROR","Can't find \" & $HealthBarFile)
		Exit
	EndIf
	If Not _FindImage($HealthBarFile, $HealthBarXY[0], $HealthBarXY[1]) Then
		;Health changed
		If $AlertsConfig[0][2] Then
			PlaySound("sounds\Attacked.mp3")
		EndIf
		If $AlertsConfig[1][2] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][2] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][2] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][2] Then
			Exit
		EndIf
	EndIf
EndIf

;CHECK ELEMENTALS
If $AlertsConfig[0][3] or $AlertsConfig[1][3] or $AlertsConfig[2][3] or $AlertsConfig[3][3] or $AlertsConfig[4][3] Then
	OutputMSG("Checking elementals.")
	;Fields
	$PoisonFieldFile = "images\Poison.png"
	$FireFieldFile = "images\Fire.png"
	$EnergyFieldFile = "images\Energy.png"

	;Stats
	$PoisonStatFile = "images\PoisonStat.png"
	$EnergyStatFile = "images\EnergyStat.png"
	$FireStatFile = "images\FireStat.png"

	;Auxiliar pointer
	Local $aux[2]

	;Check files
	If Not FileExists($PoisonFieldFile) Then
		msgbox(16,"ERROR","Unable to find \" & $PoisonFieldFile)
		Exit
	EndIf
	If Not FileExists($FireFieldFile) Then
		msgbox(16,"ERROR","Unable to find \" & $FireFieldFile)
		Exit
	EndIf
	If Not FileExists($EnergyFieldFile) Then
		msgbox(16,"ERROR","Unable to find \" & $EnergyFieldFile)
		Exit
	EndIf
	If Not FileExists($PoisonStatFile) Then
		msgbox(16,"ERROR","Unable to find \" & $PoisonStatFile)
		Exit
	EndIf
	If Not FileExists($EnergyStatFile) Then
		msgbox(16,"ERROR","Unable to find \" & $EnergyStatFile)
		Exit
	EndIf
	If Not FileExists($FireStatFile) Then
		msgbox(16,"ERROR","Unable to find \" & $FireStatFile)
		Exit
	EndIf

	;Search images
	If _FindImage($PoisonFieldFile,$aux[0],$aux[1]) Or _FindImage($FireFieldFile,$aux[0],$aux[1]) Or _FindImage($EnergyFieldFile,$aux[0],$aux[1]) Or _FindImage($PoisonStatFile,$aux[0],$aux[1]) Or _FindImage($FireStatFile,$aux[0],$aux[1]) Or _FindImage($EnergyStatFile,$aux[0],$aux[1]) Then
		;Energy Status!
		If $AlertsConfig[0][3] Then
			PlaySound("sounds\Elementals.mp3")
		EndIf
		If $AlertsConfig[1][3] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][3] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][3] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][3] Then
			Exit
		EndIf
	EndIf
EndIf

;CHECK MOVED
If $AlertsConfig[0][4] Or $AlertsConfig[1][4] Or $AlertsConfig[2][4] Or $AlertsConfig[3][4] Or $AlertsConfig[4][4] Then
	OutputMSG("Checking if moved.")
	$image_map = "images\cross.png"
	If Not FileExists($image_map) Then
		MsgBox(16,"ERROR","Unable to find \" & $image_map)
	EndIf
	If _FindImage($image_map, $MapCrossXY[0], $MapCrossXY[1]) Then
		If FileExists($SSpath) Then
			$filetime = FileGetTime($SSpath)
			If $filetime[3] <> @HOUR Then
				FileDelete($SSpath)
				$FileUpdated = False
			Else
				$FileUpdated = True
			EndIf
		EndIf
		If ActivateWindow() Then
			;take map position and capture around
			If _FindImage($image_map, $MapCrossXY[0], $MapCrossXY[1]) Then
				$SSX1 = ($MapCrossXY[0] - 20)
				$SSY1 = ($MapCrossXY[1] - 20)
				If Not FileExists("gen\xy.ini") Then
					IniWrite("gen\xy.ini", "MAP", "Path", $SSpath)
					IniWrite("gen\xy.ini", "MAP", "X", $SSX1)
					IniWrite("gen\xy.ini", "MAP", "Y", $SSY1)
					IniWrite("gen\xy.ini", "MAP", "Width", "50")
					IniWrite("gen\xy.ini", "MAP", "Height", "50")
					IniWrite("gen\xy.ini", "CLIENT", "Process", $ClientProcess)
				EndIf
				OutputMSG("Taking map screenshot.")
				If Not FileExists($SSpath) Then
					ShellExecute("gen\ScreenCapture.exe")
					While Not FileExists($SSpath)
						Sleep(100)
					WEnd
				EndIf
			EndIf

			;check if moved
			If Not _FindImage($SSpath, $SSX1, $SSY1) Then
				;Moved
				If $AlertsConfig[0][4] Then
					PlaySound("sounds\Moved.mp3")
				EndIf
				If $AlertsConfig[1][4] Then
					LogoutClient()
				EndIf
				If $AlertsConfig[2][4] Then
					ProcessClose($ClientProcess)
				EndIf
				If $AlertsConfig[3][4] Then
					PauseBot()
				EndIf
				If $AlertsConfig[4][4] Then
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

;CHECK OUT OF RUNES
If $AlertsConfig[0][5] Or $AlertsConfig[1][5] Or $AlertsConfig[2][5] Or $AlertsConfig[3][5] Or $AlertsConfig[4][5] Then
	OutputMSG("Checking blank runes.")
	$BlankRuneFile = "images\Blank Rune.png"
	Local $BlankX = 0
	Local $BlankY = 0

	If ActivateWindow() Then
		If Not _FindImage($BlankRuneFile, $BlankX, $BlankY) Then
			;No Blank Runes
			If $AlertsConfig[0][5] Then
				PlaySound("sounds\Out Of Runes.mp3")
			EndIf
			If $AlertsConfig[1][5] Then
				LogoutClient()
			EndIf
			If $AlertsConfig[2][5] Then
				ProcessClose($ClientProcess)
			EndIf
			If $AlertsConfig[3][5] Then
				PauseBot()
			EndIf
			If $AlertsConfig[4][5] Then
				Exit
			EndIf
		EndIf
	EndIf
EndIf

;CHECK CLIENT CLOSED
If $AlertsConfig[0][6] Or $AlertsConfig[1][6] Or $AlertsConfig[2][6] Or $AlertsConfig[3][6] Or $AlertsConfig[4][6] Then
	OutputMSG("Checking if game closed.")
	If Not ProcessExists($PID) Then
		;Client not found
		If $AlertsConfig[0][6] Then
			PlaySound("sounds\Client Closed.mp3")
		EndIf
		If $AlertsConfig[1][6] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][6] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][6] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][6] Then
			Exit
		EndIf
	EndIf
EndIf

;CHECK ANTI BOT
If $AlertsConfig[0][7] Or $AlertsConfig[1][7] Or $AlertsConfig[2][7] Or $AlertsConfig[3][7] Or $AlertsConfig[4][7] Then
	OutputMSG("Checking antibot.")
	Local $winPos = WinGetPos($WindowTitle)
	If ActivateWindow() Then
		$coords1 = PixelSearch( 0, 0, $winPos[2], $winPos[3], $clrAntiCheatOrange, 2, 1)
		$coords2 = PixelSearch( 0, 0, $winPos[2], $winPos[3], $clrAntiCheatYellow, 2, 1)
	EndIf
	If $coords1 Or $coords2 Then
		;ANTIBOT DETECTED
		If $AlertsConfig[0][7] Then
			PlaySound("sounds\Anti Cheat.mp3")
		EndIf
		If $AlertsConfig[1][7] Then
			LogoutClient()
		EndIf
		If $AlertsConfig[2][7] Then
			ProcessClose($ClientProcess)
		EndIf
		If $AlertsConfig[3][7] Then
			PauseBot()
		EndIf
		If $AlertsConfig[4][7] Then
			Exit
		EndIf
	EndIf
EndIf

;OutputMSG("All alerts checked.")
EndFunc

; ### DANCE ###
Func Dance()
If CheckBoxIsChecked($Dance) Then
	OutputMSG("Into dance function.")
	If $DATEDance = 0 And $DanceCompleted = False Then
		$DATEDance = _NowTime(5)
		$DATEDance = _DateAdd("m",$DanceInterval,$DATEDance)
	EndIf
	If $DATEDance >= _NowTime(5) And $DanceCompleted = False Then
		If ActivateWindow() Then
			OutputMSG("Simulating keyboard...")
			sleep(100)
			Send("^{UP}")
			sleep(100)
			Send("^{DOWN}")
			sleep(100)
			Send("^{LEFT}")
			sleep(100)
			Send("^{RIGHT}")
			sleep(100)
			$DanceCompleted = True
		Else
			msgbox(16, "ERROR", "Unable to focus game client!")
			Exit
		EndIf
	EndIf
	If $DATEDance >= _NowTime(5) And $DanceCompleted = True Then
		$DanceCompleted = False
		$DATEDance = _NowTime(5)
		$DATEDance = _DateAdd("m",$DanceInterval,$DATEDance)
	EndIf
EndIf
EndFunc

; ### EAT FOOD ###
Func eatFood()
If CheckBoxIsChecked($EatFood) Then
	OutputMSG("Into eat food function.")
	$Food = GUICtrlRead($FoodName)
	;Check if food image exists
	$FoodFile = "images\" & $Food & ".png"

	IF FileExists($FoodFile) Then
		If $DATEEat = 0 And $EatCompleted = False Then
			$DATEEat = _NowTime(5)
			$DATEEat = _DateAdd("m", $EatInterval, $DATEEat)
		EndIf
		If $DATEEat >= _NowTime(5) And $EatCompleted = False Then
			If ActivateWindow() Then
				OutputMSG("Simulating mouse...")
				$result = _FindImage($FoodFile,$FoodXY[0],$FoodXY[1])
				If $result Then
					MouseMove($FoodXY[0],$FoodXY[1])
					MouseClick("right",$FoodXY[0],$FoodXY[1],5,10)
					$EatCompleted = True
				Else
					MsgBox(16,"ERROR","Can't find the food ingame!")
				EndIf
			Else
				msgbox(16, "ERROR", "Unable to focus game client!")
				Exit
			EndIf
		EndIf
	Else
		MsgBox(16,"ERROR","Can't find " & $Food & ".png")
		Exit
	EndIf

	If $DATEEat >= _NowTime(5) And $EatCompleted = True Then
		$EatCompleted = False
		$DATEEat = _NowTime
		$DATEEat = _DateAdd("m", $EatInterval, $DATEEat)
	EndIf
EndIf
EndFunc

; ### SPELL CASTER ###
Func SpellCaster()
If CheckBoxIsChecked($SpellCaster) Then
	OutputMSG("Into spell caster function.")
	$SpellCastInterval = GUICtrlRead($Interval)

	Local $isRune = False

	If Not CheckBoxIsChecked($RuneToHand) Then
		$isRune = False
	Else
		$isRune = True
		$RuneFile = "images\Blank Rune.png"
		If FileExists($RuneFile) Then
			OutputMSG("Image " & $RuneFile " & loaded.")
		Else
			MsgBox(16,"ERROR","Unable to load \images\Blank Rune.png")
			Exit
		EndIf
	EndIf

	If $DATESpellCast = 0 And $SpellCastCompleted = False Then
		$DATESpellCast = _NowTime(5)
		$DATESpellCast = _DateAdd("s", $SpellCastInterval, $DATESpellCast)
	EndIf

	If $DATESpellCast >= _NowTime(5) And $SpellCastCompleted = False Then
		If ActivateWindow() Then
			OutputMSG("Casting spell...")
			If $isRune Then
				If _FindBlankRune($BlankRuneXY[0],$BlankRuneXY[1]) Then
					If _FindHand($FreeHandXY[0],$FreeHandXY[1]) Then
						;MouseMove($BlankRuneXY[0],$BlankRuneXY[1])
						MouseClickDrag("left",$BlankRuneXY[0],$BlankRuneXY[1],$FreeHandXY[0],$FreeHandXY[1],10)
						Sleep(100)
						local $spell = GUICtrlRead($SpellWords)
						Send($spell)
						Send("{ENTER}")
						Sleep(100)
						MouseClickDrag("left",$FreeHandXY[0],$FreeHandXY[1],$BlankRuneXY[0],$BlankRuneXY[1],10)
						Sleep(100)
						$SpellCastCompleted = True
					Else
						MsgBox(16,"ERROR","Can't find a free hand!")
					EndIf
				Else
					MsgBox(16,"ERROR","Can't find blank runes ingame.")
				EndIf
			Else
				Send($spell)
				Send("{ENTER}")
				Sleep(100)
			EndIf
		Else
			msgbox(16, "ERROR", "Unable to focus game client!")
			Exit
		EndIf
	EndIf

	If $DATESpellCast >= _NowTime(5) And $SpellCastCompleted = True Then
		$SpellCastCompleted = False
		$DATESpellCast = _NowTime
		$DATESpellCast = _DateAdd("s", $SpellCastInterval, $DATESpellCast)
	EndIf
EndIf
EndFunc

; ### LOGOUT ###
Func LogoutClient()
OutputMSG("Into logout function.")
ActivateWindow()
Send("^q")
EndFunc
#EndRegion ### Game end ###

#Region ### FIND PLAYER AND DEFINE COORDS ###
Func SetPlayerXY()
OutputMSG("Calculating character X/Y...")
Global $player = WinGetPos($WindowTitle)
msgbox(0,"INFO",$player[0] & $player[1] & $player[2] & $player[3])
$CharacterXY[0] = ($player[2]/2)-100
$CharacterXY[1] = ($player[3]/2)-50
EndFunc
#EndRegion

Func KeyTest()
$imageresult = _FindImage("images\Brown Mushroom.png",$FoodXY[0],$FoodXY[1])
If $imageresult = 1 Then
	MouseMove($FoodXY[0],$FoodXY[1],50)
EndIf
EndFunc

#Region ### SETTINGS ###
Func Settings()
If Not $Settings_Loaded Then
	OutputMSG("Into settings function.")
	If Not FileExists("settings.ini") Then
		;GENERAL
		IniWrite("settings.ini", "GENERAL", "Title", "Nathali Bot")
		IniWrite("settings.ini", "GENERAL", "Version", $BotVersion)
		IniWrite("settings.ini", "GENERAL", "Author", "Kuhi")
		IniWrite("settings.ini", "GENERAL", "Website", "www.kuhiscripts.com")

		;CLIENT
		$WindowTitle = "MasterCores"
		IniWrite("settings.ini", "CLIENT", "Window", "MasterCores")
		$ClientProcess = "client_dx.exe"
		IniWrite("settings.ini", "CLIENT", "Process", "client_dx.exe")

		;DEBUG
		IniWrite("settings.ini", "DEBUG", "DEBUG_MODE", "False")

		;PLAYER
		IniWrite("settings.ini", "PLAYER", "Reset XY", "True")
		IniWrite("settings.ini", "PLAYER", "X", $CharacterXY[0])
		IniWrite("settings.ini", "PLAYER", "Y", $CharacterXY[1])
		msgbox(64,"SETTINGS","Settings.ini file created." & @LF & "Bot will close.")
		Exit
	Else
		;CLIENT
		$WindowTitle = IniRead("settings.ini", "CLIENT", "Window", "default")
		$ClientProcess = IniRead("settings.ini", "CLIENT", "Process", "default")

		;DEBUG
		$DEBUG_MODE = IniRead("settings.ini", "DEBUG", "DEBUG_MODE", "default")

		;PLAYER
		If IniRead("settings.ini", "PLAYER", "Reset XY", "default") = "True" Then
			If FindTibia() Then
				OutputMSG("Calculating character X/Y...")
				$player = WinGetPos($WindowTitle)
				;MsgBox(0,"",$WindowTitle)
				;_ArrayDisplay($player)
				$CharacterXY[0] = ($player[2]/2)-100
				$CharacterXY[1] = ($player[3]/2)-50
			EndIf
		Else
			$CharacterXY[0] = IniRead("settings.ini", "PLAYER", "X", "default")
			$CharacterXY[1] = IniRead("settings.ini", "PLAYER", "Y", "default")
		EndIf
	EndIf
	If FileExists("gen\xy.ini") Then
		$SSpath = IniRead("gen\xy.ini", "MAP", "Path", "default")
		$SSX1 = IniRead("gen\xy.ini", "MAP", "X", "default")
		$SSY1 = IniRead("gen\xy.ini", "MAP", "Y", "default")
		$SSWidth = IniRead("gen\xy.ini", "MAP", "Width", "default")
		$SSWidth = IniRead("gen\xy.ini", "MAP", "Height", "default")
	EndIf
	$Settings_Loaded = True
	OutputMSG("Bot ready.")
EndIf
EndFunc
#EndRegion

#Region ### PLAY SOUND / STOP SOUND ###
Func PlaySound($sound)
OutputMSG("Into play sound function.")
WinFlash($WindowTitle)
SoundPlay($sound)
EndFunc
#EndRegion

#Region ### OUTPUT MSG START ###
Func OutputMSG($msg)
	GUICtrlSetData($Output,$msg)
EndFunc
#EndRegion ### END OF OUTPUT MSG ###

#Region ### PAUSE/RESUME BOT ###
Func PauseBot()
$Paused = True
EndFunc
Func ResumeBot()
$Paused = False
EndFunc
#EndRegion

#Region ### WINDOW ACTIVATE ###
Func ActivateWindow()
OutputMSG("Into activate window function.")
If Not _WinActiveByExe($ClientProcess, True) Then
		_WinActiveByExe($ClientProcess, False)
	EndIf
If _WinActiveByExe($ClientProcess, True) Then
	Return True
Else
	Return False
EndIf
EndFunc
#EndRegion

#Region ### FIND PROCESS START ###
Func FindTibia()
OutputMSG("Finding Tibia process.")
$PID = ProcessExists($ClientProcess)
If $PID = 0 Then
	msgbox(16, "ERROR", "Unable to find a Tibia process!")
	Exit
Else
	$WindowTitle = _WinGetByPID($PID)
	If $WindowTitle Then
		OutputMSG("Client found at PID " & $PID & ".")
		Return True
	Else
		msgbox(16, "ERROR", "Unable to find Tibia window name!")
		Exit
	EndIf
EndIf
EndFunc
#EndRegion ### END OF FIND PROCESS ###

#Region ### END ###
Func Quit()
	Exit
EndFunc

#Region ### HWID ###
Func _GetHardwareID($iFlags = Default, $bIs64Bit = Default)
    Local $sBit = @AutoItX64 ? '64' : ''

    If IsBool($bIs64Bit) Then
        ; Use 64-bit if $bIs64Bit is true and AutoIt is a 64-bit process; otherwise 32-bit
        $sBit = $bIs64Bit And @AutoItX64 ? '64' : ''
    EndIf

    If $iFlags == Default Then
        $iFlags = $UHID_MB
    EndIf

    Local $aSystem = ['Identifier', 'VideoBiosDate', 'VideoBiosVersion'], _
            $iResult = 0, _
            $sHKLM = 'HKEY_LOCAL_MACHINE' & $sBit, $sOutput = '', $sText = ''

    For $i = 0 To UBound($aSystem) - 1
        $sOutput &= RegRead($sHKLM & '\HARDWARE\DESCRIPTION\System\', $aSystem[$i])
    Next
    $sOutput &= @CPUArch
    $sOutput = StringStripWS($sOutput, $STR_STRIPALL)

    If BitAND($iFlags, $UHID_BIOS) Then
        Local $aBIOS = ['BaseBoardManufacturer', 'BaseBoardProduct', 'BaseBoardVersion', 'BIOSVendor', 'BIOSReleaseDate']
        $sText = ''
        For $i = 0 To UBound($aBIOS) - 1
            $sText &= RegRead($sHKLM & '\HARDWARE\DESCRIPTION\System\BIOS\', $aBIOS[$i])
        Next
        $sText = StringStripWS($sText, $STR_STRIPALL)
        If $sText Then
            $iResult += $UHID_BIOS
            $sOutput &= $sText
        EndIf
    EndIf

    If BitAND($iFlags, $UHID_CPU) Then
        Local $aProcessor = ['ProcessorNameString', '~MHz', 'Identifier', 'VendorIdentifier']

        $sText = ''
        For $i = 0 To UBound($aProcessor) - 1
            $sText &= RegRead($sHKLM & '\HARDWARE\DESCRIPTION\System\CentralProcessor\0\', $aProcessor[$i])
        Next

        For $i = 0 To UBound($aProcessor) - 1
            $sText &= RegRead($sHKLM & '\HARDWARE\DESCRIPTION\System\CentralProcessor\1\', $aProcessor[$i])
        Next

        $sText = StringStripWS($sText, $STR_STRIPALL)
        If $sText Then
            $iResult += $UHID_CPU
            $sOutput &= $sText
        EndIf
    EndIf

    If BitAND($iFlags, $UHID_HDD) Then
        Local $aDrives = DriveGetDrive('FIXED')

        $sText = ''
        For $i = 1 To UBound($aDrives) - 1
            $sText &= DriveGetSerial($aDrives[$i])
        Next

        $sText = StringStripWS($sText, $STR_STRIPALL)
        If $sText Then
            $iResult += $UHID_HDD
            $sOutput &= $sText
        EndIf
    EndIf

    Local $sHash = StringTrimLeft(_Crypt_HashData($sOutput, $CALG_MD5), StringLen('0x'))
    If Not $sHash Then
        Return SetError(1, 0, Null)
    EndIf

    Return SetExtended($iResult, StringRegExpReplace($sHash, '([[:xdigit:]]{8})([[:xdigit:]]{4})([[:xdigit:]]{4})([[:xdigit:]]{4})([[:xdigit:]]{12})', '{\1-\2-\3-\4-\5}'))
EndFunc
#EndRegion ### HWID ###

BaseLoop()
Exit
#EndRegion ### END ###
