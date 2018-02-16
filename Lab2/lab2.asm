;---------------------------------------------
; Lab 2.
; 
; Authors:
;    Grant Oberhauser
;    Grant Sanderson
;---------------------------------------------

    include "P16F877A.inc"
    LIST P=16F877A, R=DEC
    
    ; XT (slow) Oscillator, Watchdog disabled, other config bits off
    __config _XT_OSC & _WDT_OFF & _CP_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF

;-------------------------------
; Constants
;-------------------------------

MODE_PIN    EQU    4
INNER_DELAY_AMOUNT  EQU 200
OUTER_DELAY_AMOUNT  EQU 251
VERY_OUTER_DELAY_AMOUNT  EQU 4

MAX_STRING    EQU    8  


;-------------------------------
; Variables
;-------------------------------
INNER_DELAY EQU 32
OUTER_DELAY    EQU    33
VERY_DELAY    EQU 34
STRING_POS  EQU 35   ;Start at the 0 position of the string.
STRING_LEN    EQU    36
ARR_START   EQU 37     ;Nothing past this so we can grow easily


;Declare the string here.
    
    ; Set the I/O directions for port pins
    ; will get "messages" to "ensure bank bits okay"
    clrf    PORTB                 ; 
    clrf    PORTC                 ; 
    clrf    PORTD    
    bcf     STATUS, RP1            
    bsf     STATUS, RP0           ; Switch bank to bank 1
    bcf     OPTION_REG, NOT_RBPU  ; weak pull-ups on Port B
    movlw   B'11111111'           ; 1=input, 0=output
    movwf   TRISB                 ; Set all PORB directions
    movlw   B'00000000'           ; 1=input, 0=output
    movwf   TRISC                 ; Set all PORC directions
    movlw   B'11111111'           ; 1=input, 0=output
    movwf   TRISD                 ; Set all PORD directions
    
    bcf     STATUS, RP0           ; switch back to  bank 0
    

    call SetUpString

    ;Initialize the STRING_POS variable. We're at the start.
    movlw    0
    movwf    STRING_POS

    ;Delay for one second after startup.
    call    delay_sec

main_loop:
    
    
    BTFSC    PORTD, MODE_PIN        ;First, move port D to W to check our mode.
    goto ma_mode

display_mode:


    MOVF    STRING_POS, W           ;Check if we should loop back the string index.

    SUBWF    STRING_LEN, W

    BTFSC    STATUS, Z
    MOVWF    STRING_POS

    
    ;Grab the current letter out of memory
    MOVLW    ARR_START              ;Load the start of the array
    ADDWF    STRING_POS, W          ;Offset the array address by our current position.
    MOVWF    FSR                    ;Put the final address into FSR

    MOVF    INDF, W                 ;Move the value of the address pointed to into W.

    CALL    GetBitPattern           ;Get the related 7-seg value.

    MOVWF    PORTC                  ;Finally, move the value to C.

    CALL    delay_sec

    INCF    STRING_POS, f           ; Increment string position

    
    goto main_loop

ma_mode:



    MOVLW    ARR_START              ; Move the ARR_START position to W.

    ADDWF    STRING_POS, w          ; Add the string position to get the address to point to.

    MOVWF    FSR                    ; Move the value to FSR to acces through INDF

    MOVF    STRING_POS, W           ; Check if we should loop back the string index.

    SUBWF    STRING_LEN, W          ; Subtracting STRING_POS and STRING_LEN to see if they are equal.

    BTFSS    STATUS, Z              ; Skip next line if they are equal.
    goto    modify_loop             ; They are not equal, go to modify_loop.

    MOVLW    MAX_STRING             ; The length and position are equal. We are appending now. 

    SUBWF    STRING_LEN, W          ; Ensure the MAX_STRING size has not been reached yet. 

    BTFSC    STATUS, Z              ; Skip the next line if they are not equal
    goto    too_big                 ; This happens if MAX_STRING = STRING_LEN
    
    INCF    STRING_LEN, f           ; We haven't reached the max size yet, increment STRING_LEN

;   Shouldn't need next 2 lines.
    
;   MOVF    STRING_POS              ; 

;   ADDWF    ARR_START, w

    MOVWF    FSR

    MOVLW    0                      ; Initialize the appending character as a space char.

    MOVWF    INDF                   ; Move into new position

    goto     modify_loop

