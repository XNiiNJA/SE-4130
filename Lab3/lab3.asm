;---------------------------------------------
; Lab 3. Sets up two types of interrupts and counts the occurance of each.
; Also displays the number of occurances on PortC and PortD 
;
; Authors:
;    Grant Oberhauser
;    Grant Sanderson
;---------------------------------------------

    include "P16F877A.inc"
    LIST P=16F877A, R=DEC
    

	; XT (slow) Oscillator, Watchdog enabled, other config bits off
   	__config _XT_OSC & _WDT_ON & _CP_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF


;-------------------------------
; Constants
;-------------------------------

INNER  EQU 242
OUTER  EQU 5 


;-------------------------------
; Variables
;-------------------------------
INCOUNT 	EQU 32		;The variable for the inner count of the delay loop
OUTCOUNT    EQU 33		;The variable for the outer count of the delay loop
var			EQU	34		;A variable for temporary storage.

						;The following variables are stored in the common area
						;so they can be accessed from interrupts easily.

tmrCount	EQU	0x70	;The number of times the TMR interrupt was triggered.
rb0Count	EQU	0x71	;The number of times the RB0 interrupt was triggered.
w_save		EQU	0x72	;The variable W will be saved to in interrupts.
stat_save	EQU	0x73	;The variable the status register will be saved to in interrupts.



GOTO	main			;At the start of the program, jump to main.

ORG	4					;Start interrupt here.
	MOVWF	w_save		;In the interrupt save W and Status
	MOVF	STATUS, W
	MOVWF	stat_save

	BTFSC	INTCON, TMR0IF	; Is this a TMR0 interrupt?
	goto	TMR0_INT		; It is, go to TMR0_INT to handle.
	BTFSC	INTCON, INTF	; Is this an RB0 interrupt?
	goto	INTF_INT		; It is, go to INTF_INT to handle.
	goto	end_handle		; It is neither of these interrupts. Clean up interrupts.


TMR0_INT:
	BCF		INTCON, TMR0IF	; Clear the TMR0IF flag to leave interrupt.

	INCF	tmrCount, f		; Increment the tmr count

	movlw	0xFF			; Initialize TMR0 to 0xFF
	movwf	TMR0
	goto	end_handle
	
INTF_INT:
	BCF		INTCON,	INTF	; Clear the INTF flag to leave the interrupt.

	INCF	rb0Count, f		; Increment the rb0Count
		
	goto	end_handle		

end_handle:
	MOVF	STAT_SAVE, W	; Move the W and status back. 
	MOVWF	STATUS
	SWAPF	w_save, f
	SWAPF	w_save, w

	RETFIE					; Return from interrupt.



main:


	CALL	Delay			; Calling Delay 5 times before starting program.
	CALL	Delay
	CALL	Delay
	CALL	Delay
	CALL	Delay
	CLRWDT

    ; Set the I/O directions for port pins
    ; will get "messages" to "ensure bank bits okay"
    clrf    PORTB                 ; 
    clrf    PORTC                 ; 
    clrf    PORTD    
	clrf	var
    bcf     STATUS, RP1            
    bsf     STATUS, RP0           ; Switch bank to bank 1
    bcf     OPTION_REG, NOT_RBPU  ; weak pull-ups on Port B
    
	movlw   B'00010000'           ; 1=input, 0=output
    movwf   TRISA                 ; Set all PORB directions
    movlw   B'00000111'           ; 1=input, 0=output
    movwf   TRISB                 ; Set all PORB directions
    movlw   B'00001111'           ; 1=input, 0=output
    movwf   TRISC                 ; Set all PORC directions
    movlw   B'00001111'           ; 1=input, 0=output
    movwf   TRISD                 ; Set all PORD directions
    
	BSF		OPTION_REG,PSA		  ; Set prescaler to Watchdog/Not TMR0
	
	BSF		OPTION_REG,T0CS		  ; Set TMR0 clock source to RA4
	
	BSF		OPTION_REG,T0SE		  ; Set TMR0 to increment on high-to-low

	BCF		OPTION_REG,INTEDG	  ; Set Interrupt Edge RB0/INT to falling edge.

	BSF		INTCON, TMR0IE		  ; Enable TMR0 Overflow Interrupt

	BSF		INTCON, INTE		  ; RB0 /INT External Interrupt

	BSF		INTCON,	GIE			  ; Globally enable interrupts

	BCF		OPTION_REG, PS0		  ; Clear PS2:PS0 for WDT to be 1:1
	BCF		OPTION_REG, PS1
	BCF		OPTION_REG, PS2

	bcf     STATUS, RP0           ; switch back to  bank 0
    
	movlw	0xFF				  ; Initialize TMR0 to 0xFF
	movwf	TMR0

	;Initialize tmrCount and rb0Count
	clrf	tmrCount
	clrf	rb0Count


