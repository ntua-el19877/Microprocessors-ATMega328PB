.include "m328pbdef.inc"

.equ FORC_MHZ = 1		;Microcontroller operating freq in MHz
.equ DEL_0c005S= FORC_MHZ*5

.org 0x0
    rjmp reset
.org 0x4
    rjmp ISR1
.org 0x1A
    rjmp ISR_TIMER1_OVF

reset:
    ; Interrupt on rising edge of INTO pin
    
    ldi r24, (1<<ISC11)|(1<<ISC10)
    sts EICRA, r24
    ;Enable the INTO interrupt (PD2)
    ldi r24, (1<<INT1)
    out EIMSK, r24
    clr r26
    
    ;init PC5 for input (the others are output)
    ldi r24,223
    out DDRC,r24
    
    ;init PORTB for output
    ser r24
    out DDRB,r24
    
    sei				;Sets the Global Interrupt Flag
    
loop1:
    in r24,PORTC
    andi r24,223
    cpi r24,0
    brne loop1
    rjmp timer1_init
    ;loop untul INT1
    rjmp loop1	    
    
ISR1:
    push r25
    push r24
    in r24,SREG			;Save r24, r25, SREG
    push r24
    
    ;check for debouncing
check_Debouncing:
    ldi r26,(1<<INTF1)
    out EIFR,r26
    ldi r24, low (DEL_0c005S)
    ldi r25, high (DEL_0c005S)	
    rcall delay_mS		;delay 5 msec
    in r26,EIFR
    ror r26
    andi r26,1
    cpi r26,0
    brne check_Debouncing

    ;code 
    
    pop r24
    out SREG,r24		; Restore r24, r25, SREG
    pop r24
    pop r25
    reti
    
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


timer1_init:
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    ;suxnothta aukshshs xronisth
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)
    sts TCCR1B,r24
    ;arxiki timh
    ldi r24,HIGH(3036)
    out TCNT1H,r24
    ldi r24,LOW(3036)
    out TCNT1L,r24
    ret

