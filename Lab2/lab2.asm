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
INNER_DELAY_AMOUNT  EQU 1
INNER_DELAY EQU 1


;-------------------------------
; Variables
;-------------------------------

MAX_STRING	EQU	8               
;STRING	db 0,1,2,3,4,5,6


;Declare the string here.
	
	
	
	   
	; Set the I/O directions for port pins
	; will get "messages" to "ensure bank bits okay"
	clrf    PORTB                 ; 
	clrf    PORTC                 ; 
	clrf    PORTD    
	bcf     STATUS, RP1            
	bsf     STATUS, RP0           ; Switch bank to bank 1
	bcf     OPTION_REG, NOT_RBPU  ; weak pull-ups on Port B
	movlw   B'00111111'           ; 1=input, 0=output
	movwf   TRISB                 ; Set all PORB directions
	movlw   B'00010000'           ; 1=input, 0=output
	movwf   TRISC                 ; Set all PORC directions
	movlw   B'00000000'           ; 1=input, 0=output
	movwf   TRISD                 ; Set all PORD directions
	
	bcf     STATUS, RP0           ; switch back to  bank 0
	
	;Delay for one second after startup.
	call	delay_sec

main_loop:
	
	
	BTFSS	PORTD, MODE_PIN	;First, move port D to W to check our mode.
	goto ma_mode

display_mode:

	;GetBitPattern 



ma_mode:




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

delay_sec:
	movlw  INNER_DELAY_AMOUNT
	movwf  INNER_DELAY
InnerLoop: 
	nop
	   ; Have from 0 to N nops
	nop 
	decfsz INNER_DELAY, f
	goto   InnerLoop

    RETURN

end