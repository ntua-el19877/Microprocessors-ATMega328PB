.include "m328pbdef.inc"

.equ DEL_mS = 600		;Delay in mS (1-4095)
.equ FORC_MHZ = 16		;Microcontroller operating freq in MHz
.equ DEL_NU = FORC_MHZ * DEL_mS	;delay_ms routinw : 1000*DEL_NU+6 cycles  

.org 0x0
    rjmp reset
.org 0x2
    rjmp ISR0

reset:
    ; Interrupt on rising edge of INTO pin
    
    ldi r24, (1<<ISC01)|(1<<ISC00)
    sts EICRA, r24
    ;Enable the INTO interrupt (PD2)
    ldi r24, (1<<INT0)
    out EIMSK, r24
    clr r26
    sei				;Sets the Global Interrupt Flag
	
    
    ;initiallize pc4-0 for output and PORTB for input
    ser r26			
    out DDRC,r26		
    clr r26			
    out DDRB,r26		
   
loop1:
    ;loop untul INT1
    rjmp loop1		

;----------------------------------------------------------------
ISR0:
    push r25
    push r24
    in r24,SREG			;Save r24, r25, SREG
    push r24
    
    ;code 
    
    pop r24
    out SREG,r24		; Restore r24, r25, SREG
    pop r24
    pop r25
    reti

;-----------------------------------------------------------------
    
;delays by specific time
delay_mS:
    ldi r23,249
loop_inn:
    dec r23
    nop
    brne loop_inn
    sbiw r24,1
    brne delay_mS 
    ret
    
;counts how many ones are in one binary number   
count_ones:
    push r23
    push r22
    
    
    ldi r22,8		    ;8 logical shifts
    ldi r23,0		    ;number of ones
checkagain:
    rol r26
    brcs notzero		    ;if carry not zero goto
    inc r23		    ;found 1/////
notzero:
    dec r22 
    cpi r22,0
    brne checkagain
    
    
    mov r26,r23
    pop r22
    pop r23
    ret
    
;takes a number N in r26 and returns a number with N ones in r26
new_num_of_ones:
    
    ldi r19 ,0
    
checkagain1:
    cpi r26,0
    breq end1		    ;if no more ones end it
    dec r26
    rol r19
    inc	r19
    rcall checkagain1
end1:
    mov r26,r19
    
    ret


