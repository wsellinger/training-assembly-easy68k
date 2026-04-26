*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Description: Bitmap rendering with a subroutine

* In this exercise, write the logic to display a chunk of a .bmp file,
* then refactor that code to use a subroutine.

* The arguments required for your subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* You will need to handle 24-bit and 32-bit bitmaps

*-----------------------------------------------------------
* Part 2: refactor the code from part 1 to use a subroutine
*-----------------------------------------------------------

* Dev Notes
*
* Subroutines
*
* Register: 
*     Subroutines prepended with 'r' are small footprint and operate on registers in place.
*     eg. rToggleEndianness, toggle endianness of Long Word in register d0
*
* Stack: 
*     Subroutines prepended with 's' are fully register scoped and transfer arguments and return
*     values via the stack. These are more suitible for logic that the uses a lot of registers or 
*     requires a lot of arguments. Stack Subroutines should prioritize use of the upper registers 
*     (starting at the top and working downward) for persistant data and leave the lower registers
*     (starting at 0 and working upward) for temporary datamanipulation, trap codes, and Register 
*      Subroutines
*
* Labels:
*     Stack subroutines are accompanied by a number of boilerplate labels/variables to simplify
*     and clarify their use. These, as well as any helper data, are prepended by an acronym consisting
*     of the first letter in each word of the subroutine name
*     eg. ValidateFile uses 'vf' for vfRegCount, etc
*
*-----------------------------------------------------------

;==========================================
;=== Constants ============================
;==========================================

;=== Offsets ===
SignatureBitmapOffset equ 0
PixelArrayOffset equ 10
WidthBitmapOffset equ 18
HeightBitmapOffset equ 22
BitPerPixelBitmapOffset equ 28

;=== Trap ===
;Trap Code
SimulatorControlTrapCode equ 15

;Trap Tasks
DisplayStringTask equ 13

GetSetOutputWindowTask equ 33

SetPenColorTask equ 80
DrawPixelTask equ 82

;Misc
ByteSize equ 8
StackVarSize equ 4
ReturnAddressOffset equ 1

;Test Input
sX equ 41
sY equ 83
sW equ 24
sH equ 28
dX equ 100
dY equ 200

;==========================================
;=== Main Routine =========================
;==========================================
 
    ORG (*+3)&-4  Force Long Word alignment
    
START:
    ;Load File
    lea     BitmapFile,a6
    
    ;Draw Sprite
    sub.l   #dsArgAlloc,sp                  ;Allocate Args
    move.l  #BitmapFile,dsArgBmpAdr(sp)     ;   Bitmap Pointer
    move.l  #sX,dsArgSpriteX(sp)            ;   Sprite X
    move.l  #sY,dsArgSpriteY(sp)            ;   Sprite Y
    move.l  #sW,dsArgSpriteW(sp)            ;   Sprite Width
    move.l  #sH,dsArgSpriteH(sp)            ;   Sprite Height
    move.l  #dX,dsArgDisplayX(sp)           ;   Display X
    move.l  #dY,dsArgDisplayY(sp)           ;   Display Y    
    jsr     sDrawSprite                     ;Make Call    
    add.l   #dsArgAlloc,sp                  ;Deallocate Args 

    SIMHALT

;==========================================
;=== Subroutines ==========================
;==========================================

;------------------------------------------
;--- Stack Subroutines --------------------
;------------------------------------------

;==========================================
;=== Draw Sprite ==========================

;=== Registers ===
dsRegCount equ 13
dsRegs reg d0-d7/a2-a6

;a6 Arguments Pointer
;a5 Bitmap Pointer
;a4 wSprite Pointer
;a3 xDisplay Pointer
;a2 yDisplay Pointer

;d7	byteDepth
;d6	xPenStart
;d5	xPixel
;d4	xPen
;d3	yPen
;d2	iPixel
;d1 temp  
;d0 temp