main_loop:

	CLRWDT							; Clear the watchdog timer at the top of the loop.

	BTFSC	PORTB, 1				; 
	goto	rb1_1
rb1_0:
	BTFSC	PORTB, 2
	goto	rb1_0_rb2_1
rb1_0_rb2_0:    				; Do this if RB1 = 0 and RB2 = 0
	movf	rb0Count,w			; Take rb0Count and move to W.
	movwf	var
	swapf	var, W				; Swap upper and lower bits and mask the upper bits.
	andlw	0xF0
	movwf	PORTC				; Move into PORTC
	movf	tmrCount,w			; Take tmrCount and move to W.
	movwf	var					; Swap the upper and lower bits.
	swapf	var, W
	andlw	0xF0				; Mask the upper bits
	movwf	PORTD				; Move to PORTD
		
	goto end_delay
rb1_0_rb2_1:					; Do this if RB1 = 0 and RB2 = 1
	movf	tmrCount,w			; Take tmrCount and move to W.
	movwf	var					
	swapf	var, W              ; Swap upper and lower bits and mask the upper bits.
	andlw	0xF0                
	movwf	PORTC               ; Move into PORTC
	movf	rb0Count,w          ; Take rb0Count and move to W.
	movwf	var                 ; Swap the upper and lower bits.
	swapf	var, W              
	andlw	0xF0                ; Mask the upper bits
	movwf	PORTD               ; Move to PORTD
	goto end_delay
rb1_1:
	BTFSC	PORTB, 2
	goto	rb1_1_rb2_1
rb1_1_rb2_0:					; Do this if RB1 = 1 and RB2 = 0
	movf	tmrCount,w			; Take tmrCount and move to W.
	movwf	var                 
	swapf	var, W              ; Swap upper and lower bits and mask the upper bits.
	andlw	0xF0                
	movwf	PORTC               ; Move into PORTC
	movf	tmrCount,w          ; Take tmrCount and move to W.
	andlw	0xF0                ; Mask the upper bits.
	movwf	PORTD               ; Move to PORTD
	goto end_delay              
rb1_1_rb2_1:					; Do this if RB1 = 1 and RB2 = 1
	movf	rb0Count,w			; Take rb0Count and move to W.
	movwf	var                 
	swapf	var, W              ; Swap upper and lower bits and mask the upper bits.
	andlw	0xF0                
	movwf	PORTC               ; Move into PORTC
	movf	rb0Count,w          ; Take rb0Count and move to W.
	movwf	var                 
	andlw	0xF0                ; Mask the upper bits.
	movwf	PORTD				; Move to PortD
	goto end_delay


end_delay:

	call	Delay				; At the end of the loop, delay.
	goto	main_loop			; Do the loop again.

Delay:

	; Delay is : VERY_DELAY * (2 + (2 + INNER_DELAY * 5 + 4) * OUTER_DELAY + 4) cycles

	; Values are: VERY_DELAY = 4
	;			  OUTER_DELAY = 200
	;             INNER_DELAY = 249				  

	; This gives us 1,002,000 cycles. One second is 1,000,000 cycles at 4 MHz
	movlw	OUTER
	movwf	OUTCOUNT
outer_loop:
	movlw	INNER
	movwf	INCOUNT
inner_loop:
	nop
	nop
	nop
	nop
	decfsz	INCOUNT, F
	goto	inner_loop

	decfsz	OUTCOUNT, F
	goto	outer_loop

	nop
	nop
	nop
	nop
	nop
  RETURN

end