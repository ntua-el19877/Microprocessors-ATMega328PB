/* 
 * File:   main2_3.c
 * Author: Aggelos
 *
 * Created on November 1, 2022, 4:52 AM
 */
#define F_CPU 16000000UL
#include <stdio.h>
#include <stdlib.h>
#include<avr/interrupt.h>
#include<util/delay.h>

/*
 * 
 */
char x=0;


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
    sei();
    if((x>>1)&1)            //check for second INT
    {
        PORTB=0xFF;
        _delay_ms(50);
        PORTB=0x01;
        _delay_ms(350);
        x=0;
        x=EIFR;
        if(!(x>>1)&1)       //if no extra INT switch off
        {
            PORTB=0x00;
        }
    }
    else
    {
        PORTB=0x01;
        _delay_ms(400);
        x=0;
        x=EIFR;
        if(!(x>>1)&1)       //if no extra INT switch off
        {
            PORTB=0x00;
        }
    }
    
}

int main() 
{
    
    EICRA=(1<<ISC10)|(1<<ISC11);
    EIMSK=(1<<INT1);
    sei();                              //enable global INT
    
    DDRB=0xFF;                          //PORTB output
    
    while(1)
    {
        PORTB=0x00;
    }
    
}

