#singleinstance force
; Auto-fisher script for Minecraft 1.20 made by N1xon, 2023
; Version 3
CoordMode, Pixel, Screen
SendMode, Play
SoundSet, 20

; CHANGE THESE DEPENDING ON SETUP: 
; Positions of UI on the screen, made for 1080p
global POS_HEART := [900,940] ; position of health bar
global POS_QUIT := [1000,725] ; position of save and quit button
global POS_INVEND := [1247,712] ; position of last inventory slot
global POS_CHEST_INVSTART := [670,680] ; position of first player inventory slot when chest is open
global POS_CHEST_INVEND := [1250,830] ; position of last player inventory slot when chest is open
global POS_CHEST_END := [1247,560] ; position of last slot in a chest
global POS_INV_OFFSET := [42, -24] ; Offset of an item's black background preview from the mouse when an item is hovered
; Angle of fishing spot vs chests to store loot
global ANGLE_CHESTS := [800,650,500,350] ; Down angle (from top of screen) of each chest to store loot
global ANGLE_FISH_RIGHT := 1050 ; How much to turn right to fish (from the chests)
global ANGLE_FISH_DOWN := 725 ; How much to turn down from top of screen to fish


; How-to:
; X : where bobber will land
; F : Where to stand
; = : Dock
; C : Chests, stacked 4 High

;~XX~~~~~~~~~
;~X~~~~~~~~~~
;~~~~~~~~~~~~
;~~~~~~F==~~~
;~~~~~~===~~~
;~~~~~~==C~~~
;~~~~~~==C~~~

; Stand at F, Look at the closest corner of the stack of chests, them press "." to start
; Press "," to stop. Will also automatically log out if damaged, and will stop if other input is detected

; -------------------
; CODE; DO NOT MODIFY
; -------------------
global invSize := (POS_CHEST_INVEND[1] - POS_CHEST_INVSTART[1])/8
global is_running := False
global state := "invcheck"
global pos := "chest"
global depChest:= 1
global timer := 0
global state := ""
global fishes := 0
global bobberPos := 0

