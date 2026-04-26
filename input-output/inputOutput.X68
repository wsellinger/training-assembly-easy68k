*-----------------------------------------------------------
* Title      : Input Output
* Description: Use trap codes to test inputs and output
*
* In this exercise, you will use trap codes to test inputs and output
* Be sure to use the Help -> Help? -> Simulator I/O

*   - Output 'Hello World' to the user
*       Note: You will have to declare your own string in memory with this

*   - On a new line, Output just 'Hello' from the same string to the user
*   - On a new line, Output just 'World' from the same string to the user
*   - On a new line, Output 'Hello' from the same string on the same line 
*       twice with a space in between

*   - On a new line, prompt the user for a string. Save this string 
*       into a memory location with a new label you create.
*       Note: make sure you can accomdate the maximum input noted size
*       in the Sim68K Text I/O in Help)

*   - On a new line, prompt the user for a letter. Continue to prompt
*       until they get the SecretLetter. Keep track of the number of 
*       guesses in the provided storage and output that number each time. 
*       Eg: 
*       > "Guess the letter"
*       > A         < user input
*       > "Incorrect guesses: 1"
*       > "Guess the letter"
*       Challenge: Make it case insensitive

*   - On a new line, prompt the user for a number. Continue to prompt
*       until they get the SecretNumber. Keep track of the number of 
*       guesses in the provided storage and output that number each time. 
*       Eg: 
*       > "Guess the number"
*       > 4         < user input
*       > "Incorrect guesses: 1"
*       > "Guess the number"
*       Note: What is the maximum number of guesses?

*   - Use Trap Code 19 to check for WASD input.
*       Output the key pressed.

*   - Use Trap Code 19 to check for Arrow Key input.
*       Output the key pressed (E.g. "Up", "Down", "Left", "Right")
*-----------------------------------------------------------

;Control Characters
BEL EQU  $07   Bell
BS  EQU  $08   Backspace
HT  EQU  $09   Tab (horizontal 5 characters)
LF  EQU  $0A   Line Feed
VT  EQU  $0B   Vertical tab (4 lines)
FF  EQU  $0C   Form Feed (Always end printing with a Form Feed.)
CR  EQU  $0D   Carriage Return 

;Key Codes
KeyCodeW        equ 'W'    
KeyCodeA        equ 'A'    
KeyCodeS        equ 'S'    
KeyCodeD        equ 'D' 

KeyCodeLeft     equ $25
KeyCodeUp       equ $26
KeyCodeRight    equ $27
KeyCodeDown     equ $28

;Calculated
LetterCaseDelta equ 'a'-'A'

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
DisplayStringNCharTask      equ 0
DisplayStringNCharNoLBTask  equ 1
DisplayStringAndDecTask     equ 17

DisplayCharTask             equ 6

ReadStringKeyboardInputTask equ 2
ReadCharKeyboardInputTask   equ 5
ReadNumKeyboardInputTask    equ 4
ReadKeyCurrentStateTask     equ 19

;Values
HelloStringCount    equ 5

    ORG    $1000
START:

;Logic

;1. Display String
    lea     GreetingString,a1
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    

;2. Display N Char of String
    move.b  #DisplayStringNCharTask,d0
    move.w  #HelloStringCount,d1
    trap    #SimulatorControlTrapCode  
    
;3. Display End of String
    move.b  #DisplayStringTask,d0
    add.l   #HelloStringCount+1,a1             ;Advance To 'World'
    trap    #SimulatorControlTrapCode

;4. Display N Char of String No Line Break
    lea     GreetingString,a1
    move.b  #DisplayStringNCharNoLBTask,d0
    move.w  #HelloStringCount+1,d1              ;Capture Space After 'Hello'
    trap    #SimulatorControlTrapCode  
    move.b  #DisplayStringNCharTask,d0
    trap    #SimulatorControlTrapCode
    
;5. Save User Input
    lea     UserInputPromptString,a1            ;Display Input Prompt
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode 
    
    lea     UserInputString,a1                  ;Read Input
    move.b  #ReadStringKeyboardInputTask,d0
    trap    #SimulatorControlTrapCode
    
;6. Letter Guess Game
    lea     LetterGuessAnswerChar,a2
    lea     LetterGuessGuessesCount,a3
    clr.l   d1
    clr.b   d3

LetterGuessStart
    lea     LetterGuessPromptString,a1          ;Display Input Prompt
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    

    move.b  #ReadCharKeyboardInputTask,d0       ;Read Input
    trap    #SimulatorControlTrapCode

    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0
    trap    #SimulatorControlTrapCode 

    move.b  (a2),d2                             ;To Byte
    cmp     d2,d1                               ;Uppercase Check
    beq     LetterGuessEnd                      ;Success!
    
    add.b   #LetterCaseDelta,d2                 ;To Upper
    cmp     d2,d1                               ;Lowercase Check
    beq     LetterGuessEnd                      ;Success!
    
    ;Wrong
    add.b   #1,d3                               ;Increment Guess Count
    move.b  d3,(a3)                             ;Save Current Guesses

    move.l  d3,d1                               ;Fail Response
    lea     GuessFailString,a1
    move.b  #DisplayStringAndDecTask,d0
    trap    #SimulatorControlTrapCode    
    
    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0    
    trap    #SimulatorControlTrapCode 
    
    bra     LetterGuessStart                    ;Try Again
    
    ;Right