;=== Arguments ===
dsArgCount equ 7
dsArgAlloc equ dsArgCount*StackVarSize
dsArgBmpAdr equ 0*StackVarSize
dsArgSpriteX equ 1*StackVarSize
dsArgSpriteY equ 2*StackVarSize
dsArgSpriteW equ 3*StackVarSize
dsArgSpriteH equ 4*StackVarSize
dsArgDisplayX equ 5*StackVarSize
dsArgDisplayY equ 6*StackVarSize
 
dsArgPointerOffset equ (dsRegCount+ReturnAddressOffset)*StackVarSize

;=== Subroutine === 
sDrawSprite
    ;Save Registers
    movem.l dsRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #dsArgPointerOffset,a6          ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  dsArgBmpAdr(a6),a5              ;a5 Bitmap Pointer
    move.l  dsArgSpriteW(a6),a4             ;a4 wSprite Data
    move.l  dsArgDisplayX(a6),a3            ;a3 xDisplay Data
    move.l  dsArgDisplayY(a6),a2            ;a2 yDisplay Data

    ;--- Start Core Logic ---

    ;Validate File
    sub.l   #vfArgAlloc,sp                  ;Allocate Args
    move.l  a5,vfArgBmpAdr(sp)              ;   Bitmap Pointer    
    jsr     sValidateFile                   ;Call    
    add.l   #vfArgAlloc,sp                  ;Deallocate Args
    
    ;Validate Input
    sub.l   #viArgAlloc,sp                      ;Allocate Args
    move.l  a5,viArgBmpAdr(sp)                  ;   Bitmap Pointer
    move.l  dsArgSpriteX(a6),viArgSpriteX(sp)   ;   xSprite
    move.l  dsArgSpriteY(a6),viArgSpriteY(sp)   ;   ySprite
    move.l  dsArgSpriteW(a6),viArgSpriteW(sp)   ;   wSprite
    move.l  dsArgSpriteH(a6),viArgSpriteH(sp)   ;   hSprite
    jsr     sValidateInput                      ;Call    
    add.l   #viArgAlloc,sp                      ;Deallocate Args

    ;--- Get Constants ---

    ;Get byteDepth                          ;d7 
    move.w  BitPerPixelBitmapOffset(a5),d7  ;Get Bits Per Pixel
    ror.w   #ByteSize,d7                    ;Toggle Endianness
    lsr.w   #3,d7                           ;Convert Bits to Bytes
    
    ;Get xPenStart                          ;d6 
    move.l  dsArgDisplayX(a6),d6            ;   xDisplay
    add.l   a4,d6                           ;+  wSprite
    sub.l   #1,d6                           ;-  1 (zero indexed display)
    
    ;Get iPixelIncrement                    ;d5 
    sub.l   #gpiArgAlloc,sp                 ;Allocate Args
    move.l  a5,gpiArgBmpAdr(sp)             ;   Bitmap Pointer  
    move.l  d7,gpiArgByteDepth(sp)          ;   byteDepth
    move.l  a4,gpiArgSpriteW(sp)            ;   wSprite
    jsr     sGetPixelIncrement              ;Call   
    move.l  gpiArgOutPixelInc(sp),d5        ;d5 Out iPixelIncrement
    move.l  gpiArgOutRowWBytes(sp),d1       ;d1 Out rowWidthBytes 
    add.l   #gpiArgAlloc,sp                 ;Deallocate Args
    
    ;--- Init Dynamics ---
    
    ;Get yPen                               ;d3
    move.l  dsArgDisplayY(a6),d3            ;   yDisplay
    add.l   dsArgSpriteH(a6),d3             ;   hSprite
    sub.l   #1,d3                           ;-  1 (zero indexed display)
    
    ;Get iPixel                             ;d2
    ;   arrayStart
    move.l  PixelArrayOffset(a5),d0         ;   arrayStart
    jsr     rToggleEndianness               ;   Toggle Endianness
    add.l   a5,d0                           ;+  StartOfFile
    move.l  d0,d2                           ;   iPixel = arrayStart
    ;   + xPixel
    move.l  dsArgSpriteX(a6),d0             ;   xSprite
    add.l   dsArgSpriteW(a6),d0             ;   wSprite
    mulu    d7,d0                           ;x  byteDepth = xPixel
    add.l   d0,d2                           ;   iPixel += xPixel

    ;   + yPixel
    move.l  HeightBitmapOffset(a5),d0       ;   hBitmap
    jsr     rToggleEndianness               ;   Toggle Endianness
    sub.l   dsArgSpriteY(a6),d0             ;-  ySprite
    sub.l   dsArgSpriteH(a6),d0             ;-  hSprite
    mulu    d1,d0                           ;x  rowWidthBytes
    add.l   d0,d2                           ;   iPixel += yPixel

    ;--- DrawLoop ---
    sub.l   #dlArgAlloc,sp                  ;Allocate Args
    move.l  a3,dlArgDisplayX(sp)            ;   xDisplay
    move.l  a2,dlArgDisplayY(sp)            ;   yDisplay
    move.l  d6,dlArgPenStartX(sp)           ;   xPenStart
    move.l  d5,dlArgPixelIncrement(sp)      ;   iPixelIncrement
    move.l  d2,dlArgPixelItr(sp)            ;   iPixel
    move.l  d3,dlArgPenY(sp)                ;   yPen
    move.l  d7,dlArgByteDepth(sp)           ;   byteDepth
    jsr     sDrawLoop                       ;Call
    add.l   #dlArgAlloc,sp                  ;Deallocate Args

    ;--- End Core Logic ---

    ;Restore Registers
    movem.l (sp)+,dsRegs
    
    ;Return
    rts
    
