/*
 */

/*
 */
#include "printf.h" /* Used to print out the data to the computer */ 


module Watts_up_telosbP
{
    uses interface UartByte;
    uses interface UartStream;
    uses interface Resource; 
    uses interface Leds;
    provides interface Watts_up_telosb;
    provides interface Msp430UartConfigure;
}
implementation
{
    uint8_t state = 0;

    /*****************************************************
                            Commands  
    *****************************************************/

    async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig()
    {
        msp430_uart_union_config_t msp430_uart_config = {
            {
                 utxe : 1,
                 urxe : 1,
                 ubr : UBR_1MHZ_115200,
                 umctl : UMCTL_1MHZ_115200,
                 ssel : 0x02,
                 pena : 0,
                 pev : 0,
                 spb : 0,
                 clen : 1,
                 listen : 0,
                 mm : 0,
                 ckpl : 0,
                 urxse : 0,
                 urxeie : 1,
                 urxwie : 0,
                 utxe : 1,
                 urxe : 1
            }
        };
        return &msp430_uart_config;

    }

    command error_t Watts_up_telosb.get_data()
    {
        
        
        printf("get\n");
        
        call Resource.request(); 
        return SUCCESS;
    }

    /*****************************************************
                            Events  
    *****************************************************/
    async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error)
    {
        uint8_t get_input[8] = {'#','L','W',3,'E',1,1,';'};
        uint8_t iter;
        uint8_t serial_in[255];
        uint8_t converted_int;

        switch(state) {
            case 0:
                printf("done cfg\n");
                call UartStream.send(get_input,18);
                state = 1;
                break;
            case 1:
                printf("done get\n");
                for(iter=0; iter<255; iter++)
                    serial_in[iter] = 'a';
                iter = 0;
                serial_in[iter] = 0;
                do{
                    if(iter > 255)
                    {
                        printf("End Buffer\n");
                        break;
                    }
                    while(call UartByte.receive(&serial_in[iter],10) == FAIL)
                    {
                    } 
                    if(serial_in[iter] == ',')
                    {
                        printf("\n");
                    } 
                    else 
                    {
                         
                        converted_int = serial_in[iter]-'0'; 
                        printf("%i", converted_int);
                        
                    //    printf("%c",serial_in[iter]);
                    }
                    iter++;
                    printfflush();
                } while(serial_in[iter-1] != '\n') ;
                printf("Done\n");
                break;
        }
        printfflush();

    }

    async event void UartStream.receivedByte(uint8_t byte)
    {
        /* do nothing */
    }

    async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error)
    {
        /* do nothing */
    }

    event void Resource.granted()
    {
        uint8_t iter;
        uint8_t serial_in[255];
        uint8_t serial_out[23]= {'#','C','W',18,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,';'};
        call Leds.led0Toggle();
        if(call UartStream.send(serial_out,23) == FAIL)
        {
            printf("Failed send\n");
        }
        printfflush();
 
    } 
 
}
 