LetterGuessEnd
    lea     GuessSuccessString,a1               ;Display Success
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode  

;7. Number Guess Game
    lea     NumberGuessAnswerChar,a2
    lea     NumberGuessGuessesCount,a3
    clr.l   d1
    clr.b   d3

NumberGuessStart
    lea     NumberGuessPromptString,a1          ;Display Input Prompt
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    

    move.b  #ReadNumKeyboardInputTask,d0        ;Read Input
    trap    #SimulatorControlTrapCode

    move.b  (a2),d2                             ;To Byte
    cmp     d2,d1                               ;Check
    beq     NumberGuessEnd                      ;Success!
    
    ;Wrong
    add.b   #1,d3                               ;Increment Guess Count
    move.b  d3,(a3)                             ;Save Current Guesses

    move.l  d3,d1                               ;Fail Response
    lea     GuessFailString,a1
    move.b  #DisplayStringAndDecTask,d0
    trap    #SimulatorControlTrapCode    
    
    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0
    trap    #SimulatorControlTrapCode 
    
    bra     NumberGuessStart                    ;Try Again
    
    ;Right
NumberGuessEnd
    lea     GuessSuccessString,a1               ;Display Success
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode  

;8. WASD Input
    lea     WasdInputPromptString,a1            ;Display Input Prompt
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    

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
    
    move.b  #'W',d1                             ;Display W
    move.b  #DisplayCharTask,d0                 
    trap    #SimulatorControlTrapCode
    bra     EndWasdInputChecks
    
CheckForA
    move.l  #PackedByte2,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForS
    
    move.b  #'A',d1                             ;Display A
    move.b  #DisplayCharTask,d0                 
    trap    #SimulatorControlTrapCode
    bra     EndWasdInputChecks

CheckForS
    move.l  #PackedByte3,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForD
    
    move.b  #'S',d1                             ;Display S
    move.b  #DisplayCharTask,d0                 
    trap    #SimulatorControlTrapCode  
    bra     EndWasdInputChecks
    
CheckForD
    move.l  #PackedByte4,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     EndWasdInputChecks
    
    move.b  #'D',d1                             ;Display D
    move.b  #DisplayCharTask,d0                 
    trap    #SimulatorControlTrapCode 

EndWasdInputChecks

    lea     LineBreak,a1                        ;Line Break
    move.b  #DisplayStringNoLBTask,d0
    trap    #SimulatorControlTrapCode 

;9. Arrow Key Input
    lea     ArrowInputPromptString,a1           ;Display Input Prompt
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    

ArrowInputLoopStart   
    move.l  #KeyCodeLeft<<24+KeyCodeRight<<16+KeyCodeUp<<8+KeyCodeDown,D1  ;Pack keycodes for Left, Right, Up, and Down

    move.b  #ReadKeyCurrentStateTask,d0
    trap    #SimulatorControlTrapCode
    
    cmp.l   #0,d1                               ;No Valid Key Input
    beq     ArrowInputLoopStart                 ;Continue Checking for Key Input
    
    move.l  d1,d2                               ;Save Off Result
    clr.l   d1                                  ;Clear to Allow Byte Instructions
    
;CheckForLeft
    move.l  #PackedByte1,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForRight
    
    lea     ArrowInputLeftString,a1             ;Display Left
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode    
    bra     EndArrowInputChecks
    
CheckForRight
    move.l  #PackedByte2,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForUp
    
    lea     ArrowInputRightString,a1            ;Display Right
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode
    bra     EndArrowInputChecks

CheckForUp
    move.l  #PackedByte3,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     CheckForDown
    
    lea     ArrowInputUpString,a1               ;Display Up
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode 
    bra     EndArrowInputChecks
    
CheckForDown
    move.l  #PackedByte4,d3
    and.l   d2,d3                               ;Zero Out All But Desired Byte
    beq     EndArrowInputChecks
    
    lea     ArrowInputDownString,a1             ;Display Down
    move.b  #DisplayStringTask,d0
    trap    #SimulatorControlTrapCode

EndArrowInputChecks
    
;End Of Program
    SIMHALT

;Data
LineBreak                   dc.b CR,LF,0

GreetingString              dc.b 'Hello World',0

UserInputPromptString       dc.b 'Input String To Save Below (Max 80 Chars)',0
UserInputString             ds.b 80

GuessFailString             dc.b 'Incorrect guesses: ',0
GuessSuccessString          dc.b 'Correct!',0

LetterGuessPromptString     dc.b 'Guess the letter',0
LetterGuessAnswerChar       dc.b 'N'
LetterGuessGuessesCount     dc.b 0

NumberGuessPromptString     dc.b 'Guess the number',0
NumberGuessAnswerChar       dc.b 10
NumberGuessGuessesCount     dc.b 0 ;max guesses 255

WasdInputPromptString       dc.b 'Press W,A,S, or D',0

ArrowInputPromptString      dc.b 'Press An Arrow Key',0
ArrowInputLeftString        dc.b 'Left',0
ArrowInputRightString       dc.b 'Right',0
ArrowInputUpString          dc.b 'Up',0
ArrowInputdownString        dc.b 'Down',0
    END    START








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
