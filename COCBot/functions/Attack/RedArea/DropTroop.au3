
; #FUNCTION# ====================================================================================================================
; Name ..........: DropTroop
; Description ...:
; Syntax ........: DropTroop($troop, $nbSides, $number[, $slotsPerEdge = 0[, $indexToAttack = -1]])
; Parameters ....: $troop               - a dll struct value.
;                  $nbSides             - a general number value.
;                  $number              - a general number value.
;                  $slotsPerEdge        - [optional] a string value. Default is 0.
;                  $indexToAttack       - [optional] an integer value. Default is -1.
; Return values .: None
; Author ........: didipe
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func DropTroop($troop, $nbSides, $number, $slotsPerEdge = 0, $indexToAttack = -1)
	SetLog("TEST OPTIMIZATION DROPT TROOP FUNCTION", $COLOR_INFO)
    If IsProblemAffect(True) Then Return
    Local $nameFunc = "[DropTroop]"
    DebugRedArea($nameFunc & " IN ")
    DebugRedArea("troop : [" & $troop & "] / nbSides : [" & $nbSides & "] / number : [" & $number & "] / slotsPerEdge [" & $slotsPerEdge & "]")

    If $g_abAttackStdSmartAttack[$g_iMatchMode] Then
        If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = Floor($number / $nbSides)
        If _Sleep($DELAYDROPTROOP1) Then Return
        SelectDropTroop($troop) ;Select Troop
        If _Sleep($DELAYDROPTROOP2) Then Return

        If $nbSides < 1 Then Return
        Local $nbTroopsLeft = $number

        Local $g_aaiEdgeDropPointsPixelToDrop
        If $nbSides = 4 Then
            $g_aaiEdgeDropPointsPixelToDrop = GetPixelDropTroop($troop, $number, $slotsPerEdge)
        EndIf

        For $i = 0 To $nbSides - 1
            Local $nbTroopsPerEdge
            If $nbSides = 4 Then
                $nbTroopsPerEdge = Round($nbTroopsLeft / ($nbSides - $i * 2))
                If $number > 0 And $nbTroopsPerEdge = 0 Then $nbTroopsPerEdge = 1
                Local $listEdgesPixelToDrop[2] = [$g_aaiEdgeDropPointsPixelToDrop[$i], $g_aaiEdgeDropPointsPixelToDrop[$i + 2]]
            Else
                $nbTroopsPerEdge = Round($nbTroopsLeft / ($nbSides - $i))
                If $number > 0 And $nbTroopsPerEdge = 0 Then $nbTroopsPerEdge = 1
                Local $g_aaiEdgeDropPointsPixelToDrop = GetPixelDropTroop($troop, $nbTroopsPerEdge, $slotsPerEdge)
                Local $listEdgesPixelToDrop[1] = [$g_aaiEdgeDropPointsPixelToDrop[$i]]
            EndIf

            DropOnPixel($troop, $listEdgesPixelToDrop, $nbTroopsPerEdge, $slotsPerEdge)
            $nbTroopsLeft -= $nbTroopsPerEdge * ($nbSides - $i * 2)
        Next
    Else
        DropOnEdges($troop, $nbSides, $number, $slotsPerEdge)
    EndIf

    DebugRedArea($nameFunc & " OUT ")
EndFunc   ;==>DropTroop


