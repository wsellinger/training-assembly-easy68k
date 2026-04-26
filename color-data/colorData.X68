*-----------------------------------------------------------
* Title      : Color Data
* Description: write code to draw a block of color data

* In this exercise, you write code to draw a block of color
*   data. Use the data at the bottom to define the region
*   - Use ScreenHeight and ScreenWidth to set the output window resolution
*   - Use ScreenPosX and ScreenPosY to set the starting block position
*   - Use the BlockHeight and BlockWidth to determine the size of the block 
*       of pixels that will be drawn on screen.
*   - Get the colors from the ColorBlock1 first, then try using ColorBlock2
*       Note: ColorBlock1 stores colors as (stored as BB GG RR)
*       Note: ColorBlock2 stores colors as (stored as BB GG RR 00)

*-----------------------------------------------------------

;Default Trap Code
SimulatorControlTrapCode equ 15

;Trap Tasks
SetPenColorTask             equ 80
DrawPixelTask               equ 82
GetSetOutputWindowTask      equ 33

DelayTask                   equ 23
GetSetCursorScreenClearTask equ 11

;Values
DelayAmount equ 50
ClearScreen equ $0000FF00

    ORG    $1000
START:

;Logic

;Set Resolution
    lea     ScreenWidth,a0
    lea     ScreenHeight,a1
    
    move.w  (a0),d1                         ;Pack Resolution Data
    swap.w  d1
    move.w  (a1),d1
    move.b  #GetSetOutputWindowTask,d0      ;Change Resolution
    trap    #SimulatorControlTrapCode

;Color Block Byte
    ;Registers
    ;d3 = x
    ;d4 = y
    ;d5 = iX
    ;d6 = iY    
    ;a0 = X Start
    ;a1 = Y Start
    ;a2 = iX Start
    ;a3 = iY Start
    ;a4 = Color Iterator
    ;d7 = Byte/Long Bool
    
;Set Block Start
    lea     ScreenPosX,a0
    lea     ScreenPosY,a1
    lea     BlockWidth,a2
    lea     BlockHeight,a3
    
;Set Iterators 
ColorBlockInit   
    move.w  (a0),d3
    move.w  (a1),d4
    move.w  (a2),d5
    move.w  (a3),d6

;Set Color Iterator
    cmp.b   #1,d7                           ;Check Byte or Long
    beq     SetColorBlockLong               ;Branch Set Long
    lea     ColorBlockByte,a4               ;Set Byte
    bra     ColorBlockLoop                  ;Branch Skip Long
SetColorBlockLong
    lea     ColorBlockLong,a4               ;Set Long
    
ColorBlockLoop
;Set Pen Color
    cmp.b   #1,d7                           ;Check Byte or Long
    beq     ColorShiftLong                  ;Branch Get Color Long 

    move.b  #3,d0                           ;Pack Next 3 Bytes
    clr.l   d1
ColorPackByteLoop
    move.b  (a4)+,d1                        ;Get Byte
    sub.b   #1,d0                           ;Decrement Iterator

    beq     ColorSelectEnd                  ;End Loop

    lsl.l   #8,d1                           ;Shift Left
    bra     ColorPackByteLoop               ;Loop

ColorShiftLong
    move.l  (a4)+,d1
    lsr.l   #8,d1
ColorSelectEnd
    
    move.b  #SetPenColorTask,d0             ;Set Pen Color
    trap    #SimulatorControlTrapCode

;Draw Pixel
    move.w  d3,d1                           ;Set X
    move.w  d4,d2                           ;Set Y
    move.b  #DrawPixelTask,d0               ;Draw Pixel
    trap    #SimulatorControlTrapCode

