/* 
 * File:   main3_2.c
 * Author: Aggelos
 *
 * Created on November 8, 2022, 4:52 AM
 */
#define F_CPU 16000000UL
#include <stdio.h>
#include <stdlib.h>
#include<avr/interrupt.h>
#include<util/delay.h>

ISR(TIMER1_OVF_vect)
{
    
}

int main() 
{
    unsigned char duty;
    
    TCCR1A=(1<<WGM10)|(1<<COM1A1);
    TCCR1B=(1<<WGM12)|(1<<CS11);
    
    DDRB|=0b00111111;               //portb for output
    DDRD = 0;                       //portd for input
    
    OCR1AH=0;
    OCR1AL=0b11111111;              //duty cicle 50%
    
    int maxDC=245;                        // 512*98/100 -255 -1 = 245.76
    int minDC=9;                          //512*2/100 -1 = 9.24
    
    while(1)
    {
        if(PIND1)
        {
            //check if under 50% or over
            //if over => inc ORC1AH
            //else => inc OCR1AL and OCR1AH if necessary
            if(OCR1AL==0b11111111)
            {
                if(OCR1AH<=maxDC)           //stop if over 98% DC
                {
                    OCR1AH+=4;             // 512*8/100=4.096 
                }
            }
            else
            {
                int x=255-OCR1AL;
                if(x>4)
                {
                    OCR1AL+=4;
                }
                else
                {
                    x=x-(255-OCR1AL);
                    OCR1AL=0b11111111;
                    OCR1AH=x;
                }
            }
            while(PIND1) _delay_ms(5); //check for debouncing while waiting to release PIND1
            
        } 
        else if(PIND2)
        {
            //check if under 50% or over
            //if under => dec ORC1AL
            //else => dec OCR1AH and OCR1AL if necessary
            if(OCR1AH==0b00000000)
            {
                if(OCR1AL>=minDC)           //stop if under 2% DC
                {
                    OCR1AH-=4;             // 512*8/100=4.096 
                }
            }
            else
            {
                int x=OCR1AH;
                if(x>4)
                {
                    OCR1AH-=4;
                }
                else
                {
                    x=4-x;
                    OCR1AL=0b11111111-x;
                    OCR1AH=0;
                }
            }
            while(PIND2) _delay_ms(5);   //check for debouncing while waiting to release PIND2
            
        }
    }
}

            
