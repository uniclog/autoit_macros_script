#RequireAdmin

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>
#include <WinAPI.au3>
#include <WinAPISys.au3>
#include <WinAPIvkeysConstants.au3>
#include <Guiconstants.au3>

Global Const $SC_DRAGMOVE = 0xF012
Global $block = False;
Global $_event = False;
Global Const $WK_DOWN = 256

#Region ### Hooks
OnAutoItExitRegister("Cleanup")
$hStub_KeyProc = DllCallbackRegister("_KeyProc", "long", "int;wparam;lparam")
$hmod = _WinAPI_GetModuleHandle(0)
$hHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hStub_KeyProc), $hmod)
#EndRegion

#Region ### GUI
$hApp =GUICreate("SWAPER", 150, 50, -1, -1,$WS_CAPTION+$WS_SYSMENU+$WS_MINIMIZEBOX); GUICreate("SWAPER", 150, 50, -1, -1, $WS_POPUP + $WS_SYSMENU)

GUISetBkColor(0x808080)

;Global $hExit = GUICtrlCreateButton("X", 125, 0, 25, 25)
;Global $hMin = GUICtrlCreateButton("---", 102, 0, 25, 25)
$TitleLabel = GUICtrlCreateLabel("Swaper 0.2", 5, 5, 140, 18, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetFont(-1, 12, 700, 0, "Courier New")
GUICtrlSetColor(-1, 0xBEFFBE)
GUICtrlSetBkColor(-1, 0x000000)

;Global $label = GUICtrlCreateLabel("SWAPER", 20, 13, 50, 15)
Global $item = GUICtrlCreateLabel("Alt = X+F1+F2+F3+F4+F6", 5, 35, 0, 0, $SS_CENTER)
GUISetState(@SW_SHOW)
#EndRegion

While True
    Event()
    $nMsg = GUIGetMsg()
    Switch $nMsg
         Case $GUI_EVENT_CLOSE
			Exit
		 ;Case $hExit
		;	Exit
            ;Msgbox(0, "debug", "onex works")
		 ;Case $hMin
		;	GUISetState(@SW_MINIMIZE)
	     Case $GUI_EVENT_PRIMARYDOWN
			_SendMessage($hApp, $WM_SYSCOMMAND, $SC_DRAGMOVE, 0)
    EndSwitch
 WEnd
#Region KeyEvents
Func Event()
	  Sleep(20)
	  If $_event Then
			  $_event = False
			  _WinAPI_Keybd_Event($VK_X, 0)
			  _WinAPI_Keybd_Event($VK_X, 2)
			  Sleep(20)
			  Send("{F2}")
			  Sleep(20)
			  Send("{F3}")
			  Sleep(20)
			  Send("{F4}")
			  Sleep(20)
			  Send("{F5}")
			  Sleep(20)
			  Send("{F6}")
	  EndIf
   EndFunc   ;==>Event
#EndRegion
#Region WinAPI_HOOK
 Func _KeyProc($nCode, $wParam, $lParam)
   Local $tKEYHOOKS
   $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
   If $nCode < 0 Then
	  Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
   EndIf

   Local $flags = DllStructGetData($tKEYHOOKS, "flags")

   If DllStructGetData($tKEYHOOKS, "vkCode") <> 0 Then
	  If DllStructGetData($tKEYHOOKS, "scanCode") = 56 And DllStructGetData($tKEYHOOKS, "vkCode") = 164 Then
	  Else
		 $block = False
	  EndIf
   EndIf
   ;ConsoleWrite("$LLKHF_UP: scanCode - " & DllStructGetData($tKEYHOOKS, "scanCode") & @TAB & "vkCode - " & DllStructGetData($tKEYHOOKS, "vkCode") & @LF)
   Switch $flags
		 Case $LLKHF_UP
			if $block Then
			   If DllStructGetData($tKEYHOOKS, "scanCode") = 56 And DllStructGetData($tKEYHOOKS, "vkCode") = 164 Then
				   $block = False
				   $_event = True
				   ;ConsoleWrite(" ALT UP" & @LF)
			   EndIf
			EndIf

		 Case $LLKHF_ALTDOWN
			if not $block Then
			   $block = True
			   ;ConsoleWrite("$LLKHF_ALTDOWN " & @LF)
			EndIf
   EndSwitch

   Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
EndFunc   ;==>_KeyProc

Func Cleanup()
   _WinAPI_UnhookWindowsHookEx($hHook)
   DllCallbackFree($hStub_KeyProc)
EndFunc   ;==>Cleanup
#EndRegion