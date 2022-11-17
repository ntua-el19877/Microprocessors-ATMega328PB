.include "m328pbdef.inc"

.equ DEL_mS = 4000		;Delay in mS (1-4095)
.equ FORC_MHZ = 16		;Microcontroller operating freq in MHz
.equ DEL_NU = FORC_MHZ * DEL_mS	;delay_ms routinw : 1000*DEL_NU+6 cycles  
.equ DEL_0c005S= FORC_MHZ*5
.equ DEL_3c5S=FORC_MHZ*3500
    
.org 0x0
    rjmp reset
.org 0x4
    rjmp ISR1
    
    
ISR1:
    push r25
    push r24
    ;Save r24, r25, SREG
    in r24,SREG			
    push r24
 
;------------------------------------------------------------------------    
    
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

;------------------------------------------------------------------------
    
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


