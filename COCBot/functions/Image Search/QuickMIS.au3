; #FUNCTION# ====================================================================================================================
; Name ..........: QuickMIS
; Description ...: A function to easily use ImgLoc, without headache :P !!!
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: RoroTiti
; Modified ......: ---
; Remarks .......: This file is part of MyBotRun. Copyright 2017
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

Func QuickMIS($ValueReturned, $directory, $Left = 0, $Top = 0, $Right = $g_iGAME_WIDTH, $Bottom = $g_iGAME_HEIGHT, $bNeedCapture = True, $Debug = False)
	Local $error, $extError
	If ($ValueReturned <> "BC1") And ($ValueReturned <> "CX") And ($ValueReturned <> "CNX") And ($ValueReturned <> "N1") And _
		($ValueReturned <> "NX") And ($ValueReturned <> "Q1") And ($ValueReturned <> "QX") And ($ValueReturned <> "BFI") Then
		SetLog("Bad parameters during QuickMIS call for MultiSearch...", $COLOR_RED)
		Return
	EndIf
	
	Local $Res, $aCoords
	Local $RectArea[4] = [$Left, $Top, $Right, $Bottom]
	Local $sImageArea = GetDiamondFromArray($RectArea)
	If $ValueReturned = "BFI" Then 
		Local $iPattern = StringInStr($directory, "*")
		If $iPattern > 0 Then
			Local $dir = ""
			Local $pat = $directory
			Local $iLastBS = StringInStr($directory, "\", 0, -1)
			If $iLastBS > 0 Then
				$dir = StringLeft($directory, $iLastBS)
				$pat = StringMid($directory, $iLastBS + 1)
			EndIf
			Local $files = _FileListToArray($dir, $pat, $FLTA_FILES, True)
			If @error Or UBound($files) < 2 Then
				;~ SetDebugLog("findImage files not found : " & $directory, $COLOR_ERROR)
				SetError(1, 0, $aCoords) ; Set external error code = 1 for bad input values
				Return
			EndIf
			For $i = 1 To $files[0]
				$aCoords = ""
				$aCoords = findImage($pat, $files[$i], $sImageArea, 1, True)
				If $aCoords <> "" Then 
					Local $coord = StringSplit($aCoords, ",", $STR_NOCOUNT)
					If UBound($coord) = 2 Then 
						$g_iQuickMISX = $coord[0]
						$g_iQuickMISY = $coord[1]
						$g_iQuickMISName = $files[$i]
						If $g_bDebugSetlog Then SetDebugLog("BFI Found : " & $g_iQuickMISName & " [" & $g_iQuickMISX & "," & $g_iQuickMISY & "]")
						Return True
					EndIf
				Else
					If $g_bDebugSetlog Then SetDebugLog("BFI No result")
				EndIf
			Next
		EndIf
	Else
		If $bNeedCapture Then _CaptureRegion2($Left, $Top, $Right, $Bottom)
		$Res = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $directory, "str", "FV", "Int", 0, "str", "FV", "Int", 0, "Int", 1000)
	EndIf
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		;~ SetDebugLog(" QuickMIS DLL Error : " & $error & " --- " & $extError)
		Return -1
	EndIf
	If $g_bDebugImageSave Then SaveDebugImage("QuickMIS_" & $ValueReturned, False)

	If IsArray($Res) Then
		;_ArrayDisplay($Res)
		;~ If $g_bDebugSetlog Then SetDebugLog("DLL Call succeeded " & $Res[0], $COLOR_PURPLE)

		If $Res[0] = "" Or $Res[0] = "0" Then
			;~ If $Debug Then SetDebugLog($ValueReturned & ", Image not found in " & $directory)
			Switch $ValueReturned
				Case "BC1"
					Return False
				Case "CX"
					Return -1
				Case "CNX"
					Return -1
				Case "N1"
					Return "none"
				Case "NX"
					Return "none"
				Case "Q1"
					Return 0
				Case "QX"
					Return 0
			EndSwitch

		;ElseIf StringInStr($Res[0], "-1") <> 0 Then
		;	SetLog("DLL Error", $COLOR_RED)

		Else
			Switch $ValueReturned

				Case "BC1" ; coordinates of first/one image found + boolean value

					Local $Result = "" , $Name = "", $Level = ""
					Local $KeyValue = StringSplit($Res[0], "|", $STR_NOCOUNT)
					For $i = 0 To UBound($KeyValue) - 1
						Local $DLLRes = DllCallMyBot("GetProperty", "str", $KeyValue[$i], "str", "objectpoints")
						If UBound(decodeSingleCoord($DLLRes[0])) > 1 Then $Result &= $DLLRes[0] & "|"
					Next
					If StringRight($Result, 1) = "|" Then $Result = StringLeft($Result, (StringLen($Result) - 1))
					
					Local $aCords = decodeSingleCoord($Result)
					Local $iColumn = UBound($aCords)
					If $iColumn < 2 Then 
						SetLog("Error: decodeSingleCoord failed, retcoord: " & UBound($aCords), $COLOR_ERROR)
						Return False
					EndIf
					
					$g_iQuickMISX = $aCords[0] + $Left
					$g_iQuickMISY = $aCords[1] + $Top

					$Name = RetrieveImglocProperty($KeyValue[0], "objectname")
					$g_iQuickMISName = $Name
					$Level = RetrieveImglocProperty($KeyValue[0], "objectlevel")
					$g_iQuickMISLevel = $Level

					If $g_bDebugSetlog Or $Debug Then
						;~ SetDebugLog($ValueReturned & " Found: " & $Name & " Level:" & $Level & ", using " & $g_iQuickMISX & "," & $g_iQuickMISY, $COLOR_PURPLE)
						If $g_bDebugImageSave Then DebugQuickMIS($Left, $Top, "BC1_detected[" & $Name & "_" & $g_iQuickMISX & "x" & $g_iQuickMISY & "]")
					EndIf

					Return True

				Case "CX" ; coordinates of each image found - eg: $Array[0] = [X1, Y1] ; $Array[1] = [X2, Y2]

					Local $Result = ""
					Local $KeyValue = StringSplit($Res[0], "|", $STR_NOCOUNT)
					For $i = 0 To UBound($KeyValue) - 1
						Local $DLLRes = DllCallMyBot("GetProperty", "str", $KeyValue[$i], "str", "objectpoints")
						If UBound(decodeSingleCoord($DLLRes[0])) > 1 Then $Result &= $DLLRes[0] & "|"
					Next
					If StringRight($Result, 1) = "|" Then $Result = StringLeft($Result, (StringLen($Result) - 1))
					If $g_bDebugSetlog Then SetDebugLog($ValueReturned & " Found: " & $Result, $COLOR_PURPLE)
					Local $CoordsInArray = StringSplit($Result, "|", $STR_NOCOUNT)
					Return $CoordsInArray
					
				Case "CNX" 
					Local $Result[0][4]
					Local $KeyValue = StringSplit($Res[0], "|", $STR_NOCOUNT)
					Local $sResult = ""
					For $i = 0 To UBound($KeyValue) - 1
						Local $DLLRes = DllCallMyBot("GetProperty", "str", $KeyValue[$i], "str", "objectpoints")
						Local $objName = StringSplit($KeyValue[$i], "_", $STR_NOCOUNT)
						Local $xy = StringSplit($DLLRes[0], "|", $STR_NOCOUNT)
						;SetDebugLog(_ArrayToString($xy))
						For $j = 0 To Ubound($xy) - 1
							If UBound(decodeSingleCoord($xy[$j])) > 1 Then 
								Local $Tmpxy = StringSplit($xy[$j], ",", $STR_NOCOUNT)
								_ArrayAdd($Result, $objName[0] & "|" & $Tmpxy[0] + $Left & "|" & $Tmpxy[1] + $Top & "|" & $objName[1])
								$sResult &= "|" & $objName[0] & "," & $Tmpxy[0] + $Left & "," & $Tmpxy[1] + $Top & "," & $objName[1]
							EndIf
						Next
					Next
					If $g_bDebugSetlog Or $Debug Then 
						;~ SetDebugLog($ValueReturned & " Found: " & $sResult)
						If $g_bDebugImageSave Then DebugQuickMISCNX($Result, "CNX")
					EndIf
					Return $Result

				Case "N1" ; name of first file found

					Local $MultiImageSearchResult = StringSplit($Res[0], "|")
					Local $FilenameFound = StringSplit($MultiImageSearchResult[1], "_")
					Return $FilenameFound[1]

				Case "NX" ; names of all files found

					Local $AllFilenamesFound = ""
					Local $MultiImageSearchResult = StringSplit($Res[0], "|")
					For $i = 1 To $MultiImageSearchResult[0]
						Local $FilenameFound = StringSplit($MultiImageSearchResult[$i], "_")
						$AllFilenamesFound &= $FilenameFound[1] & "|"
					Next
					If StringRight($AllFilenamesFound, 1) = "|" Then $AllFilenamesFound = StringLeft($AllFilenamesFound, (StringLen($AllFilenamesFound) - 1))
					Return $AllFilenamesFound

				Case "Q1" ; quantity of first/one tiles found

					Local $Result = ""
					Local $KeyValue = StringSplit($Res[0], "|", $STR_NOCOUNT)
					For $i = 0 To UBound($KeyValue) - 1
						Local $DLLRes = DllCallMyBot("GetProperty", "str", $KeyValue[$i], "str", "totalobjects")
						$Result &= $DLLRes[0] & "|"
					Next
					If StringRight($Result, 1) = "|" Then $Result = StringLeft($Result, (StringLen($Result) - 1))
					If $g_bDebugSetlog Then SetDebugLog($ValueReturned & " Found: " & $Result, $COLOR_PURPLE)
					Local $QuantityInArray = StringSplit($Result, "|", $STR_NOCOUNT)
					Return $QuantityInArray[0]

				Case "QX" ; quantity of files found

					Local $MultiImageSearchResult = StringSplit($Res[0], "|", $STR_NOCOUNT)
					Return UBound($MultiImageSearchResult)

			EndSwitch
		EndIf
	EndIf
