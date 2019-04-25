Global $CaptureDLL = ("captdll.dll")
$Path = IniRead("gen\xy.ini", "MAP", "Path", "default")
$X = IniRead("gen\xy.ini", "MAP", "X", "default")
$Y = IniRead("gen\xy.ini", "MAP", "Y", "default")
$Width = IniRead("gen\xy.ini", "MAP", "Width", "default")
$Height = IniRead("gen\xy.ini", "MAP", "Height", "default")
$ClientProcess = IniRead("gen\xy.ini", "CLIENT", "Process", "default")

If Not _WinActiveByExe($ClientProcess, True) Then
	_WinActiveByExe($ClientProcess, False)
EndIf

DllCall($CaptureDLL, "int", "CaptureRegion", "str", $Path, "int", $X, "int", $Y, "int", $Width, "int", $Height, "int", -1)

Func _WinActiveByExe($sExe, $iActive = True)
    If Not ProcessExists($sExe) Then Return SetError(1, 0, 0)
    Local $aPL = ProcessList($sExe)
    Local $aWL = WinList()
    For $iCC = 1 To $aWL[0][0]
        For $xCC = 1 To $aPL[0][0]
            If $aWL[$iCC][0] <> '' And _
                WinGetProcess($aWL[$iCC][1]) = $aPL[$xCC][1] And _
                BitAND(WinGetState($aWL[$iCC][1]), 2) Then
                If $iActive And WinActive($aWL[$iCC][1]) Then Return 1
                If Not $iActive And Not WinActive($aWL[$iCC][1]) Then
                    WinActivate($aWL[$iCC][1])
                    Return 1
                EndIf
            EndIf
        Next
    Next
    Return SetError(2, 0, 0)
EndFunc