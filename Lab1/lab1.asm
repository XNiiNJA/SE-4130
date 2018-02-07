;---------------------------------------------
; Lab 1 implementation. Adds or subtracts ports B and C.
; Outputs result to port D.
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
MAX_SIZE    EQU     10               

;-------------------------------
; Variables
;-------------------------------
INT1         EQU     32                    ; first available RAM location, in decimal
INT2         EQU     33      
RESULT       EQU     34        

                
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

            bcf     STATUS, RP0           ; switch back to bank 0

main_loop:
            movlw   MAX_SIZE
            ;  etc.
     
            movlw   B'00000111'			  ; Move 111 to INT1
            movwf   INT1
            movlw   B'00111000'			  ; Move 111000 to INT2
            movwf   INT2

            movf    PORTB, 0			  ; Grab PORTB inputs.
            andwf   INT1, 1               ; AND INT1 with PORTB and store to file
            andwf   INT2, 1               ; AND INT2 with PORTB and store to file.
            bcf     STATUS, C             ; Clear the carry bit in STATUS.
            RRF     INT2, 1     		  ; SHIFT RIGHT INT2 3 times to correct offset.
            RRF     INT2, 1
            RRF     INT2, 1

            BTFSC   PORTC, 4			  ; Are we subtracting or adding?
            goto    subtraction			  ; We are subtracting. Goto subtraction
addition:
            movf    INT1, 0				  ; Move INT1 to W. Add INT2.
            addwf   INT2, 0 
            goto    output
subtraction:
            movf    INT2, 0				  ; Move INT2 to W
            subwf   INT1, 0               ; Subtract INT1
output:
            andlw   B'00000111'			  ; MASK all of the bits except for the lowest 3.
            movwf   RESULT				  ; MOVE to result memory locaiton
            bcf     STATUS, C             ; CLEAR the CARRY bit.
            RLF     RESULT, 1             ; SHIFT the result into position
            RLF     RESULT, 1
            RLF     RESULT, 1
            RLF     RESULT, 1
    
            movf    RESULT, 0			  ; MOVE the result to W.
           
            movwf   PORTD				  ; MOVE W into PORTD.
            goto    main_loop		      ; Repeat. Forever.

			
            END                           ; END.
