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

/*
 * 
 */
char x=0;

int main() 
{
    unsigned char duty;
    
    TCCR1A=(1<<WGM10)|(1<<COM1A1);
    TCCR1B=(1<<WGM12)|(1<<CS11);
    
    DDRB=0b00111111;
    
}

