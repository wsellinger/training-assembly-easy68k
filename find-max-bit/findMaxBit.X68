*-----------------------------------------------------------
* Title      : Find Max Bit
* Description: Traverse a binary file, find the maximum bit 
*              value, and store it in d1.
*-----------------------------------------------------------
    ORG     $1000
START:
   
    lea     DataStart, a0
    clr.l   d0
    clr.l   d1
    
GetMaxLoopStart:
    move.b  (a0)+, d0   ; get next value and increment address
    cmp.l   d1, d0      ; is value higher than current highest
    blt     NotGreater  ; skip over save if not higher
    move.b  d0, d1      ; value is the highest yet, save it
    
NotGreater:
    cmp.l   #DataEnd, a0 
    bne     GetMaxLoopStart
;GetMaxLoop End

    SIMHALT

DataStart: 	
    INCBIN "sampleData.bin" 
DataEnd:
                                                          
    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
