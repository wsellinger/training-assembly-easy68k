*-----------------------------------------------------------
* Title      : Graphics
* Written by : Bill Sellinger
* Date       : 05/15/2024
* Description: Write code to draw graphical elements

* In this exercise, write code to draw different 
*   graphical elements to the screen

*   - Prompt the user for Screen Height and Width and set 
*       the screen size to those values

*   - Draw a horizontal line of 
*       Dimensions: 2 px by 20 px
*       Position: 10 px by 10 px from top left corner
*       Draw using pixels 
*       Draw using line
*       Draw using rect

*   - Draw an empty rectangle of 
*       Dimensions: 30 px by 20 px
*       Thickness: 2 px
*       Position: 10 px by 10 px from bottom right corner

*   - Draw a filled oval of
*       Dimensions: 50 px by 100 px
*       Thickness: 2 px
*       Position: 20 px by 10 px from bottom left corner

*   - Clear the Screen
*   - Draw a grey filled 10px by 10 px rect at the center of 
*       the screen with a white outline
*   - Check for input from the user
*       If they press up, increase the value of the color. 
*       If they press down, decrease the value of the color.
*   - Clear the screen and redraw the rectangle
*   - Continue this loop until the rectangle is the MAGIC_COLOR

*   - Clear the Screen
*   - Draw a grey filled 10px by 10 px rect at the center of 
*       the screen with a white outline
*   - Check for WASD input from the user
*   - Move the position(s) of the box according to the input
*-----------------------------------------------------------

;Control Characters
BEL EQU  $07   Bell
BS  EQU  $08   Backspace
HT  EQU  $09   Tab (horizontal 5 characters)
LF  EQU  $0A   Line Feed
VT  EQU  $0B   Vertical tab (4 lines)
FF  EQU  $0C   Form Feed (Always end printing with a Form Feed.)
CR  EQU  $0D   Carriage Return 

;Colors
GREY        equ     $808080
;MAGIC_COLOR equ     $123456 ;This one takes forever
MAGIC_COLOR equ     $807654 ;Much more reasonable to reach

;Key Codes
KeyCodeW        equ 'W'    
KeyCodeA        equ 'A'    
KeyCodeS        equ 'S'    
KeyCodeD        equ 'D' 

KeyCodeUp       equ $26
KeyCodeDown     equ $28

;Byte Positions
PackedByte1    equ $FF000000
PackedByte2    equ $00FF0000
PackedByte3    equ $0000FF00
PackedByte4    equ $000000FF

;Default Trap Code
SimulatorControlTrapCode equ 15

;Trap Tasks
DisplayStringTask           equ 13
DisplayStringNoLBTask       equ 14
DisplaySignedNumTask        equ 3
DisplayCharTask             equ 6

ReadNumberWithPromptTask    equ 18
ReadCharKeyboardInputTask   equ 5
ReadKeyCurrentStateTask     equ 19

DelayTask                   equ 23

GetSetOutputWindowTask      equ 33
GetSetCursorScreenClearTask equ 11

SetPenWidthTask             equ 93
SetFillColorTask            equ 81

DrawPixelTask               equ 82
DrawLineTask                equ 84
DrawRectOutlineTask         equ 90
DrawEllipseTask             equ 88
DrawRectTask                equ 87

;Values
DelayAmount equ 50
ClearScreen equ $0000FF00

LineWidth   equ 2
LineHeight  equ 20
LineXY      equ 10

RectBorder      equ 2
RectWidth       equ 30
RectHeight      equ 20
RectXYOffset    equ 10

OvalBorder      equ 2
OvalFill        equ $00FFFFFF
OvalWidth       equ 50
OvalHeight      equ 100
OvalX           equ 20
OvalYOffset     equ 10

InteractiveRectSize equ 10
MagicColorIncrement equ 2

    ORG    $1000
START:

;Logic
 
;1. Set Resolution
GetResolutionInput
    lea     GetResWidthPromptString,a1          ;Get Width
    move.b  #ReadNumberWithPromptTask,d0
    trap    #SimulatorControlTrapCode  

    move.l  d1,d2                               ;Save Width Value

    lea     GetResHeightPromptString,a1         ;Get Height
    move.b  #ReadNumberWithPromptTask,d0
    trap    #SimulatorControlTrapCode  
    
    move.l  d1,d3                               ;Save Height Value
    
    lea     GetResConfirmPromptString,a1        ;Display Confirmation Prompt
    move.b  #DisplayStringNoLBTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  d2,d1                               ;Display Width
    move.b  #DisplaySignedNumTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #'x',d1                             ;Display Separator
    move.b  #DisplayCharTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  d3,d1                               ;Display Height
    move.b  #DisplaySignedNumTask,d0
    trap    #SimulatorControlTrapCode
    
    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0    
    trap    #SimulatorControlTrapCode 
    
    clr.l   d1
    move.b  #ReadCharKeyboardInputTask,d0       ;Read Confirmation
    trap    #SimulatorControlTrapCode
        
    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0    
    trap    #SimulatorControlTrapCode 
    
    cmp.l   #'y',d1                             ;Check Confirmation
    beq     SetResolution
    cmp.l   #'Y',d1                             
    beq     SetResolution
    
    bra     GetResolutionInput                  ;No Confirmation, Re-enter Resolution

