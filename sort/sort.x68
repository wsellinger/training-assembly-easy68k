*-----------------------------------------------------------
* Title         : Sorting
* Description   : Implementation of a sorting algorithm in Assembly
*
* Overview:
* Complete the missing code in the Sort Template code provided below to sort data.
* Note:  Do not use structured assembly. No higher-level commands like IF, etc.

* Create your own data file to sort in and sort the data as signed words. 
* This should be in a separate location (You should NOT be sorting in place. Sort into a 
* new location in memory) 
*
* Hint
* Use code from your previously implemented Find Max. 
* Use dc.w to make a small array to sort first to test your algorithm before going to file-based sort
* Link to visualized sorting algorithms: https://www.toptal.com/developers/sorting-algorithms 

    ORG     $1000
START

;Copy Input to Output
    move.l  #(InputDataEnd-InputDataStart),d0       ; Get Output Length
    beq     Exit                                    ; Exit, No Data to Sort

    lea     InputDataStart, a0                      ; Input Copy Iterator
    lea     OutputDataStart, a1                     ; Output Copy Iterator
    
CopyLoop
    move.b  (a0)+, (a1)+                            ; Copy and Increment
    cmp.l   #InputDataEnd, a0                       ; If Not End of Data
    bne     CopyLoop                                ; Loop
;CopyLoop End

;Sort Output
    move.l  #(OutputDataEnd-OutputDataStart-1),d0   ; Get Loop Iterations (length-1, we compare 2 at a time)
    beq     Exit                                    ; Exit If No Iterations
    
    lea     OutputDataEnd, a0                       ; Comparison Loop End Address

BubbleSortLoop
    sub.l   #1, d0                                  ; Decrement Sort Loop Count
    sub.l   #1, a0                                  ; Decrement Compare Loop End
    clr     d3                                      ; Clear Swap Flag
    lea     OutputDataStart, a1                     ; Comparison Iterator
    
ComparisonLoop
    move.b  (a1)+, d1                               ; Get First Value And Increment
    move.b  (a1),d2                                 ; Get Second Value

    cmp.b   d2, d1                                  ; If not Greater Than
    ble     SkipSwap                                ; Skip Swap Logic

;Swap Values
    move.b  #1, d3                                  ; Set Swap Flag
    sub.l   #1, a1                                  ; Reset Iterator To First Address
    move.b  d2, (a1)+                               ; Move Second Value Backward And Increment Address
    move.b  d1, (a1)                                ; Move First Value Forward

SkipSwap
    cmp.l   a1, a0                                  ; If Not At End Of Data
    bne     ComparisonLoop                          ; Loop 
;ComparisonLoop End

    cmp.b   #0, d3                                  ; If No Swap Made
    beq     Exit                                    ; Exit (Array Is Sorted)

    cmp.l   #0, d0                                  ; If Iterations Remain
    bne     BubbleSortLoop                          ; Loop
;BubbleSortLoop End

Exit
    SIMHALT
          
InputDataStart
    INCBIN  "randdata.bin" ;randdata
InputDataEnd

OutputDataStart
    ds.b    (InputDataEnd-InputDataStart)
OutputDataEnd

    END     START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
