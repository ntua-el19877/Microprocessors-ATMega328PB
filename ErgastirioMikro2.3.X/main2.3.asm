.include "m328pbdef.inc"

.equ DEL_mS = 4000		;Delay in mS (1-4095)
.equ FORC_MHZ = 16		;Microcontroller operating freq in MHz
.equ DEL_NU = FORC_MHZ * DEL_mS	;delay_ms routinw : 1000*DEL_NU+6 cycles  
.equ DEL_0c5S= FORC_MHZ*500
.equ DEL_3c5S=FORC_MHZ*3500
    
.org 0x0
    rjmp reset
.org 0x4
    rjmp ISR1
    
    
reset:
    ; Interrupt on rising edge of INTO pin
    
    ldi r24, (1<<ISC10)|(1<<ISC11)
    sts EICRA, r24
    ;Enable the INTO interrupt (PD2)
    ldi r24, (1<<INT1)
    out EIMSK, r24
    clr r26
    sei				;Sets the Global Interrupt Flag
    
    ser r26
    out DDRB,r26
    ldi r18,0
    clr r26
loop1:
	out PORTB,r26
	rjmp loop1
			      
ISR1:
    push r25
    push r24
    in r24,SREG		;Save r24, r25, SREG
    push r24
    
    rcall check_Debouncing
    
    rcall main_INT1
    
    pop r24
    out SREG,r24		; Restore r24, r25, SREG
    pop r24
    pop r25
    reti


delay_mS:
    ldi r23,249
   loop_inn:
    dec r23
    nop
    brne loop_inn
    sbiw r24,1
    brne delay_mS 
    ret

    ;check for debouncing
check_Debouncing:
    ldi r26,(1<<INTF1)
    out EIFR,r26
    ldi r24, low (DEL_0c5S)
    ldi r25, high (DEL_0c5S)	
    rcall delay_mS		;delay 5 msec
    in r26,EIFR
    ror r26
    andi r26,1
    cpi r26,0
    brne check_Debouncing
    ret
    
main_INT1:
    cpi r18,255			;if r18==11111111 then you added 4 sec 
    brne first_INT
    ;all leds on for 0.5 sec
    ser r26
    out PORTB,r26
    
    ldi r24, low (DEL_0c5S)
    ldi r25, high (DEL_0c5S)	; delay 0.5 sec
    rcall delay_mS
    ;PB0 on for 3.5 sec
    ldi r26,1
    out PORTB,r26
    
    ldi r24, low (DEL_3c5S)
    ldi r25, high (DEL_3c5S)	; delay 3.5 sec
    rcall delay_mS
    rjmp not_first_INT
first_INT:
    ldi r26,1
    out PORTB,r26
    ldi r24, low (DEL_NU)
    ldi r25, high (DEL_NU)	; Set delay (number of cycles)
    rcall delay_mS
    
not_first_INT:
    clr r26
    ;check for extra INT
    in r18,EIFR
    andi r18,2
    cpi r18,2
    brne no_extra_INT
    ser r18
    ldi r26,1
    rjmp skipthis
no_extra_INT:
    clr r18
skipthis:
    ret