Func DropTroop2($troop, $nbSides, $number, $slotsPerEdge = 0, $name = "")
	Local $nameFunc = "[DropTroop2]"
	debugRedArea($nameFunc & " IN ")
	debugRedArea("troop : [" & $troop & "] / nbSides : [" & $nbSides & "] / number : [" & $number & "] / slotsPerEdge [" & $slotsPerEdge & "]")
	Local $listInfoPixelDropTroop[0]

	If ($g_abAttackStdSmartAttack[$g_iMatchMode]) Then
		If $slotsPerEdge = 0 Or $number < $slotsPerEdge Then $slotsPerEdge = Floor($number / $nbSides)
		;If _Sleep($DELAYDROPTROOP1) Then Return
		;SelectDropTroop($troop) ;Select Troop
		;If _Sleep($DELAYDROPTROOP2) Then Return

		If $nbSides < 1 Then Return
		Local $nbTroopsLeft = $number
		Local $nbTroopsPerEdge = Round($nbTroopsLeft / $nbSides)
		If (($g_abAttackStdSmartNearCollectors[$g_iMatchMode][0] = False And $g_abAttackStdSmartNearCollectors[$g_iMatchMode][1] = False And _
				$g_abAttackStdSmartNearCollectors[$g_iMatchMode][2] = False) Or UBound($g_aiPixelNearCollector) = 0) Then
			If ($number > 0 And $nbTroopsPerEdge = 0) Then $nbTroopsPerEdge = 1
			If $nbSides = 4 Then
				ReDim $listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) + 4]
				Local $listInfoPixelDropTroop = GetPixelDropTroop($troop, $number, $slotsPerEdge)

			Else
				For $i = 0 To $nbSides - 1
					If $nbSides = 1 Or ($nbSides = 3 And $i = 2) Then
						Local $g_aaiEdgeDropPointsPixelToDrop = GetPixelDropTroop($troop, $nbTroopsPerEdge, $slotsPerEdge)
						ReDim $listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) + 1]
						$listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) - 1] = $g_aaiEdgeDropPointsPixelToDrop[$i]
					ElseIf ($nbSides = 2 And $i = 0) Or ($nbSides = 3 And $i <> 1) Then
						Local $g_aaiEdgeDropPointsPixelToDrop = GetPixelDropTroop($troop, $nbTroopsPerEdge, $slotsPerEdge)
						ReDim $listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) + 2]
						$listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) - 2] = $g_aaiEdgeDropPointsPixelToDrop[$i + 3]
						$listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) - 1] = $g_aaiEdgeDropPointsPixelToDrop[$i + 1]
					EndIf
				Next
			EndIf

		Else
			Local $listEdgesPixelToDrop[0]

			Local $nbTroopsPerEdge = Round($number / UBound($g_aiPixelNearCollector))
			If ($number > 0 And $nbTroopsPerEdge = 0) Then $nbTroopsPerEdge = 1
			Local $maxElementNearCollector = UBound($g_aiPixelNearCollector) - 1
			Local $startIndex = 0
			Local $troopFurther = False
			If ($troop = $eArch Or $troop = $eSArch Or $troop = $eWiza Or $troop = $eSWiza Or $troop = $eMini Or $troop = $eSMini Or $troop = $eBarb Or $troop = $eSBarb) Then
				$troopFurther = True
			EndIf
			Local $centerPixel[2] = [430, 338]
			For $i = $startIndex To $maxElementNearCollector
				Local $pixel = $g_aiPixelNearCollector[$i]
				ReDim $listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) + 1]
				Local $arrPixelToSearch
				If ($pixel[0] < $centerPixel[0] And $pixel[1] < $centerPixel[1]) Then
					If ($troopFurther) Then
						$arrPixelToSearch = $g_aiPixelTopLeftFurther
					Else
						$arrPixelToSearch = $g_aiPixelTopLeft
					EndIf
				ElseIf ($pixel[0] < $centerPixel[0] And $pixel[1] > $centerPixel[1]) Then
					If ($troopFurther) Then
						$arrPixelToSearch = $g_aiPixelBottomLeftFurther
					Else
						$arrPixelToSearch = $g_aiPixelBottomLeft
					EndIf
				ElseIf ($pixel[0] > $centerPixel[0] And $pixel[1] > $centerPixel[1]) Then
					If ($troopFurther) Then
						$arrPixelToSearch = $g_aiPixelBottomRightFurther
					Else
						$arrPixelToSearch = $g_aiPixelBottomRight
					EndIf
				Else
					If ($troopFurther) Then
						$arrPixelToSearch = $g_aiPixelTopRightFurther
					Else
						$arrPixelToSearch = $g_aiPixelTopRight
					EndIf
				EndIf

				$listInfoPixelDropTroop[UBound($listInfoPixelDropTroop) - 1] = _FindPixelCloser($arrPixelToSearch, $pixel, 1)

			Next

		EndIf
	Else
		DropOnEdges($troop, $nbSides, $number, $slotsPerEdge)
	EndIf

	Local $infoDropTroop[6] = [$troop, $listInfoPixelDropTroop, $nbTroopsPerEdge, $slotsPerEdge, $number, $name]
	debugRedArea($nameFunc & " OUT ")

	Return $infoDropTroop
EndFunc   ;==>DropTroop2
