; #FUNCTION# ====================================================================================================================
; Name ..........: CheckTombs.au3
; Description ...: This file Includes function to perform defense farming.
; Syntax ........:
; Parameters ....: None
; Return values .: False if regular farming is needed to refill storage
; Author ........: barracoda/KnowJack (2015)
; Modified ......: sardo (05-2015/06-2015) , ProMac (04-2016), MonkeyHuner (06-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func CheckTombs()
	Local $aTombs = QuickMIS("CNX", $g_sImgClearTombs, $InnerDiamondLeft, $InnerDiamondTop, $InnerDiamondRight, $InnerDiamondBottom)
	If IsArray($aTombs) And UBound($aTombs) > 0 Then
		For $i = 0 To UBound($aTombs) - 1
			If isInsideDiamondXY($aTombs[$i][1], $aTombs[$i][2]) Then 
				Click($aTombs[$i][1], $aTombs[$i][2])
				ExitLoop
			EndIf
		Next
		SetLog("Tombs removed!", $COLOR_SUCCESS)
	Else
		SetLog("No Tombs Found!", $COLOR_DEBUG1)
	EndIf
	;If QuickMIS("BC1", $g_sImgClearTombs, $InnerDiamondLeft, $InnerDiamondTop, $InnerDiamondRight, $InnerDiamondBottom) Then
	;	If isInsideDiamondXY($g_iQuickMISX, $g_iQuickMISY) Then 
	;		Click($g_iQuickMISX, $g_iQuickMISY)
	;		SetLog("Tombs removed!", $COLOR_SUCCESS)
	;	EndIf
	;Else
	;	SetLog("No Tombs Found!", $COLOR_DEBUG1)
	;EndIf
EndFunc   ;==>CheckTombs

Func CleanYardCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(True) ;check if we have available builder
	If $bTest Then $g_iFreeBuilderCount = 1
	If $g_iFreeBuilderCount > 0 Then 
		$bRet = True
	Else
		;~ SetDebugLog("No More Builders available")
	EndIf
	;~ SetDebugLog("Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func CleanYard($bTest = False)
	Local $bRet = False
	If Not $g_bChkCleanYard And Not $g_bChkGemsBox Then Return
	VillageReport(True, True)
	If Not CleanYardCheckBuilder($bTest) Then Return
	SetLog("CleanYard: Try removing obstacles", $COLOR_DEBUG)
	checkMainScreen(True, $g_bStayOnBuilderBase, "CleanYard")
	
	If $g_aiCurrentLoot[$eLootElixir] < 30000 Then 
		SetLog("Elixir < 30000, try again later", $COLOR_DEBUG)
		Return
	EndIf
	
	If RemoveGembox() Then _SleepStatus(35000) ;Remove gembox first, and wait till gembox removed
	
	; Setup arrays, including default return values for $return
	Local $Filename = ""
	Local $x, $y, $Locate = 0
	
	If $g_iFreeBuilderCount > 0 And $g_bChkCleanYard Then
		Local $aResult = QuickMIS("CNX", $g_sImgCleanYard, $OuterDiamondLeft, $OuterDiamondTop, $OuterDiamondRight, $OuterDiamondBottom)
		If IsArray($aResult) And UBound($aResult) > 0 Then
			For $i = 0 To UBound($aResult) - 1
				$Filename = $aResult[$i][0]
				$x = $aResult[$i][1]
				$y = $aResult[$i][2]
				If Not $g_bRunState Then Return
				If Not isInsideDiamondXY($x, $y, True) Then ContinueLoop
				SetLog($Filename & " found [" & $x & "," & $y & "]", $COLOR_SUCCESS)
				Click($x, $y, 1, 0, "CleanYard") ;click CleanYard
				_Sleep(1000)
				If Not ClickRemoveObstacle($bTest) Then ContinueLoop
				CleanYardCheckBuilder($bTest)
				If $g_iFreeBuilderCount = 0 Then _SleepStatus(12000)
				ClickAway()
				$Locate += 1
			Next
		EndIf
	EndIf
	
	If $Locate = 0 Then 
		SetLog("No Obstacles found, Yard is clean!", $COLOR_SUCCESS)
	Else
		$bRet = True
		SetLog("CleanYard Found and Clearing " & $Locate & " Obstacles!", $COLOR_SUCCESS)
	EndIf
	UpdateStats()
	ClickAway()
	
	Return $bRet
EndFunc   ;==>CleanYard

Func ClickRemoveObstacle($bTest = False, $BuilderBase = False)
	If Not $bTest Then 
		If ClickB("RemoveObstacle") Then 
			If _Sleep(1000) Then Return
			If IsGemOpen(True) Then
				Return False
			Else
				Return True
			EndIf
		Else
			If $BuilderBase Then
				ClickAway("Left")
			Else
				ClickAway()
			EndIf
		EndIf
	Else
		SetLog("Only for Testing", $COLOR_ERROR)
	EndIf
	Return False
EndFunc

Func RemoveGembox()
	If Not $g_bChkGemsBox Then Return 
	If Not IsMainPage() Then Return
	
	If QuickMIS("BC1", $g_sImgGemBox, 70,70,830,620) Then
		If Not isInsideDiamondXY($g_iQuickMISX, $g_iQuickMISY, True) Then 
			SetLog("Cannot Remove GemBox!", $COLOR_INFO)
			Return False
		EndIf
		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "#0430")
		_Sleep(1000)
		ClickRemoveObstacle()
		ClickAway()
		SetLog("GemBox removed!", $COLOR_SUCCESS)
		Return True
	Else
		SetLog("No GemBox Found!", $COLOR_DEBUG)
	EndIf
	Return False
EndFunc