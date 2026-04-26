*-----------------------------------------------------------
* Title         : Quicksort
* Description   : Implementation of Quicksort in Assembly
*
* a0: Partition Stack Iterator
*-----------------------------------------------------------

    ORG     $1000
    
START

    ;Copy Input
    move.l  #(InputDataEnd-InputDataStart),d0       ; Get Output Length
    beq     Exit                                    ; Exit, No Data to Sort

    lea     InputDataStart, a0                      ; Input Copy Iterator
    lea     OutputDataStart, a1                     ; Output Copy Iterator
    
CopyLoop
    move.b  (a0)+, (a1)+                            ; Copy and Increment
    cmp.l   #InputDataEnd, a0                       ; If Not End of Data
    bne     CopyLoop                                ; Loop
;CopyLoop End

    ;QuickSort
    lea     OutputDataStart, a0                     ; Get Data Address
    lea     PartitionStack, a1                      ; Get Partition Stack Iterator
    sub     #1, d0                                  ; Calculate Upper Bound
    move.l  #0, (a1)+                               ; Push Lower Bound
    move.l  d0, (a1)+                               ; Push Upper Bound

SortLoop
    move.l  -(a1),d1                                ; Pop Upper Bound
    move.l  -(a1),d0                                ; Pop Lower Bound
    
    ;Partition
    move.b  (a0,d1),d2                              ; Get Pivot Value (Last Element)
    move.l  d0, d3                                  ; Set Swap Index To Lower Bound
    move.l  d0, d4                                  ; Set Loop Index To Lower Bound
    
PartitionLoop
    ;Swap Conditional
    move.b  (a0,d4),d5                              ; Get Current Value
    cmp.b   d2, d5                                  ; If Current Value >= Pivot
    bge     SwapEnd                                 ; Skip Swap Logic  
    ;Swap Start
        move.b  (a0,d3),(a0,d4)                     ; Set Current Value To Swap Value
        move.b  d5,(a0,d3)                          ; Set Swap value To Saved Current Value    
        add.l   #1, d3                              ; Increment Swap Index    
SwapEnd

    add.l   #1, d4                                  ; Increment Loop Index
    cmp.l   d1, d4                                  ; If Not At Upper Bound
    bne     PartitionLoop                           ; Loop
;PartitionLoop End
    
    ;Swap Pivot
    move.b  (a0,d3),d5                              ; Get Swap Value
    move.b  (a0,d1),(a0,d3)                         ; Set Swap Value To Upper Bounds Value
    move.b  d5,(a0,d1)                              ; Set Upper Bounds Value To Swap Value
    
    ;Left Push Conditional
    move.l  d3,d5                                   ; Get Pivot Index
    sub.l   #1,d5                                   ; Set New Upper Bound
    cmp.l   d0,d5                                   ; If No Elements On Left
    ble     LeftPushEnd                             ; Skip Left Push
    ;Left Push Start
        move.l  d0, (a1)+                           ; Push Lower Bound
        move.l  d5, (a1)+                           ; Push Upper Bound
LeftPushEnd

    ;Right Push Conditional
    move.l  d3,d5                                   ; Get Pivot Index
    add.l   #1,d5                                   ; Set New Lower Bound
    cmp.l   d1,d5                                   ; If No Elements On Right
    bge     RightPushEnd                            ; Skip Right Push
    ;Right Push Start
        move.l  d5, (a1)+                           ; Push Lower Bound
        move.l  d1, (a1)+                           ; Push Upper Bound
RightPushEnd

    cmp.l   #PartitionStack, a1                     ; If Not Bottom of Stack
    bgt     SortLoop                                ; Loop
;SortLoop End

Exit
    SIMHALT
    
; Data
   
InputDataStart
    INCBIN  "randdata.bin" ;randdata
InputDataEnd

OutputDataStart
    ds.b    InputDataEnd-InputDataStart
OutputDataEnd

PartitionStack
    ds.b    InputDataEnd-InputDataStart+1

    END     START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