EndFunc   ;==>QuickMIS

Func DebugQuickMIS($x, $y, $DebugText)

	_CaptureRegion2()
	Local $subDirectory = $g_sProfileTempDebugPath & "QuickMIS"
	DirCreate($subDirectory)
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC & "." & @MSEC
	Local $filename = String($Date & "_" & $Time & "_" & $DebugText & "_.png")
	Local $editedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFFD800, 3) ; Create a pencil Color FFFFD800/Yellow

	_GDIPlus_GraphicsDrawRect($hGraphic, $g_iQuickMISX - 5, $g_iQuickMISY - 5, 10, 10, $hPenRED)

	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & "\" & $filename)
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($editedImage)

EndFunc   ;==>DebugQuickMIS

Func DebugQuickMISCNX($aResult, $DebugText)

	_CaptureRegion2()
	Local $subDirectory = $g_sProfileTempDebugPath & "QuickMIS"
	DirCreate($subDirectory)
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC & "." & @MSEC
	Local $filename = String($Date & "_" & $Time & "_" & $DebugText & "_.png")
	Local $editedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($editedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFFD800, 3) ; Create a pencil Color FFFFD800/Yellow
	
	For $i = 0 To UBound($aResult) - 1
		_GDIPlus_GraphicsDrawRect($hGraphic, $aResult[$i][1] - 3, $aResult[$i][2] - 3, 3, 3, $hPenRED)
	Next

	_GDIPlus_ImageSaveToFile($editedImage, $subDirectory & "\" & $filename)
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($editedImage)

EndFunc   ;==>DebugQuickMIS