SetResolution
    move.l  d2,d1                               ;Pack Resolution Data
    swap.w  d1
    move.w  d3,d1
    move.b  #GetSetOutputWindowTask,d0          ;Change Resolution
    trap    #SimulatorControlTrapCode
    
    ;Save Resolution
    lea     ScreenWidth,a0
    lea     ScreenHeight,a1
    clr.l   d1
    
    move.b  #GetSetOutputWindowTask,d0          ;Get Resolution
    trap    #SimulatorControlTrapCode
    
    move.w  d1,(a1)
    swap.w  d1
    move.w  d1,(a0)

;2. Draw Lines
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode

;2a. Pixel Line
    move.l  #LineXY,d1
    move.l  #LineXY,d2
    move.l  #DrawPixelTask,d0
    
DrawPixelLineLoop
    trap    #SimulatorControlTrapCode
    
    add.l   #1,d1
    cmp.l   #LineXY+LineWidth,d1
    blt     DrawPixelLineLoop
    
    move.l  #LineXY,d1
    add.l   #1,d2
    cmp.l   #LineXY+LineHeight,d2
    blt     DrawPixelLineLoop

    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End

;2b. Line Line
    move.b  #LineWidth,d1
    move.l  #SetPenWidthTask,d0
    trap    #SimulatorControlTrapCode

    move.w  #LineXY,d1
    move.w  #LineXY,d2
    move.w  #LineXY,d3
    move.w  #LineXY+LineHeight,d4
    move.l  #DrawLineTask,d0
    trap    #SimulatorControlTrapCode

    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End
    
;2c. Rect Line
    move.b  #1,d1
    move.l  #SetPenWidthTask,d0
    trap    #SimulatorControlTrapCode
    
    move.w  #LineXY,d1
    move.w  #LineXY,d2
    move.w  #LineXY+LineWidth-1,d3
    move.w  #LineXY+LineHeight-1,d4
    move.l  #DrawRectOutlineTask,d0
    trap    #SimulatorControlTrapCode
    
    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End
    
;3. Draw Empty Rect
    lea     ScreenWidth,a0
    lea     ScreenHeight,a1

    move.b  #RectBorder,d1
    move.l  #SetPenWidthTask,d0
    trap    #SimulatorControlTrapCode
    
    move.w  (a0),d1                            ;X
    sub.w   #RectXYOffset+RectWidth,d1
    
    move.w  (a1),d2                            ;Y
    sub.w   #RectXYOffset+RectHeight,d2   
    
    move.w  (a0),d3                            ;Width
    sub.w   #RectXYOffset,d3   

    move.w  (a1),d4                            ;Height
    sub.w   #RectXYOffset,d4   

    move.l  #DrawRectOutlineTask,d0
    trap    #SimulatorControlTrapCode

    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End

;4. Draw Filled Oval
    lea     ScreenHeight,a0

    move.b  #OvalBorder,d1                      ;Border Thickness
    move.l  #SetPenWidthTask,d0
    trap    #SimulatorControlTrapCode

    move.l  #OvalFill,d1                        ;Fill color
    move.b  #SetFillColorTask,d0
    trap    #SimulatorControlTrapCode 
    
    move.w  #OvalX,d1                           ;X
    
    move.w  (a0),d2                             ;Y
    sub.w   #OvalYOffset+OvalHeight,d2   
    
    move.w  #OvalX+OvalWidth,d3                 ;Width

    move.w  (a0),d4                             ;Height
    sub.w   #RectXYOffset,d4   
    
    move.l  #DrawEllipseTask,d0
    trap    #SimulatorControlTrapCode

    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End
    
;5. Magic Color Game
    move.l  #GREY,d7                            ;Save Fill Color

    move.b  #1,d1                               ;Reset Border
    move.l  #SetPenWidthTask,d0
    trap    #SimulatorControlTrapCode
    
    lea     ScreenWidth,a0
    lea     ScreenHeight,a1
    lea     MagicRectLX,a2
    lea     MagicRectUY,a3
    lea     MagicRectRX,a4
    lea     MagicRectLY,a5
    
    ;Calculate LX
    move.w  (a0),d0
    asr.w   #1,d0
    move.w  #InteractiveRectSize,d1
    asr.w   #1,d1
    sub.w   d1,d0    
    move.w  d0,(a2)
    
    ;CalculateRX
    add.w   #InteractiveRectSize,d0
    move.w  d0,(a4)
    
    ;Calculate UY
    move.w  (a1),d0
    asr.w   #1,d0
    sub.w   d1,d0    
    move.w  d0,(a3)
    
    ;Calculate LY
    add.w   #InteractiveRectSize,d0
    move.w  d0,(a5)

