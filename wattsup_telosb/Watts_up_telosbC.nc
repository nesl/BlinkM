#include "printf.h" /* Used to print out the data to the computer */ 

configuration Watts_up_telosbC
{
    provides interface Watts_up_telosb;
}
implementation
{
    components Watts_up_telosbP, LedsC, new Msp430Uart0C();

    
    Watts_up_telosb = Watts_up_telosbP;

    Watts_up_telosbP.Leds -> LedsC;
    Watts_up_telosbP.UartByte -> Msp430Uart0C.UartByte;
    Watts_up_telosbP.UartStream -> Msp430Uart0C.UartStream;

    Watts_up_telosbP.Resource -> Msp430Uart0C.Resource;
    Msp430Uart0C.Msp430UartConfigure -> Watts_up_telosbP.Msp430UartConfigure;
}
