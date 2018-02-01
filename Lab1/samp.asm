;---------------------------------------------
; Sample Layout for PIC assembly files.
; You would have a nice comment block here!
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
     
            movlw   B'00000111'
            movwf   INT1
            movlw   B'00111000'
            movwf   INT2

            movf    PORTB, 0
            andwf   INT1, 1
            andwf   INT2, 1
            bcf     STATUS, C
            RRF     INT2, 1     
            RRF     INT2, 1
            RRF     INT2, 1

            BTFSC   PORTC, 4
            goto    subtraction
addition:
            movf    INT1, 0
            addwf   INT2, 0 
            goto    output
subtraction:
            movf    INT2, 0
            subwf   INT1, 0
output:
            andlw   B'00000111'
            movwf   RESULT
            bcf     STATUS, C
            RLF     RESULT, 1
            RLF     RESULT, 1
            RLF     RESULT, 1
            RLF     RESULT, 1
    
            movf    RESULT, 0
           
            movwf   PORTD
            goto    main_loop		

			
            END                           ; don't forget the end!
