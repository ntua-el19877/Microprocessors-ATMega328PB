;takes a number N in r26 and returns a number with N ones in r26
new_num_of_ones:
    push r23
    ldi r23 ,0
    
checkagain1:
    cpi r26,0
    breq end1		    ;if no more ones end it
    dec r26
    rol r23
    inc	r23
    rcall checkagain1
end1:
    mov r26,r23
    
    pop r23
    ret