~.::
{
	is_running := True
	state := "invcheck"
	pos := "chest"
	while (is_running)
	{
		UniqueID := WinActive("Minecraft")
		if(UniqueID==0x0){
			is_running := False
			break
			;MsgBox, "WOW!"
			;PixelGetColor, color_base, 253, 943, RGB
		}
		else{
			; Check health
			PixelGetColor, healthcheck, POS_HEART[1], POS_HEART[2], RGB
			if (healthcheck != "0xFF1313"){
				SendInput, {Escape}
				Sleep, 100
				DllCall("SetCursorPos", uint, POS_QUIT[1], uint, POS_QUIT[2])
				Sleep, 100
				SendMouse_LeftClick()
				Sleep, 100
				is_running := False
				break
			}
			if (state == "invcheck")
			{
				ToolTip "Inventory Check", 0,0
				SendInput, "e"
				Sleep, 100
				DllCall("SetCursorPos", uint, POS_INVEND[1], uint, POS_INVEND[2])
				Sleep, 300
				PixelGetColor, invcheck, POS_INVEND[1]+POS_INV_OFFSET[1], POS_INVEND[2]+POS_INV_OFFSET[2], RGB
				SendInput, "e"
				;MsgBox, %invcheck%
				if (invcheck == "0x1B0C1B") ; INV IS FULL
				{ 
					state := "deposit"
				}
				else{
					state := "fish"
				}
				Sleep, 200
			}
			else if (state == "deposit")
			{
				ToolTip "Deposit", 0,0
				if(pos == "fish"){
					SendMouse_RelativeMove(0,1)
					Sleep, 500
					SendMouse_RelativeMove(0,-2000)
					Sleep, 500
					
					SendMouse_RelativeMove(-ANGLE_FISH_RIGHT,ANGLE_FISH_DOWN)
					Sleep, 500
					pos := "chest"
				}
				chestIsEmpty := False
				if (pos == "chest"){
					Sleep, 200
					SendMouse_RelativeMove(0,1)
					Sleep, 500
					SendMouse_RelativeMove(0,-2000)
					Sleep, 500
					
					SendMouse_RelativeMove(0,ANGLE_CHESTS[depChest])
					Sleep, 500
					SendMouse_RightClick()
					Sleep, 500
					DllCall("SetCursorPos", uint, POS_CHEST_END[1], uint, POS_CHEST_END[2])
					Sleep, 300
					PixelGetColor, invcheck, POS_CHEST_END[1]+POS_INV_OFFSET[1], POS_CHEST_END[2]+POS_INV_OFFSET[2], RGB
					if (invcheck == "0x1B0C1B") ; CHEST IS FULL
					{ 
						depChest++
						if(depChest>4){
							MsgBox, "CHESTS FULL!"
							depChest:=1
							is_running := False
							Break
						}
						SendInput, "e"
						Sleep, 250
					}
					else{
						chestIsEmpty := True
					}
				}
				else {
					MsgBox, "ERROR!"
					is_running := False
					Break
				}
				
				if(chestIsEmpty){
					SendInput, {Shift Down}
					y := 0
					while(y<3){
						x := 0
						while(x<9) { ;; 9
							DllCall("SetCursorPos", uint, POS_CHEST_INVSTART[1]+x*invSize, uint, POS_CHEST_INVSTART[2]+y*invSize)
							Sleep, 100
							SendMouse_LeftClick()
							Sleep, 100
							x++
						}
						y++
					}
					SendInput, {Shift Up}
					SendInput, "e"
					state := "fish"
					Sleep, 200
					
				}
			}
			else if (state == "fish")
			{
				ToolTip "Fish", 0,0
				if (pos == "chest"){
					SendMouse_RelativeMove(0,1)
					Sleep, 500
					SendMouse_RelativeMove(0,-2000)
					Sleep, 500
					
					SendMouse_RelativeMove(ANGLE_FISH_RIGHT,ANGLE_FISH_DOWN)
					Sleep, 500
					pos := "fish"
				}
				state := "casting"
				timer := A_TickCount
				; CAST
				SendInput, "1"
				sleep, 50
				SendMouse_RightClick()
				sleep, 50
			}
			else if (state == "casting")
			{
				ToolTip "Casting", 0,0
				if (A_TickCount - timer > 2000)
				{
					state := "bobber"
				}
			}
			else if (state == "bobber") {
				ToolTip "Looking for Bobber", 0,0 ; 1415
				y := 575
				while(y<625){
					PixelGetColor, linecheck, 1415, y, RGB
					if (linecheck == "0x000000"){
						bobberPos := y
						state := "waitfish"
						Break
					}
					y := y+2
				}
				if (A_TickCount - timer > 5000) ; 4000
				{
					state := "fish" ; bobber taking too long, probably failed cast
				}
			}
			else if (state == "waitfish")
			{
				ToolTip "Waiting for fish: Bobber @ %bobberPos%", 0,0
				if (A_TickCount - timer > 30000)
				{
					state := "fish" ; reset if taking too long, probably failed cast
				}
				PixelGetColor, linecheck, 1415, bobberPos-4, RGB
				PixelGetColor, linecheck2, 1415, bobberPos-2, RGB
				PixelGetColor, linecheck3, 1415, bobberPos, RGB
				PixelGetColor, linecheck4, 1415, bobberPos+2, RGB
				PixelGetColor, linecheck5, 1415, bobberPos+4, RGB
				if (Not (linecheck == "0x000000" or linecheck2 == "0x000000" or linecheck3 == "0x000000" or linecheck4 == "0x000000" or linecheck5 == "0x000000")){
					SendMouse_RightClick()
					state := "reeling"
				}
			}
			else if (state == "reeling"){
				ToolTip "Catching fish", 0,0
				fishes++
				if (fishes > 2){
					fishes:=0
					state := "invcheck"
					Sleep, 100
				}
				else{
					Sleep, 500
					state := "fish"
				}
			}
		}
	}
	ToolTip
}

~,::
{
	is_running := False
	depChest:= 1
}
;---------------------------------------------------------------------------
SendMouse_RightClick() { ; send fast right mouse clicks
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x08) ; right button down
    DllCall("mouse_event", "UInt", 0x10) ; right button up
}
;---------------------------------------------------------------------------
SendMouse_LeftClick() { ; send fast left mouse clicks
;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x02) ; left button down
    DllCall("mouse_event", "UInt", 0x04) ; left button up
}
SendMouse_RelativeMove(x, y) {
	DllCall("mouse_event", uint, 1, int, x, int, y)
}