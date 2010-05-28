/*  Watts up Telosb Configuration
*/
/*
*/
#include "Watts_up_telosb.h"
#include "printf.h" 

configuration Watts_up_telosbC
{
    provides interface Watts_up_telosb;
}
implementation
{
    components Watts_up_telosbP, LedsC, new Msp430Uart0C();
    components new AMSenderC(WATTS_UP_MSG);
    components ActiveMessageC;
    
    Watts_up_telosb = Watts_up_telosbP;

    Watts_up_telosbP.Leds -> LedsC;

    /* Uart for telosb to Watts up Pro communication */ 
    Watts_up_telosbP.UartByte -> Msp430Uart0C.UartByte;
    Watts_up_telosbP.UartStream -> Msp430Uart0C.UartStream;

    /* Serial for telosb to micaz communication */ 
    Watts_up_telosbP.AMSend -> AMSenderC;
    Watts_up_telosbP.AMControl -> ActiveMessageC;
    Watts_up_telosbP.Packet -> AMSenderC;

    Watts_up_telosbP.Resource -> Msp430Uart0C.Resource;
}
