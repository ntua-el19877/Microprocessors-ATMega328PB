

reset:  
	ldi r24 , low(RAMEND)	; initialize stack pointer
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	ser r24                 ; initialize PORTA for output
	out DDRB , r24
	clr r26 
	ldi r26 , 1             ; clear time counter

main:   
	out PORTB , r26            
	ldi r24 , low(100)      ; load r25:r24 with 1000 
	ldi r25 , high(100)     ; delay 1 second
	rcall wait_x_msec	; 3 cycles (3 usec)
				; 100*1000+3 =100.003 ms
	rol r26                 ; increment time counter, one second passed  
	brsh main
	ldi r26,1		; and then goto main
	rjmp main

wait_x_msec:
	push r24		; 2 cycles (2 usec)
	push r25		; 2 cycles (2 usec)
	ldi r24,low(98)		; 1 cycle (1 usec)
	ldi r25,high(98)	; 1 cycle (1 usec)
   	rcall wait_msec        	; 3 cycles (3 usec)
				; 97*10+1*(9+4) = 983 usec     
	pop r25			; 2 cycles (2 usec)
	pop r24			; 2 cycles (2 usec)
   	sbiw r24 , 1          	; 2 cycles (2 usec)
   	brne wait_x_msec        ; 1 or 2 cycles (1 or 2 usec)
   	ret			; 4 cycles (4 usec)
	
wait_msec:   
	sbiw r24 ,1      	; 2 cycles (2 usec)  
	nop           		; 1 cycle (1 usec)
	nop          		; 1 cycle (1 usec)
	nop           		; 1 cycle (1 usec)
	nop           		; 1 cycle (1 usec)
	nop           		; 1 cycle (1 usec)
	nop           		; 1 cycle (1 usec)
	brne wait_msec		; 1 or 2 cycles (1 or 2 usec)
    	ret             	; 4 cycles (4 usec)