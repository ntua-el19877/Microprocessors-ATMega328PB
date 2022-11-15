



.DEF A = r16 
.DEF B = r17 
.DEF C = r18
.DEF D = r19
.DEF F1 = r20
.DEF T = r21
.DEF F2 = r22

    ldi A,0x55
    ldi B,0x43
    ldi C,0x22
    ldi D,0x02
	
 main:		clr F1			; clear F
		clr F2

		mov T,B
		com A 			;A'
		com B			;B'
		mov F1,A		;A'
		and F1,B		;A'B'
		and B,D			;B'D
		or F1,B			;A'B'+B'D
		com F1			;(A'B'+B'D)'
		com A			;A
		mov B,T

		
		mov F2,A
		or F2,C			;A+C
		com D			;D'
		mov T,B
		or B,D			;B+D'
		com D
		and F2,B		;(A+C)(B+D')
		mov B,T

		inc A
		inc A
		inc B
		inc B
		inc B
		inc C
		inc C
		inc C
		inc C
		inc D 
		inc D
		inc D
		inc D
		inc D
	jmp main
		