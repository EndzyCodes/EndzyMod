; #FUNCTION# ====================================================================================================================
; Name ..........: SetSleep
; Description ...: Randomizes deployment wait time
; Syntax ........: SetSleep($type)
; Parameters ....: $type                - Flag for type return desired.
; Return values .: None
; Author ........:
; Modified ......: KnowJack (06/2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func SetSleep($iType)
	If IsKeepClicksActive() = True Then Return 0
	;~ iOffset1 = 100 - longer duration for wave to simulate longer waves liek what human attacks
	;~ iOffset0 = 10 - slower duration for troops to simulate more realistic multi click or drag clicks like a human attacks
	Local $iOffset0 = 100, $iOffset1 = 100 ; 
	Switch $iType
		Case 0
			Return Round(Random(0.95, 1.15) * (5 * $iOffset0)) ;troops
		Case 1
			Return Round(Random(0.95, 1.15) * (5 * $iOffset1)) ;wave
	EndSwitch
EndFunc   ;==>SetSleep

; #FUNCTION# ====================================================================================================================
; Name ..........: _SleepAttack
; Description ...: Version of _Sleep() used in attack code so active keep clicks mode doesn't slow down bulk deploy
; Syntax ........: see _Sleep
; Parameters ....: see _Sleep
; Return values .: see _Sleep
; Author ........: cosote (2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _SleepAttack($iDelay, $iSleep = True)
	If Not $g_bRunState Then
		ResumeAndroid()
		Return True
	EndIf
	If IsKeepClicksActive() Then Return False
	Return _Sleep($iDelay, $iSleep)
EndFunc   ;==>_SleepAttack