;=== Draw Sprite Return ===================
;==========================================

;==========================================
;=== Validate File ========================

;=== Registers ===
vfRegCount equ 5
vfRegs reg d0-d1/a1/a5-a6

;a6 = Arguments Pointer
;a5 = Bitmap Pointer
;a1 = Trap

;d1 = Comparison
;d0 = Comparison/Trap

;=== Arguments ===
vfArgCount equ 1
vfArgAlloc equ vfArgCount*StackVarSize
vfArgBmpAdr equ 0*StackVarSize

vfArgPointerOffset equ (vfRegCount+ReturnAddressOffset)*StackVarSize

;=== Data ===
vfFileSignature dc.b 'BM',0
vfErrorInvalidFileSignature dc.b 'Invalid File: Bad Signature',0
vfErrorInvalidBitsPerPixel dc.b 'Invalid File: Bits Per Pixel',0
    ORG (*+3)&-4  Force Long Word alignment
    
;=== Subroutine ===
sValidateFile
    ;Save Registers
    movem.l vfRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #vfArgPointerOffset,a6          ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  vfArgBmpAdr(a6),a5              ;a5 Bitmap Pointer
    
    ;--- Start Core Logic ---
    
    ;Validate File Signature
    move.w  SignatureBitmapOffset(a5),d0    ;d0 ActualSignature
    move.w  vfFileSignature,d1              ;d1 Expected Signature
    cmp.w   d0,d1                           ;Compare
    bne     InvalidFileSignature            ;Must Be Equal

    ;Validate Bit Depth    
    move.w  BitPerPixelBitmapOffset(a5),d0  ;d0 ActualBitDepth
    ror.w   #ByteSize,d0                    ;Toggle Endianness
    cmp.w   #24,d0                          ;Compare to 24
    beq     ValidBitsPerPixel               ;If Equal, Valid
    cmp.w   #32,d0                          ;Compare to 32
    beq     ValidBitsPerPixel               ;If Equal, Valid
    bra     InvalidBitsPerPixel             ;Else, Invalid
ValidBitsPerPixel
    
    ;--- End Core Logic ---
    
    ;Restore Registers
    movem.l (sp)+,vfRegs
    
    ;Return
    rts 

