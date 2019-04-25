#include <MsgBoxConstants.au3>

HotKeySet("m","MousePos")

Global $mouseXY[2] = MouseGetPos()

While 1
	Sleep(500)
WEnd

Func MousePos()
	$mouseXY = MouseGetPos()
	$iColor = PixelGetColor($mouseXY[0],$mouseXY[1])
	$iColor = hex($iColor)
	MsgBox(0,"COLOR",$iColor)
EndFunc