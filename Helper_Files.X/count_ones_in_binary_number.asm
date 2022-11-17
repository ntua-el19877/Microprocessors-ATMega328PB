;counts how many ones are in one binary number (input r26,output r26)   
count_ones:
    push r23
    push r22
    
    ldi r22,8		    ;8 logical shifts
    ldi r23,0		    ;number of ones
checkagain:
    rol r26
    brsh notzero		    ;if carry not zero goto
    inc r23		    ;found 1
notzero:
    dec r22
    cpi r22,0
    brne checkagain
    
    mov r26,r23
    pop r22
    pop r23
    ret