;Advance Loop
    add.w   #1,d3                           ;Increment x
    sub.w   #1,d5                           ;Decrement iX
    bne     ColorBlockLoop                  ;Loop until out of columns 
    
    add.w   #1,d4                           ;Increment y
    sub.w   #1,d6                           ;Decrement iY
    beq     DrawPixelLoopEnd                ;End Loop if out of rows

    move.w  (a0),d3                         ;Reset x
    move.w  (a2),d5                         ;Reset iX
    
    bra     ColorBlockLoop                  ;Loop
    
DrawPixelLoopEnd

    ;Delay Start
    move.l  #DelayAmount,d1                 ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #ClearScreen,d1                 ;ClearScreen
    move.l  #GetSetCursorScreenClearTask,d0
    trap    #SimulatorControlTrapCode
    
    move.l  #DelayAmount,d1                 ;Delay
    move.l  #DelayTask,d0
    trap    #SimulatorControlTrapCode
    ;Delay End

;Color Block Long
    cmp.b   #1,d7                           ;Check if finished
    beq     ColorBlockLoopEnd               ;End Program
    
    move.b  #1,d7                           ;Set flag for long block instead of byte block
    bra     ColorBlockInit                  ;Reinit and Loop

ColorBlockLoopEnd

    SIMHALT

;Memory

ScreenHeight    dc.w    768
ScreenWidth     dc.w    1024
ScreenPosY      dc.w    10
ScreenPosX      dc.w    10
BlockHeight     dc.w    30
BlockWidth      dc.w    60

ColorBlockByte

*----------------------------------------------------------- CYAN ----------------------------------------------------------- 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00

                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00

                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00 
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00
                dc.b    $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00, $FF,$FF,$00

*----------------------------------------------------------- MAGENTA ----------------------------------------------------------- 

                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF   

                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF  
                
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF  
                
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF  
                
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF
                dc.b    $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF, $FF,$00,$FF  
                
 *----------------------------------------------------------- YELLOW ----------------------------------------------------------- 
                         
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                dc.b    $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF, $00,$FF,$FF
                

 *----------------------------------------------------------- BLUE ----------------------------------------------------------- 
                
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00
                dc.b    $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00, $FF,$00,$00

 *----------------------------------------------------------- GREEN ----------------------------------------------------------- 
                
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00
                dc.b    $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00, $00,$FF,$00

 *----------------------------------------------------------- RED ----------------------------------------------------------- 

                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF
                dc.b    $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF, $00,$00,$FF

ColorBlockLong     

*----------------------------------------------------------- CYAN ----------------------------------------------------------- 
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                                                                                                                                  
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                                                                                                                                  
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                                                                                                                                  
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                                                                                                                                  
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                dc.l    $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000, $FFFF0000
                                                                                                                                  
*----------------------------------------------------------- MAGENTA -----------------------------------------------------------  
                                                                                                                                  
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00  
                                                                                                                                  
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00 
                                                                                                                                  
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00 
                                                                                                                                  
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00 
                                                                                                                                  
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00
                dc.l    $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00, $FF00FF00 
                                                                                                                                  
 *----------------------------------------------------------- YELLOW -----------------------------------------------------------  
                                                                                                                                  
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                                                                                                                                  
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                                                                                                                                  
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                                                                                                                                  
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                                                                                                                                  
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                dc.l    $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00, $00FFFF00
                                                                                                                                  
                                                                                                                                  
 *----------------------------------------------------------- BLUE -----------------------------------------------------------    
                                                                                                                                  
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                                                                                                                                  
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                                                                                                                                  
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                                                                                                                                  
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                                                                                                                                  
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                dc.l    $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000, $FF000000
                                                                                                                                  
 *----------------------------------------------------------- GREEN -----------------------------------------------------------   
                                                                                                                                  
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                                                                                                                                  
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                                                                                                                                  
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                                                                                                                                  
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                                                                                                                                  
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                dc.l    $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000, $00FF0000
                                                                                                                                  
 *----------------------------------------------------------- RED -----------------------------------------------------------     
                                                                                                                                  
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00

                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00

                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00

                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00

                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00
                dc.l    $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00, $0000FF00

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