;Error Cases

InvalidFileSignature    
    ;Invalid File - Error Out
    lea     vfErrorInvalidFileSignature,a1
    jsr     rErrorOut
    
InvalidBitsPerPixel
    ;Invalid Bits Per Pixel - Error Out
    lea     vfErrorInvalidBitsPerPixel,a1
    jsr     rErrorOut


;=== Validate File Return =================
;==========================================

;==========================================
;=== Validate Input =======================

;=== Registers ===
viRegCount equ 10
viRegs reg d0/d2-d7/a1/a5-a6

;a6 = Arguments Pointer
;a5 = Bitmap Pointer
;a1 = Trap

;d7 = xSprite
;d6 = ySprite
;d5 = wSprite
;d4 = hSprite
;d3 = Bitmap Width
;d2 = Bitmap Height

;d0 = Comparison/Trap

;=== Arguments ===
viArgCount equ 5
viArgAlloc equ viArgCount*StackVarSize
viArgBmpAdr equ 0*StackVarSize
viArgSpriteX equ 1*StackVarSize
viArgSpriteY equ 2*StackVarSize
viArgSpriteW equ 3*StackVarSize
viArgSpriteH equ 4*StackVarSize

viArgPointerOffset equ (viRegCount+ReturnAddressOffset)*StackVarSize

;=== Data ===
viErrorInvalidSpriteW dc.b 'Invalid Input: Sprite Width Must be Greater than Zero',0
viErrorInvalidSpriteH dc.b 'Invalid Input: Sprite Height Must be Greater than Zero',0
viErrorInvalidLeft dc.b 'Invalid Input: Bitmap Left Bounds Exceeded',0
viErrorInvalidRight dc.b 'Invalid Input: Bitmap Right Bounds Exceeded',0
viErrorInvalidTop dc.b 'Invalid Input: Bitmap Top Bounds Exceeded',0
viErrorInvalidBottom dc.b 'Invalid Input: Bitmap Bottom Bounds Exceeded',0
    ORG (*+3)&-4  Force Long Word alignment
    
;=== Subroutine ===
sValidateInput
    ;Save Registers
    movem.l viRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #viArgPointerOffset,a6          ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  viArgBmpAdr(a6),a5              ;a5 Bitmap Pointer
    move.l  viArgSpriteX(a6),d7             ;d7 xSprite
    move.l  viArgSpriteY(a6),d6             ;d6 ySprite
    move.l  viArgSpriteW(a6),d5             ;d5 wSprite
    move.l  viArgSpriteH(a6),d4             ;d4 hSprite
    
    ;--- Start Core Logic ---
    
    ;Get and Convert Bitmap Values
    move.l  WidthBitmapOffset(a5),d0        ;Get Width
    jsr     rToggleEndianness               ;Toggle Endianness
    move.l  d0,d3                           ;d3 Bitmap Width
    
    move.l  HeightBitmapOffset(a5),d0       ;Get Height
    jsr     rToggleEndianness               ;Toggle Endianness
    move.l  d0,d2                           ;d2 Bitmap Height   

    ;Validate wSprite
    cmp.l   #0,d5
    ble     InvalidSpriteW
    
    ;Validate hSprite
    cmp.l   #0,d4
    ble     InvalidSpriteH
    
    ;Validate Sprite Within Bitmap Left
    move.l  d7,d0                           ;d0 x
    cmp.l   #0,d0                           ;Compare to 0
    ble     InvalidLeftBounds               ;If Less than or Equal, Invalid
    
    ;Validate Sprite Within Bitmap Right
    add.l   d5,d0                           ;d0 += w
    cmp.l   d3,d0                           ;Compare to Width
    bgt     InvalidRightBounds              ;If Greater Than, Invalid
    
    ;Validate Sprite Within Bitmap Top
    move.l  d6,d0                           ;d0 = y
    cmp.l   #0,d0                           ;Compare to 0
    ble     InvalidTopBounds                ;If Less than or Equal, Invalid

    ;Validate Sprite Within Bitmap Bottom
    add.l   d4,d0                           ;d0 += h
    cmp.l   d2,d0                           ;Compare to Height
    bgt     InvalidBottomBounds             ;If Greater Than, Invalid

    ;--- End Core Logic ---
    
    ;Restore Registers
    movem.l (sp)+,viRegs
    
    ;Return
    rts 

