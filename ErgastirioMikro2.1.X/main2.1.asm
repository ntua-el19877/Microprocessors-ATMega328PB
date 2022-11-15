.include "m328pbdef.inc"

.equ DEL_mS = 500		;Delay in mS (1-4095)
.equ FORC_MHZ = 16		;Microcontroller operating freq in MHz
.equ DEL_NU = FORC_MHZ * DEL_mS	;delay_ms routinw : 1000*DEL_NU+6 cycles  
.equ DEL_0c5 = FORC_MHZ * 5
    
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
    
	
    
    ;initiallize pc4-0 for output and pd7 for input
    ser r18			
    out DDRC,r18		
    clr r18			
    out DDRD,r18		
   
    ldi r18 ,0
    ;initiallize portb for counter
    ser r26
    out DDRB,r26
    sei				;Sets the Global Interrupt Flag
    
loop1:
    ;loop untul INT1
    rjmp loop1		
			      
ISR1:
    push r25
    push r24
    ;Save r24, r25, SREG
    in r24,SREG			
    push r24
    
    ;check for debouncing
check_D_again:
    ldi r26,(1<<INTF1)
    out EIFR,r26
    ldi r24, low (DEL_0c5)
    ldi r25, high (DEL_0c5)	
    rcall delay_mS
    in r26,EIFR
    ror r26
    andi r26,1
    cpi r26,0
    brne check_D_again
    
    ;check for pd7
    in r16 , PIND		
    andi r16,0x80
    cpi r16,0x80
    brne not32_or_pd7
    
    ;check if whe got 32 interuptions
    inc r18			
    cpi r18 ,32
    brlo not32_or_pd7
    clr r18
    
not32_or_pd7:
    out PORTC,r18
    
    ; Set delay (number of cycles)
    ldi r24, low (DEL_NU)
    ldi r25, high (DEL_NU)	
    rcall delay_mS
    
    ; Restore r24, r25, SREG
    pop r24
    out SREG,r24		
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