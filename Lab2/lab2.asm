;---------------------------------------------
; Lab 2.
; 
; Authors:
;	Grant Oberhauser
;	Grant Sanderson
;---------------------------------------------

	include "P16F877A.inc"
	LIST P=16F877A, R=DEC
	
	; XT (slow) Oscillator, Watchdog disabled, other config bits off
	__config _XT_OSC & _WDT_OFF & _CP_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF

;-------------------------------
; Constants
;-------------------------------

MODE_PIN	EQU	4
INNER_DELAY_AMOUNT  EQU 200
OUTER_DELAY_AMOUNT  EQU 200
VERY_OUTER_DELAY_AMOUNT  EQU 100

MAX_STRING	EQU	8  


;-------------------------------
; Variables
;-------------------------------
INNER_DELAY EQU 32
OUTER_DELAY	EQU	33
VERY_DELAY	EQU 34
STRING_POS  EQU 35   ;Start at the 0 position of the string.
STRING_LEN	EQU	36
ARR_START   EQU 37	 ;Nothing past this so we can grow easily


;Declare the string here.
	
	; Set the I/O directions for port pins
	; will get "messages" to "ensure bank bits okay"
	clrf    PORTB                 ; 
	clrf    PORTC                 ; 
	clrf    PORTD    
	bcf     STATUS, RP1            
	bsf     STATUS, RP0           ; Switch bank to bank 1
	bcf     OPTION_REG, NOT_RBPU  ; weak pull-ups on Port B
	movlw   B'00000000'           ; 1=input, 0=output
	movwf   TRISB                 ; Set all PORB directions
	movlw   B'00000000'           ; 1=input, 0=output
	movwf   TRISC                 ; Set all PORC directions
	movlw   B'11111111'           ; 1=input, 0=output
	movwf   TRISD                 ; Set all PORD directions
	
	bcf     STATUS, RP0           ; switch back to  bank 0
	

	call SetUpString

	;Initialize the STRING_POS variable. We're at the start.
	movlw	0
	movwf	STRING_POS

	;Delay for one second after startup.
	call	delay_sec

main_loop:
	
	
	BTFSS	PORTD, MODE_PIN	;First, move port D to W to check our mode.
	goto ma_mode

display_mode:
	
	;Grab the current letter out of memory
	MOVLW	ARR_START		;Load the start of the array
	ADDWF	STRING_POS, W	;Offset the array address by our current position.
	MOVWF	FSR				;Put the final address into FSR

	MOVF	INDF, W			;Move the value of the address pointed to into W.

	CALL	GetBitPattern 		;Get the related 7-seg value.

	MOVWF	PORTC			;Finally, move the value to C.

	INCF	STRING_POS, f

	MOVF	STRING_POS, W		;Check if we should loop back the string index.

	SUBWF	STRING_LEN, W

	BTFSC	STATUS, Z
	MOVWF	STRING_POS
	
	CALL	delay_sec

ma_mode:

	MOVLW 	b'11111111'
	MOVWF	PORTC


	goto main_loop

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
	retlw    B'00000010'    ;  7 = G = unimplemented  (looks like dash)
	retlw    B'00000010'    ;  8 = H = unimplemented
	retlw    B'00000010'    ;  9 = I = unimplemented
	retlw    B'00000010'    ; 10 = J = unimplemented
	retlw    B'00000010'    ; 11 = K = unimplemented
	retlw    B'00000010'    ; 12 = L = unimplemented
	retlw    B'00000010'    ; 13 = M = unimplemented
	retlw    B'00000010'    ; 14 = N = unimplemented
	retlw    B'00000010'    ; 15 = O = unimplemented
	retlw    B'00000010'    ; 16 = P = unimplemented
	retlw    B'00000010'    ; 17 = Q = unimplemented
	retlw    B'00000010'    ; 18 = R = unimplemented
	retlw    B'00000010'    ; 19 = S = unimplemented
	retlw    B'00000010'    ; 20 = T = unimplemented
	retlw    B'00000010'    ; 21 = U = unimplemented
	retlw    B'00000010'    ; 22 = V = unimplemented
	retlw    B'00000010'    ; 23 = W = unimplemented
	retlw    B'00000010'    ; 24 = X = unimplemented
	retlw    B'00000010'    ; 25 = Y = unimplemented
	retlw    B'00000010'    ; 26 = Z = unimplemented
	retlw    B'00000010'    ; 27 = unimplemented
	retlw    B'00000010'    ; 28 = unimplemented
	retlw    B'00000010'    ; 29 = unimplemented
	retlw    B'00000010'    ; 30 = unimplemented
	retlw    B'00000010'    ; 31 = unimplemented

SetUpString:

    movlw  3            ; C
    movwf  ARR_START
    movlw  1            ; A
    movwf  ARR_START + 1
    movlw  6            ; F
    movwf  ARR_START + 2
    movlw  5            ; E
    movwf  ARR_START + 3
    movlw  4            ; String Length
    movwf  STRING_LEN
    return

delay_sec:
	movlw  INNER_DELAY_AMOUNT
	movwf  INNER_DELAY

	movlw  OUTER_DELAY_AMOUNT
	movwf  OUTER_DELAY

	movlw  VERY_OUTER_DELAY_AMOUNT
	movwf  VERY_DELAY

very_outer_loop:

outer_loop:

inner_loop: 
	
	decfsz INNER_DELAY, f
	goto   inner_loop

	decfsz OUTER_DELAY, f
	goto   outer_loop

	decfsz VERY_DELAY, f
	goto   very_outer_loop

    RETURN

end