;Error Cases
InvalidSpriteW
    ;Invalid Input - wSprite
    lea     viErrorInvalidSpriteW,a1 
    jsr     rErrorOut

InvalidSpriteH
    ;Invalid Input - hSprite
    lea     viErrorInvalidSpriteH,a1
    jsr     rErrorOut

InvalidLeftBounds    
    ;Invalid Input - Left Bounds
    lea     viErrorInvalidLeft,a1
    jsr     rErrorOut
    
InvalidRightBounds    
    ;Invalid Input - Right Bounds
    lea     viErrorInvalidRight,a1
    jsr     rErrorOut

InvalidTopBounds    
    ;Invalid Input - Right Bounds
    lea     viErrorInvalidTop,a1
    jsr     rErrorOut

InvalidBottomBounds    
    ;Invalid Input - Bottom Bounds
    lea     viErrorInvalidBottom,a1
    jsr     rErrorOut

;=== Validate Input Return ================
;==========================================

;==========================================
;=== Get Pixel Increment ==================

;=== Registers ===
gpiRegCount equ 7
gpiRegs reg d0-d1/d5-d7/a5-a6

;a6 = Arguments Pointer
;a5 = Bitmap Pointer

;d7 = byteDepth
;d6 = Out iPixelIncrement
;d5 = Out rowWidthBytes
;d1 = Temp
;d0 = Temp

;=== Arguments ===
gpiArgCount equ 5
gpiArgAlloc equ gpiArgCount*StackVarSize
gpiArgBmpAdr equ 0*StackVarSize
gpiArgByteDepth equ 1*StackVarSize
gpiArgSpriteW equ 2*StackVarSize
gpiArgOutPixelInc equ 3*StackVarSize
gpiArgOutRowWBytes equ 4*StackVarSize

gpiArgPointerOffset equ (gpiRegCount+ReturnAddressOffset)*StackVarSize
 
;=== Subroutine ===
sGetPixelIncrement
    ;Save Registers
    movem.l gpiRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #gpiArgPointerOffset,a6         ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  gpiArgBmpAdr(a6),a5             ;a5 Bitmap Pointer
    move.l  gpiArgByteDepth(a6),d7          ;d7 byteDepth
    
    ;--- Start Core Logic ---    
    
    ;Get rowWidthBytes
    move.l  WidthBitmapOffset(a5),d0        ;   wBitmap
    jsr     rToggleEndianness               ;   Convert Endianness
    mulu    d7,d0                           ;x  byteDepth
    move.l  d0,d5                           ;d5 rowWidthBytes
    
    ;Get paddingBytes
    divu    #4,d0                           ;Divide rowWidthBytes by 4
    clr.w   d0                              ;Clear quotient 
    swap    d0                              ;Swap Remainder to Lower Word 
    cmp.w   #0,d0                           ;Check if remainder                      
    beq     NoPadding                       ;If Not, Skip Padding
;Add Padding
    move.l  #4,d1                           ;If So, Subtract remainder from 4
    sub.b   d0,d1                           ;d1 Padding
    add.l   d1,d5                           ;   rowWidthBytes += padding
