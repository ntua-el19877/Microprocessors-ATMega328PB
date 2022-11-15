/* 
 * File:   main3_1.c
 * Author: Aggelos
 *
 * Created on November 10, 2022, 4:52 AM
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
        _delay_ms(100);
    }
    while(EIFR!=0);
    if (TCCR1B==0)
            {
                PORTB=0b00000001;
                //leds are off
                TCCR1B=(1<<CS12)|(1<<CS10);
                TCNT1=3036;
            }
            else
            {
                PORTB=0b00111111;
                //leds are on
                _delay_ms(500);
                PORTB=0b00000001;
                TCCR1B=(1<<CS12)|(1<<CS10);
                TCNT1=10848;
            }
}

ISR(TIMER1_OVF_vect)
{
    PORTB=0b00000000;
    TCCR1B=(0<<CS12)|(0<<CS10);
}

int main() 
{
    sei();
    TIMSK1=(1<<TOIE1);
    DDRB=0b00111111;                /* PORTB is output */
    EIMSK=(1<<INT1);                //allow external interrupts
    EICRA=(1<<ISC11)|(1<<ISC10);    // INT in rising edge
    
    while(1)
    {
        if((PINC&(1<<PINC5))==(0<<PINC5))       //if PINC5==1
        {
            if (TCCR1B==0)
            {
                PORTB=0b00000001;
                //leds are off
                while((PINC&(1<<PINC5))==(0<<PINC5)) 
                {
                    _delay_ms(5);
                }
                TCCR1B=(1<<CS12)|(1<<CS10);
                TCNT1=3036;
            }
            else
            {
                PORTB=0b00111111;
                //leds are on
                while((PINC&(1<<PINC5))==(0<<PINC5)) 
                {
                    _delay_ms(5);
                }
                _delay_ms(500);
                PORTB=0b00000001;
                TCCR1B=(1<<CS12)|(1<<CS10);
                TCNT1=10848;
            }
        }
    }
}