too_big:

    MOVLW    0                      ; The string is at max size, simply loop STRING_POS to the front.
    MOVWF    STRING_POS

modify_loop:

    MOVLW    b'00011111'            ; Loading a mask for PORTB

    ANDWF    PORTB, W               ; Load PORTB by masking.

    CALL    GetBitPattern           ; Get the character PORTB value maps to.

    MOVWF    PORTC                  ; MOVE the character to PORTC to display on 7-segment.

    BTFSS    PORTD, 0               ; Is PORT D bit 0 cleared?
    goto    store_string            ; If it is cleared, store the string.

    BTFSC    PORTD, 4               ; Is PORT D bit 4 cleared?
    goto    modify_loop             ; If it is not cleared, keep looping.

    MOVLW    0                      ; Otherwise, reset STRING_POS and return to the main loop.
    
    MOVWF    STRING_POS

    goto    main_loop

store_string:

    MOVLW    b'00011111'            ; MASK PORTB

    ANDWF    PORTB, W

    MOVWF    INDF                   ; Store to current string position.

    goto     modify_loop

; Returns bit pattern for given number
GetBitPattern:
    addwf    pcl, f         ; jump to correct position
    retlw    B'00001000'    ;  0 = space  (looks like underscore)
    retlw    B'01110111'    ;  1 = A
    retlw    B'00011111'    ;  2 = b
    retlw    B'01001101'    ;  3 = C
    retlw    B'00111110'    ;  4 = d 
    retlw    B'01001111'    ;  5 = E
    retlw    B'01000111'    ;  6 = F
    retlw    B'01011101'    ;  7 = G
    retlw    B'00110111'    ;  8 = H
    retlw    B'00110000'    ;  9 = I
    retlw    B'00111000'    ; 10 = J
    retlw    B'00000010'    ; 11 = K = unimplemented
    retlw    B'00001101'    ; 12 = L
    retlw    B'00000010'    ; 13 = M = unimplemented
    retlw    B'00010110'    ; 14 = n
    retlw    B'01111101'    ; 15 = O
    retlw    B'01100111'    ; 16 = P
    retlw    B'00000010'    ; 17 = Q = unimplemented
    retlw    B'01000101'    ; 18 = r
    retlw    B'01011011'    ; 19 = S
    retlw    B'00001111'    ; 20 = t
    retlw    B'00111101'    ; 21 = U
    retlw    B'00000010'    ; 22 = V = unimplemented
    retlw    B'00000010'    ; 23 = W = unimplemented
    retlw    B'00000010'    ; 24 = X = unimplemented
    retlw    B'00111011'    ; 25 = y
    retlw    B'01101110'    ; 26 = Z
    retlw    B'00000010'    ; 27 = unimplemented
    retlw    B'00000010'    ; 28 = unimplemented
    retlw    B'00000010'    ; 29 = unimplemented
    retlw    B'00000010'    ; 30 = unimplemented
    retlw    B'00000010'    ; 31 = unimplemented

SetUpString:

    movlw  7             ; G
    movwf  ARR_START
    movlw  18            ; R
    movwf  ARR_START + 1
    movlw  1             ; A
    movwf  ARR_START + 2
    movlw  14            ; N
    movwf  ARR_START + 3
    movlw  20            ; T
    movwf  ARR_START + 4
    movlw  19            ; S
    movwf  ARR_START + 5


    movlw  6            ; String Length
    movwf  STRING_LEN
    return

delay_sec:

    movlw  VERY_OUTER_DELAY_AMOUNT      ; Load the first layer delay value.
    movwf  VERY_DELAY
very_outer_loop:

    movlw  OUTER_DELAY_AMOUNT           ; Load the second layer delay value.
    movwf  OUTER_DELAY
outer_loop:    
    movlw  INNER_DELAY_AMOUNT           ; Load the third layer delay value.
    movwf  INNER_DELAY
inner_loop: 
    nop                                 ; 2 NOPS to make the math work out.
    nop
    decfsz  INNER_DELAY                 ; Decrement and loop for the third layer loop
    goto    inner_loop
    
    decfsz  OUTER_DELAY                 ; Decrement and loop for the second layer loop
    goto    outer_loop

    decfsz  VERY_DELAY                  ; Decrement and loop for the first looop
    goto    very_outer_loop


    RETURN

end