NoPadding
    ;Add wSpriteBytes
    move.l  d5,d6                           ;d6 iPixelIncrement = rowWidthBytes 
    move.l  gpiArgSpriteW(a6),d0            ;d0 wSprite
    mulu    d7,d0                           ;x  byteDepth
    add.l   d0,d6                           ;+  iPixelIncrement += wSpriteBytes 
     
    ;--- End Core Logic ---
    
    ;Set Out Args
    move.l  d6,gpiArgOutPixelInc(a6)
    move.l  d5,gpiArgOutRowWBytes(a6)
    
    ;Restore Registers
    movem.l (sp)+,gpiRegs
    
    ;Return
    rts

;=== Get Pixel Increment Return ===========
;==========================================

;==========================================
;=== Draw Loop ============================

;=== Registers ===
dlRegCount equ 9
dlRegs reg d0-d7/a6

;a6 = Arguments Pointer
;a5 = ByteDepth Data

;d7 = xDisplay
;d6 = yDisplay
;d5 = xPenStart
;d4 = iPixelIncrement
;d3 = iPixel
;d2 = yPen
;d1 = xPen
;d0 = Trap

;=== Arguments ===
dlArgCount equ 7
dlArgAlloc equ dlArgCount*StackVarSize
dlArgDisplayX equ 0*StackVarSize
dlArgDisplayY equ 1*StackVarSize
dlArgPenStartX equ 2*StackVarSize
dlArgPixelIncrement equ 3*StackVarSize
dlArgPixelItr equ 4*StackVarSize
dlArgPenY equ 5*StackVarSize
dlArgByteDepth equ 6*StackVarSize

dlArgPointerOffset equ (dlRegCount+ReturnAddressOffset)*StackVarSize
 
;=== Subroutine ===
sDrawLoop
    ;Save Registers
    movem.l dlRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #dlArgPointerOffset,a6          ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  dlArgDisplayX(a6),d7            ;d7 xDisplay
    move.l  dlArgDisplayY(a6),d6            ;d6 yDisplay
    move.l  dlArgPenStartX(a6),d5           ;d5 xPenStart
    move.l  dlArgPixelIncrement(a6),d4      ;d4 iPixelIncrement
    move.l  dlArgPixelItr(a6),d3            ;d3 iPixel
    move.l  dlArgPenY(a6),d2                ;d2 yPen
    move.l  dlArgByteDepth(a6),a5           ;a5 byteDepth
    
    ;--- Start Core Logic ---  
ColumnLoop    
    ;Set xPen                               ;d3
    move.l  d5,d1                           ;xPen = xPenStart
    
RowLoop    

    ;Set Pen Color
    sub.l   #spcArgAlloc,sp                 ;Allocate Args
    move.l  a5,spcArgByteDepth(sp)          ;   byteDepth
    move.l  d3,spcArgPixelItr(sp)           ;   iPixel
    jsr     sSetPenColor                    ;Call
    move.l  spcArgPixelItr(sp),d3           ;Out iPixel
    add.l   #spcArgAlloc,sp                 ;Deallocate Args

    ;Draw Pixel
    move.b  #DrawPixelTask,d0               ;Draw Pixel
    trap    #SimulatorControlTrapCode
    
    ;Row Loop Logic
    sub.l   #1,d1                           ;xPen--    
    cmp.l   d7,d1                           ;while xPen >= xDisplay    
    bge     RowLoop                         ;Loop Row
;RowLoopEnd

    ;Column Loop Logic
    add.l   d4,d3                           ;iPixel += iPixelIncrement 
    sub.l   #1,d2                           ;yPen--
    cmp.l   d6,d2                           ;while yPen >= yDisplay
    bge     ColumnLoop                      ;Loop Column
;ColumnLoopEnd  

    ;--- End Core Logic ---
    
    ;Restore Registers
    movem.l (sp)+,dlRegs
    
    ;Return
    rts

;=== Draw Loop Return =====================
;==========================================

;==========================================
;=== Set Pen Color ========================

;=== Registers ===
spcRegCount equ 6
spcRegs reg d0-d2/d7/a5/a6

;a6 = Arguments Pointer
;a5 = iPixel

;d7 = byteDepth
;d2 = Loop Iterator
;d1 = Color
;d0 = Trap

