.include "m328pbdef.inc"

.equ FORC_MHZ = 1		;Microcontroller operating freq in MHz
.equ DEL_0c005S= FORC_MHZ*5
.equ DEL_0c5S= FORC_MHZ*500
.equ DEL_3c5S= FORC_MHZ*3500
.equ DEL_4S= FORC_MHZ*4000    
.equ value=57724
    
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
    out PORTB,r26
    in r24,PINC
    cpi r24,1
    brne nott
    jmp thiss
nott:
    andi r24,32
    cpi r24,32
    brne loop1
    
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    
    ;arxiki timh
    ldi r24,HIGH(value)
    sts TCNT1H,r24
    ldi r24,LOW(value)
    sts TCNT1L,r24
    
    ;suxnothta aukshshs xronisth
    ldi r24,(1<<WG10)|(1<<COM1A1)
    sts TCCR1A,r24
    
    ;loop untul INT1
    rjmp loop1	    
;------------------------------------------------  
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
    ret
;------------------------------------------------------    
    
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
;--------------------------------------------------------
    
;turn leds off
ISR_TIMER1_OVF:
    clr r26
    out PORTB,r26
    reti
;-------------------------------------------------------
    
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
    ldi r24, low (DEL_4S)
    ldi r25, high (DEL_4S)	; Set delay (number of cycles)
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
;------------------------------------------------------