MagicColorUpdate
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode

    move.l  d7,d1                               ;Update color
    move.b  #SetFillColorTask,d0
    trap    #SimulatorControlTrapCode

    move.w  (a2),d1                             ;LX
    move.w  (a3),d2                             ;UY
    move.w  (a4),d3                             ;RX
    move.w  (a5),d4                             ;LY
    move.l  #DrawRectTask,d0
    trap    #SimulatorControlTrapCode           ;Draw Rect
  
    cmp.l   #MAGIC_COLOR,d7                     ;Check Magic Color
    beq     MagicColorSuccess

ArrowInputLoopStart   
    move.l  #KeyCodeUp<<8+KeyCodeDown,D1        ;Pack keycodes for Left, Right, Up, and Down

    move.b  #ReadKeyCurrentStateTask,d0
    trap    #SimulatorControlTrapCode
    
    cmp.l   #0,d1                               ;No Valid Key Input
    beq     ArrowInputLoopStart                 ;Continue Checking for Key Input
    
    move.l  d1,d2                               ;Save Off Result
    clr.l   d1                                  ;Clear to Allow Byte Instructions
    
;CheckForUp
    move.l  #PackedByte3,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForDown
    
    add.l   #MagicColorIncrement,d7             ;Increment Color
    bra     MagicColorUpdate   
    
CheckForDown
    move.l  #PackedByte4,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     ArrowInputLoopStart
    
    sub.l   #MagicColorIncrement,d7             ;Decrement Color
    bra     MagicColorUpdate
    
MagicColorSuccess
    move.w  #0,d1                               ;LX
    move.w  #0,d2                               ;UY
    move.w  #ScreenWidth,d3                     ;RX
    move.w  #ScreenHeight,d4                    ;LY
    move.l  #DrawRectTask,d0
    trap    #SimulatorControlTrapCode           ;Draw Rect

    ;Delay Start
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                     ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End    
    
;6. Moving Box
    move.l  #GREY,d1                            ;Reset color
    move.b  #SetFillColorTask,d0
    trap    #SimulatorControlTrapCode

MovingBoxUpdate
    move.l  #ClearScreen,d1                     ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode

    move.w  (a2),d1                             ;LX
    move.w  (a3),d2                             ;UY
    move.w  (a4),d3                             ;RX
    move.w  (a5),d4                             ;LY
    move.l  #DrawRectTask,d0
    trap    #SimulatorControlTrapCode           ;Draw Rect

WasdInputLoopStart   
    move.l  #KeyCodeW<<24+KeyCodeA<<16+KeyCodeS<<8+KeyCodeD,D1  ;Pack keycodes for WSAD

    move.b  #ReadKeyCurrentStateTask,d0
    trap    #SimulatorControlTrapCode
    
    cmp.l   #0,d1                               ;No Valid Key Input
    beq     WasdInputLoopStart                  ;Continue Checking for Key Input
    
    move.l  d1,d2                               ;Save Off Result
    clr.l   d1                                  ;Clear to Allow Byte Instructions
    
;CheckForW
    move.l  #PackedByte1,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForA
    
    cmp.w   #0,(a3)
    ble     CheckForA                           ;Skip Move If At Edge
    
    sub.w   #1,(a3)                             ;Move Up
    sub.w   #1,(a5)
    
CheckForA
    move.l  #PackedByte2,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForS
    
    cmp.w   #0,(a2)
    ble     CheckForS                           ;Skip Move If At Edge

    sub.w   #1,(a2)                             ;Move Left
    sub.w   #1,(a4)

CheckForS
    move.l  #PackedByte3,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForD

    move.w  (a5),d0
    cmp.w   (a1),d0
    bge     CheckForD                           ;Skip Move If At Edge
    
    add.w   #1,(a3)                             ;Move Down
    add.w   #1,(a5)
    
CheckForD
    move.l  #PackedByte4,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     MovingBoxUpdate
    
    move.w  (a4),d0
    cmp.w   (a0),d0
    bge     MovingBoxUpdate                     ;Skip Move If At Edge
    
    add.w   #1,(a2)                             ;Move Right
    add.w   #1,(a4)
    bra     MovingBoxUpdate

    SIMHALT             ; halt simulator

LineBreak dc.b CR,LF,0

GetResWidthPromptString dc.b 'Enter desired window width: ',0
GetResHeightPromptString dc.b 'Enter desired window height: ',0
GetResConfirmPromptString dc.b 'Set window to the following resolution? (Y/N): ',0

ScreenWidth ds.w 1
ScreenHeight ds.w 1

MagicRectLX ds.w 1
MagicRectUY ds.w 1
MagicRectRX ds.w 1
MagicRectLY ds.w 1

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
