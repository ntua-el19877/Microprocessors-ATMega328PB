/* 
 * File:   INT1_Debouncing.c
 * Author: Aggelos
 *
 * Created on November 17, 2022, 7:41 PM
 */

#define F_CPU 16000000UL
#include <stdio.h>
#include <stdlib.h>
#include<avr/interrupt.h>
#include<util/delay.h>

/*
 * 
 */


ISR(INT1_vect)
{
    sei();
    //check for debouncing
    do
    {
        EIFR=0;
        _delay_ms(5);
    }
    while(EIFR!=0);
    
    //code
    
}

int main() 
{
    //INT init
    EICRA=(1<<ISC10)|(1<<ISC11);
    EIMSK=(1<<INT1);
    sei();                              //enable global INT
    
    
}

