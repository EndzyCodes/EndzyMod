; #FUNCTION# ====================================================================================================================
; Name ..........: isNoUpgradeLoot.au3
; Description ...: Test upgrade windows for the presence of Red in the last Zero of upgrade value
; Syntax ........: isNoUpgradeLoot($bNeedCaptureRegion), FALSE is default.
; Parameters ....: $bNeedCaptureRegion = True will make a new 2x2 screencapture to identify the pixels to test, False will assume there is a full screen capture to use.
; Return values .: True if Not enough loot, and clicks away to close the window
; Author ........: KnowJack (05-2015)
; Modified ......: Sardo (08-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Click
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func isNoUpgradeLoot($bNeedCaptureRegion = False)
	If _ColorCheck(_GetPixelColor(460, 494, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) And _ ; Check regular upgrades window
			_ColorCheck(_GetPixelColor(460, 496, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) And _
			_ColorCheck(_GetPixelColor(460, 498, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) Then ; Check for Red Zero on norma Upgrades = means not enough loot!
		;~ SetDebugLog("isNoUpgradeLoot Red Zero found", $COLOR_DEBUG)
		ClickAway() ; click away to close upgrade window
		Return True
	ElseIf _ColorCheck(_GetPixelColor(691, 528, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) And _ ; Check Hero upgrades window
			_ColorCheck(_GetPixelColor(691, 530, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) And _
			_ColorCheck(_GetPixelColor(691, 532, $bNeedCaptureRegion), Hex(0xFF887F, 6), 20) Then ; Check for Red Zero = means not enough loot!
		;~ SetDebugLog("IsNoUpgradeLoot Hero Red Zero Found", $COLOR_DEBUG)
		ClickAway() ; click away to close gem window
		Return True
	EndIf
	Return False
EndFunc   ;==>isNoUpgradeLoot
