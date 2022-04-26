; Author: Jurkis
; Real author (based on): https://www.autoitscript.com/forum/topic/162445-_inetgetgui-and-_inetgetprogress/.
; 

#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7

#include <GUIConstantsEx.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Example()

Func Example()
    Local $hGUI = GUICreate('JOSM downloader', 370, 90)
    Local $iLabel = GUICtrlCreateLabel('Downloads JOSM Tested jar file to the script directory', 5, 5, 270, 40)
    Local $iStartClose = GUICtrlCreateButton('&Download', 275, 2.5, 90, 25)
    Local $iProgressBar = GUICtrlCreateProgress(5, 60, 360, 20)
    GUISetState(@SW_SHOW, $hGUI)

    Local $sFilePath = '', $sFilePathURL = 'https://josm.openstreetmap.de/josm-tested.jar'
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop

            Case $iStartClose
                $sFilePath = _InetGetGUI($sFilePathURL, $iLabel, $iProgressBar, $iStartClose, @WorkingDir)
                Switch @error ; Check what the actual error was.
                    Case 1 ; $INETGET_ERROR_1
                        MsgBox($MB_SYSTEMMODAL, 'Error', 'Check the URL or your Internet connection is working.')

                    Case 2 ; $INETGET_ERROR_2
                        MsgBox($MB_SYSTEMMODAL, 'Fail', 'It appears the user interrupted the download.')

                    Case Else
                        MsgBox($MB_SYSTEMMODAL, 'Success', 'Successfully downloaded "' & $sFilePath & '"')

                EndSwitch

        EndSwitch
    WEnd

    GUIDelete($hGUI)
EndFunc   ;==>Example

; #FUNCTION# ====================================================================================================================
; Name ..........: _InetGetGUI
; Description ...: Download a file updating a GUICtrlCreateProgress()
; Syntax ........: _InetGetGUI($sURL, $iLabel, $iProgress, $iButton[, $sDirectory = @ScriptDir])
; Parameters ....: $sURL                - A valid URL that contains the filename too
;                  $iLabel              - ControlID of a GUICtrlCreateLabel comtrol.
;                  $iProgress           - ControlID of a GUICtrlCreateProgress control.
;                  $iButton             - ControlID of a GUICtrlCreateButton control.
;                  $sDirectory          - [optional] Directory of where to download. Default is @ScriptDir.
; Return values .: Success - Downloaded filepath.
;                  Failure - Blank string & sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _InetGetGUI($sURL, $iLabel, $iProgress, $iButton, $sDirectory = @ScriptDir)
    Local Enum $INETGET_ERROR_0, $INETGET_ERROR_1, $INETGET_ERROR_2
    Local $sFilePath = StringRegExpReplace($sURL, '^.*/', '')
    If StringStripWS($sFilePath, $STR_STRIPALL) == '' Then
        Return SetError($INETGET_ERROR_1, 0, $sFilePath)
    EndIf

    $sFilePath = StringRegExpReplace($sDirectory, '[\\/]+$', '') & '\' & $sFilePath
    Local $iFileSize = InetGetSize($sURL, $INET_FORCERELOAD)
    Local $hDownload = InetGet($sURL, $sFilePath, $INET_LOCALCACHE, $INET_DOWNLOADBACKGROUND)

    Local Const $iRound = 0
    Local $iBytesRead = 0, $iPercentage = 0, $iSpeed = 0, _
            $sProgressText = '', $sSpeed = 'Current speed: ' & _ByteSuffix($iBytesRead - $iSpeed) & '/s'
    Local $hTimer = TimerInit()

    Local $iError = $INETGET_ERROR_0, _
            $sRead = GUICtrlRead($iButton)

    GUICtrlSetData($iButton, '&Cancel')
    While Not InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $iButton
                GUICtrlSetData($iLabel, 'Download cancelled.')
                $iError = $INETGET_ERROR_2
                ExitLoop
        EndSwitch

        $iBytesRead = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
        $iPercentage = $iBytesRead * 100 / $iFileSize
        $sProgressText = 'Downloading ' & _ByteSuffix($iBytesRead, $iRound) & ' of ' & _ByteSuffix($iFileSize, $iRound) & @CRLF & $sSpeed

        GUICtrlSetData($iLabel, $sProgressText)
        GUICtrlSetData($iProgress, $iPercentage)

        If TimerDiff($hTimer) >= 1000 Then
            $sSpeed = 'Current speed: ' & _ByteSuffix($iBytesRead - $iSpeed) & '/s'
            $iSpeed = $iBytesRead
            $hTimer = TimerInit()
        EndIf
        Sleep(20)
    WEnd

    InetClose($hDownload)
    GUICtrlSetData($iButton, $sRead)

    If $iError > $INETGET_ERROR_0 Then
        FileDelete($sFilePath)
        $sFilePath = ''
    EndIf
    Return SetError($iError, 0, $sFilePath)
EndFunc   ;==>_InetGetGUI

Func _ByteSuffix($iBytes, $iRound = 2) ; By Spiff59
    Local Const $aArray[9] = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
    Local $iIndex = 0
    While $iBytes > 1023
        $iIndex += 1
        $iBytes /= 1024
    WEnd
    Return Round($iBytes, $iRound) & $aArray[$iIndex]
EndFunc   ;==>_ByteSuffix