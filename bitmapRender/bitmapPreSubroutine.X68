*-----------------------------------------------------------
* Title      : Bitmap PreSubroutine
* Description: Bitmap rendering without a subroutine

* In this exercise, write the logic to display a chunk of a .bmp file,
* then refactor that code to use a subroutine.

* The arguments required for your subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* You will need to handle 24-bit and 32-bit bitmaps

*-----------------------------------------------------------
* Part 1: Write the code to render a bitmap chunk without using a subroutine.
*-----------------------------------------------------------

;Constants

;Offsets
SignatureBitmapOffset equ 0
PixelArrayOffset equ 10
WidthBitmapOffset equ 18
HeightBitmapOffset equ 22
BitPerPixelBitmapOffset equ 28

;Trap
;Trap Code
SimulatorControlTrapCode equ 15

;Trap Tasks
DisplayStringTask equ 13

GetSetOutputWindowTask equ 33

SetPenColorTask equ 80
DrawPixelTask equ 82

;Misc
ByteSize equ 8

;Logic
    ORG    $1000
START:

;Registers
    ;Data
    ;d0-2 = temp
    ;d3 = x
    ;d4 = y
    ;d5 = rowLength (in pixels)
    ;d6 = fullRowLength (in bytes)
    ;d7 = bytesPerPixel
    
    ;Address
	;a4 = rowLength (in bytes)
    ;a5 = iPixel
    ;a6 = Bitmap File Start
	
	;Color Value Order = BGR

    lea BitmapFile,a6

    ;Validate File Signature
    move.w  SignatureBitmapOffset(a6),d0
    move.w  FileSignature,d1
    cmp.w   d0,d1
    beq     FileIsValid
    
    ;Invalid File - Error Out
    lea     ErrorInvalidFileSignature,a1
    move.l  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode
    
    SIMHALT

FileIsValid

    ;Set Resolution to Bitmap Size
    move.w  WidthBitmapOffset(a6),d1        ;Get Width
    ror.w   #ByteSize,d1                    ;Convert Endianness
    move.w  d1,d5                           ;Save rowLength
 
    swap    d1                              ;Pack to Left
    
    move.w  HeightBitmapOffset(a6),d1       ;Get Height
    ror.w   #ByteSize,d1                    ;Convert Endianness
    move.w  d1,d4                           ;Save Y
    
    move.l  #GetSetOutputWindowTask,d0      ;Set Resolution Task
    trap    #SimulatorControlTrapCode       ;Execute

    clr.l   d0
    clr.l   d1
    clr.l   d2

    ;Set Bytes Per Pixel
    move.w  BitPerPixelBitmapOffset(a6),d7  ;Get Bits Per Pixel
    ror.w   #ByteSize,d7                    ;Convert Endianness
    divu    #8,d7                           ;Convert Bits to Bytes
    
BitsPerPixelIsValid

    ;DrawBitmap
    
    ;Get Start of Array
    move.w  PixelArrayOffset(a6),d0         ;Get Start of Array Offset
    ror.w   #ByteSize,d0                    ;Convert Endianness    
    add.l   a6,d0                           ;Add to Start of File
    move.l  d0,a5                           ;Set iPixel to Start of Array
    
    ;Calculate Full Row Length
    clr.l   d0
    move.w  d5,d0
    mulu    d7,d0                           ;Convert rowLength from Pixels to Bytes
    divu    #4,d0
    clr.w   d0
    swap    d0                              ;Remainder in Lower Word    
    
    cmp.w   #0,d0                           ;Calculate Padding  
    beq     NoPadding    
    move.b  #4,d6
    sub.b   d0,d6 
                            
NoPadding
    lea     RowLengthInBytes,a4
    move.w  d5,d0                           ;Convert rowLength from Pixels to Bytes
    mulu    d7,d0
    move.w  d0,(a4)                         ;Save RowLengthInBytes
    
    add.w   d0,d6                           ;Add rowLength to Padding  

    ;Adjust Pixel Pos for Loop
    sub.w   #1,d5                           ;Adjust For 0 Indexed Display xStart
    sub.w   #1,d4                           ;Adjust For 0 Indexed Display y
    
ColumnLoop
    move.w  d5,d3                           ;Set/Reset X
    add.w   (a4),a5                         ;Put iPixel at Row End
    
RowLoop    
    ;Set Pixel Color
    cmp.b   #4,d7
    beq     Set32BitColor    

;Set24BitColor
    clr.l   d1
    sub.l   #3,a5                           ;Put iPixel at Start of Next Pixel
    move.l  #2,d2                           ;Pack Next 3 Bytes
    
ColorPackLoop    
    lsl.l   #8,d1
    move.b  (a5)+,d1
    dbra    d2,ColorPackLoop                ;Loop
;ColorPackLoopEnd

    sub.l   #3,a5                           ;Reset iPixel    
    bra     SetColorEnd

Set32BitColor    
    move.l  -(a5),d1                        ;Get Next Pixel
    lsr.l   #ByteSize,d1                    ;Shift off alpha
    
SetColorEnd

    ;Set Pen Color
    move.b  #SetPenColorTask,d0             ;Set Pen Color
    trap    #SimulatorControlTrapCode

    ;Draw Pixel
    clr.l   d1
    clr.l   d2
    move.w  d3,d1                           ;Set X
    move.w  d4,d2                           ;Set Y
    move.b  #DrawPixelTask,d0               ;Draw Pixel
    trap    #SimulatorControlTrapCode

    dbra    d3,RowLoop                      ;Loop Row
;RowLoopEnd

    add.l   d6,a5                           ;Advance iPixel to Next Row
    
    dbra    d4,ColumnLoop                   ;Loop Column
;ColumnLoopEnd

    SIMHALT

;Data
    
FileSignature dc.b 'BM',0
ErrorInvalidFileSignature dc.b 'Invalid File Signature',0

ErrorInvalidBitsPerPixel dc.b 'Invalid Bits Per Pixel',0
    
RowLengthInBytes ds.w 1
   
;Force Long Word alignment
    ORG   (*+3)&-4 

*BitmapFile  INCBIN "data/small_24.bmp"
*BitmapFile  INCBIN "data/small_32.bmp"
*BitmapFile  INCBIN "data/corner_rainbow.bmp"
*BitmapFile  INCBIN "data/corner_rainbow_odd.bmp"
*BitmapFile  INCBIN "data/OddBMP24_501x623.bmp"
*BitmapFile  INCBIN "data/OddBMP24_502x624.bmp"
*BitmapFile  INCBIN "data/OddBMP24_503x625.bmp"
BitmapFile  INCBIN "data/vertical_rainbow.bmp"

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
