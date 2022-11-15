.include "m328pbdef.inc"

.equ FORC_MHZ = 16		;Microcontroller operating freq in MHz
.equ DEL_0c005S= FORC_MHZ*5
.equ DEL_0c5S= FORC_MHZ*500
.equ DEL_3c5S= FORC_MHZ*3500
.equ DEL_4S= FORC_MHZ*4000    
.equ value_4_Sec_timer=3036
.equ value_3c5_Sec_timer=10848
.equ value_0c5_Sec_timer=57724
    
.org 0x0
    rjmp reset
.org 0x4
    rjmp ISR1
.org 0x1A
    rjmp ISR_TIMER1_OVF
    
;r18 keeps tap off the number of pd3/pc5 calls
reset:
    ; Interrupt on rising edge of INTO pin
    ldi r24,HIGH(RAMEND)
    out SPH,r24
    ldi r24,LOW(RAMEND)
    out SPL,r24
    
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
    clr r26
    clr r18
loop1:
    ;check for pc5
    in r24,PINC
 
    andi r24,32
    cpi r24,32
    breq loop1
    lds r24,TCCR1B
    cpi r24,0
    breq no_led_on
    
    ;we renew the timer
    ser r26
    out PORTB,r26
    
check_PC5_again:
    ;check if PC5 is 1 so wait again
    ldi r24, low (DEL_0c005S)
    ldi r25, high (DEL_0c005S)	
    rcall delay_mS
    in r24,PORTC
    andi r24,32
    cpi r24,0
    brne check_PC5_again
    
    ldi r24, low (DEL_0c5S)
    ldi r25, high (DEL_0c5S)	
    rcall delay_mS		;delay 5 msec
    
    ;check if PC5 is 1 so wait again
    ldi r24, low (DEL_0c005S)
    ldi r25, high (DEL_0c005S)	
    rcall delay_mS
    in r24,PORTC
    andi r24,32
    cpi r24,0
    brne check_PC5_again
    
    
    ldi r26,1
    out PORTB,r26
    ;arxiki timh
    ldi r24,HIGH(value_3c5_Sec_timer)
    sts TCNT1H,r24
    ldi r24,LOW(value_3c5_Sec_timer)
    sts TCNT1L,r24

    ;suxnothta aukshshs xronisth
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)
    sts TCCR1B,r24
    
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    rjmp loop1
no_led_on:
    ldi r26,1
    out PORTB,r26
    ;check if PC5 is 1 so wait again
    ldi r24, low (DEL_0c005S)
    ldi r25, high (DEL_0c005S)	
    rcall delay_mS
    in r24,PINC
    andi r24,32
    cpi r24,0
    breq no_led_on
    
    ;arxiki timh
    ldi r24,HIGH(value_4_Sec_timer)
    sts TCNT1H,r24
    ldi r24,LOW(value_4_Sec_timer)
    sts TCNT1L,r24

    ;suxnothta aukshshs xronisth
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)
    sts TCCR1B,r24
    
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    
    ldi r26,1
    out PORTB,r26
 
    ;loop untul INT1
    rjmp loop1	    
;------------------------------------------------  
ISR1:
    push r25
    push r24
    in r24,SREG		;Save r24, r25, SREG
    push r24
    
    ldi r26,1
    out PORTB,r26
    
    rcall check_Debouncing
    
    rcall main_INT1
    
    pop r24
    out SREG,r24		; Restore r24, r25, SREG
    pop r24
    pop r25
    reti
;---------------------------------------------------
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
;------------------------------------------------------------------------------------    
    
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
    ;suxnothta aukshshs xronisth
    ldi r24,(0<<CS12)|(0<<CS11)|(0<<CS10)
    sts TCCR1B,r24
    reti
;-------------------------------------------------------
    
main_INT1:
    ;check if there is already a led on
    lds r24,TCCR1B
    cpi r24,0
    breq no_led_on_INT1
    
    ser r26
    out PORTB,r26
    
    ldi r24, low (DEL_0c5S)
    ldi r25, high (DEL_0c5S)	
    rcall delay_mS		;delay 5 msec
    
    ldi r26,1
    out PORTB,r26
    ;arxiki timh
    ldi r24,HIGH(value_3c5_Sec_timer)
    sts TCNT1H,r24
    ldi r24,LOW(value_3c5_Sec_timer)
    sts TCNT1L,r24

    ;suxnothta aukshshs xronisth
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)
    sts TCCR1B,r24
    
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    
    reti
    
no_led_on_INT1:
    ;arxiki timh
    ldi r24,HIGH(value_4_Sec_timer)
    sts TCNT1H,r24
    ldi r24,LOW(value_4_Sec_timer)
    sts TCNT1L,r24

    ;suxnothta aukshshs xronisth
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)
    sts TCCR1B,r24
    
    ;energopoihsh diakophs uperxeilishs
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    
    ldi r26,1
    out PORTB,r26
    ret
;------------------------------------------------------