;=== Arguments ===
spcArgCount equ 2
spcArgAlloc equ spcArgCount*StackVarSize
spcArgByteDepth equ 0*StackVarSize
spcArgPixelItr equ 1*StackVarSize

spcArgPointerOffset equ (spcRegCount+ReturnAddressOffset)*StackVarSize
 
;=== Subroutine ===
sSetPenColor
    ;Save Registers
    movem.l spcRegs,-(sp)
    
    ;Get Arguments Pointer
    move.l  sp,a6
    add.l   #spcArgPointerOffset,a6         ;a6 Argument Pointer
    
    ;Get Arguments
    move.l  spcArgByteDepth(a6),d7          ;d7 ByteDepth
    move.l  spcArgPixelItr(a6),a5           ;a5 iPixel Pointer
    
    ;--- Start Core Logic ---
    
    ;Set Pixel Color
    cmp.b   #4,d7                           ;If ByteDepth == 4
    beq     Get32BitColor                   ;Get 32 Bit Color
                                            ;Else 
;Get24BitColor                              ;Get 24 Bit Color
    clr.l   d1
    sub.l   #3,a5                           ;Put iPixel at Start of Next Pixel
    move.l  #2,d2                           ;Pack Next 3 Bytes
    
ColorPackLoop    
    lsl.l   #8,d1                           ;Shift Left
    move.b  (a5)+,d1                        ;Move Next Byte
    dbra    d2,ColorPackLoop                ;Loop
;ColorPackLoopEnd

    sub.l   #3,a5                           ;Reset iPixel    
    bra     SetColorEnd
;Get24BitColorEnd

Get32BitColor    
    move.l  -(a5),d1                        ;Get Next Pixel
    lsr.l   #ByteSize,d1                    ;Shift off alpha
    
SetColorEnd

    ;Set Pen Color
    move.b  #SetPenColorTask,d0
    trap    #SimulatorControlTrapCode
    
    ;--- End Core Logic ---
    ;Set Out Args
    move.l  a5,spcArgPixelItr(a6)
    
    ;Restore Registers
    movem.l (sp)+,spcRegs
    
    ;Return
    rts 

;=== Set Pen Color Return =================
;==========================================

;------------------------------------------
;--- Register Subroutines -----------------
;------------------------------------------

;==========================================
;=== Error Out ============================

;Writes the string in a1 to the display and ends the simulation

;Registers
;   a1 = string to display
;   d0 = display string task
rErrorOut
    move.l  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode
    SIMHALT

;=== Error Out End ========================
;==========================================

;==========================================
;=== Toggle Endianness ====================

;Toggles the Endianness of the Long Word in register d0

;Registers
;   d0 = input, manipulation, output
rToggleEndianness
    ror.w   #ByteSize,d0    ;Convert Lower Word
    swap    d0              ;Swap Words
    ror.w   #ByteSize,d0    ;Convert Lower Word
    rts

;=== Toggle Endianness Return =============
;==========================================

    ORG (*+3)&-4  Force Long Word alignment 

*BitmapFile  INCBIN "data/small_24.bmp"
*BitmapFile  INCBIN "data/small_32.bmp"
*BitmapFile  INCBIN "data/badFile.bad"

*BitmapFile  INCBIN "data/corner_rainbow.bmp"
*BitmapFile  INCBIN "data/corner_rainbow_odd.bmp"
*BitmapFile  INCBIN "data/OddBMP24_501x623.bmp"
*BitmapFile  INCBIN "data/OddBMP24_502x624.bmp"
*BitmapFile  INCBIN "data/OddBMP24_503x625.bmp"
*BitmapFile  INCBIN "data/vertical_rainbow.bmp"
*BitmapFile  INCBIN "data/sprite-sheet-mario_24.bmp"
BitmapFile  INCBIN "data/sprite-sheet-mario_32.bmp"

    END    START        ; last line of source















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
