; #FUNCTION# ====================================================================================================================
; Name ..........: CheckHeroesHealth
; Description ...:
; Syntax ........: CheckHeroesHealth()
; Parameters ....:
; Return values .: None
; Author ........:
; Modified ......: MonkeyHunter(03-2017), Fliegerfaust (11-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_bCheckHeroPower[4] = [True, True, True, True]

Func CheckHeroesHealth()
	SetLog("TEST OPTIMIZATION CheckHeroesHealth FUNCTION", $COLOR_INFO)
    If $g_bCheckKingPower Or $g_bCheckQueenPower Or $g_bCheckWardenPower Or $g_bCheckChampionPower Then
        ForceCaptureRegion()

        Local $aDisplayTime[$eHeroCount] = [0, 0, 0, 0]

        Local $TempKingSlot = $g_iKingSlot
        Local $TempQueenSlot = $g_iQueenSlot
        Local $TempWardenSlot = $g_iWardenSlot
        Local $TempChampionSlot = $g_iChampionSlot

        Local $bDragAttackBar = False
        If $g_iKingSlot >= 11 Or $g_iQueenSlot >= 11 Or $g_iWardenSlot >= 11 Or $g_iChampionSlot >= 11 Then
            $bDragAttackBar = Not $g_bDraggedAttackBar
        ElseIf $g_iKingSlot >= 0 And $g_iQueenSlot >= 0 And $g_iWardenSlot >= 0 And $g_iChampionSlot >= 0 And ($g_iKingSlot < $g_iTotalAttackSlot - 10 Or $g_iQueenSlot < $g_iTotalAttackSlot - 10 Or $g_iWardenSlot < $g_iTotalAttackSlot - 10 Or $g_iChampionSlot < $g_iTotalAttackSlot - 10) Then
            $bDragAttackBar = $g_bDraggedAttackBar
        EndIf

        If $bDragAttackBar Then
            $TempKingSlot -= $g_iTotalAttackSlot - 10
            $TempQueenSlot -= $g_iTotalAttackSlot - 10
            $TempWardenSlot -= $g_iTotalAttackSlot - 10
            $TempChampionSlot -= $g_iTotalAttackSlot - 10
        EndIf

        If $g_bDebugSetlog Then
            If _Sleep($DELAYRESPOND) Then Return
        EndIf

        Local $heroes[4] = [$TempQueenSlot, $TempKingSlot, $TempWardenSlot, $TempChampionSlot]
        Local $activateFlags[4] = [$g_iActivateQueen, $g_iActivateKing, $g_iActivateWarden, $g_iActivateChampion]

        For $i = 0 To UBound($heroes) - 1
            Local $hero = $heroes[$i]
            If $activateFlags[$i] = 0 Or $activateFlags[$i] = 2 Then
                CheckHeroPower($hero, $i)
            ElseIf $activateFlags[$i] = 1 Or $activateFlags[$i] = 2 Then
                CheckActivateHeroPower($hero, $i)
            EndIf
        Next

        If _Sleep($DELAYRESPOND) Then Return
    EndIf
EndFunc   ;==>CheckHeroesHealth

Func CheckHeroPower($heroSlot, $heroIndex)
    If $g_bCheckHeroPower[$heroIndex] And ($g_aHeroesTimerActivation[$heroIndex] = 0 Or __TimerDiff($g_aHeroesTimerActivation[$heroIndex]) > $DELAYCHECKHEROESHEALTH) Then
        Local $aHeroHealthCopy = $aHeroHealth[$heroIndex]
        Local $aSlotPosition = GetSlotPosition($heroSlot)
        $aHeroHealthCopy[0] = $aSlotPosition[0] + $aHeroHealthCopy[4]
        Local $heroPixelColor = _GetPixelColor($aHeroHealthCopy[0], $aHeroHealthCopy[1], $g_bCapturePixel)

        If Not _CheckPixel2($aHeroHealthCopy, $heroPixelColor, "Red+Blue") Then
            SetLog($g_aHeroNames[$heroIndex] & " is getting weak, Activating " & $g_aHeroNames[$heroIndex] & "'s ability", $COLOR_INFO)
            SelectDropTroop($heroSlot, 2, Default, False)
            $g_iCSVLastTroopPositionDropTroopFromINI = $heroSlot
            $g_bCheckHeroPower[$heroIndex] = False
        EndIf
    EndIf
EndFunc

Func CheckActivateHeroPower($heroSlot, $heroIndex)
    If $g_bCheckHeroPower[$heroIndex] Then
        If $g_aHeroesTimerActivation[$heroIndex] <> 0 Then
            Local $aDisplayTime[$heroIndex] = Ceiling(__TimerDiff($g_aHeroesTimerActivation[$heroIndex]) / 1000)
        EndIf

        If (Int($g_aHeroDelaysActivate[$heroIndex]) / 1000) <= $aDisplayTime[$heroIndex] Then
            SetLog("Activating " & $g_aHeroNames[$heroIndex] & "'s ability after " & $aDisplayTime[$heroIndex] & "'s", $COLOR_INFO)
            SelectDropTroop($heroSlot, 2, Default, False)
            $g_iCSVLastTroopPositionDropTroopFromINI = $heroSlot
            $g_bCheckHeroPower[$heroIndex] = False
            $g_aHeroesTimerActivation[$heroIndex] = 0
        EndIf
    EndIf
EndFunc

