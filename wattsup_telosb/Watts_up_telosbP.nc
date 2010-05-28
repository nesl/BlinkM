// Watts up telosb implementation
/*
*/ 
/*
*/
#include "printf.h" 
#include "Watts_up_telosb.h"


module Watts_up_telosbP
{
    uses interface UartByte;
    uses interface UartStream;
    uses interface Resource; 
    uses interface Leds;
    uses interface AMSend;
    uses interface SplitControl as AMControl;
    uses interface Packet;
    provides interface Watts_up_telosb;
    provides interface Msp430UartConfigure;
}
implementation
{
    uint8_t state = 0;
    message_t pkt;
    bool locked;

    /*****************************************************
                            Functions  
    *****************************************************/

    /* Convert array of chars to an uint16_t */ 
    uint16_t convert_char_to_int(char* digits, uint8_t num_digits)
    {
        uint16_t converted_int = 0;
        uint16_t power = 1;
        for(; num_digits > 0; num_digits--)
        {
            converted_int += (digits[num_digits-1]-'0')*power;
            power *= 10;
        }
        return converted_int;
    }

    /* Changes the color of the BlinkM's based on the value of power */ 
    void change_color(uint16_t power)
    {
        uint8_t red, green, blue;
        uint16_t power_range = 11000;
        uint8_t num_colors = 7;
        uint16_t color_width = power_range/num_colors; 
        watts_up_msg_t *wupkt; 

        if(power < color_width)
        {
            red = 0xff;
            green = 0x00;
            blue = 0x00;
        }
        else if(power < 2*color_width && power >= color_width)
        {
            red = 0xff;
            green = 0xa5;
            blue = 0x00;
        }
        else if(power < 3*color_width && power >=
               2*color_width)
        {
            red = 0xff;
            green = 0xff;
            blue = 0x00;
        }   
        else if(power < 4*color_width && power >=
               3*color_width)
        {
            red = 0x00;
            green = 0x80;
            blue = 0x00;
        }
        else if(power < 5*color_width && power >=
               4*color_width)
        {
            red = 0x00;
            green = 0x00;
            blue = 0xff;
        }
        else if(power < 6*color_width && power >=
               5*color_width)
        {
            red = 0x4b;
            green = 0x00;
            blue = 0x82;
        }
        else
        {
            red = 0xee;
            green = 0x82;
            blue = 0xee;
        }
        wupkt = (watts_up_msg_t*)(call Packet.getPayload(&pkt,sizeof(watts_up_msg_t)));
        if(wupkt == NULL)
            return;
        
        wupkt->comm = 'n';
        wupkt->red = red;
        wupkt->green = green;
        wupkt->blue = blue;

        call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(watts_up_msg_t));
    
         
   
    }


    /*****************************************************
                            Commands  
    *****************************************************/

    /* Set proper Uart configuration variables */ 
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
        call Resource.request(); 
        return SUCCESS;
    }
    
    /*****************************************************
                            Tasks  
    *****************************************************/

    /* This task receives the watts up pro data and stores the integer values
     * in serial_int_values array */  
    task void receive_wup_data()
    {
        uint8_t iter, counter, param_counter;
        uint8_t  num_chars = 0; 
        uint8_t serial_in[255];
        uint16_t serial_int_values[255];                 
        char value[5];
        
        /* Read data from Watts up pro */ 
        do
        {
            if(num_chars > 255)
            {
                /* Check for buffer overload */ 
                printf("End Buffer\n");
                break;
            }
            while(call UartByte.receive(&serial_in[num_chars],10) == FAIL)
            {
            } 
            num_chars++;
        } while(serial_in[num_chars-1] != '\n') ;

        /* Convert all characters into integers */ 
        iter = 0;
        param_counter = 0;
        for(counter = 0; counter < num_chars; counter++)
        {
            if(serial_in[counter] != ',')
            {
                value[iter] = serial_in[counter];
                iter++;
            }
            else
            {
                serial_int_values[param_counter] = convert_char_to_int(value, iter);
                param_counter++;
                for(iter = 0; iter < 5; iter++)
                    value[iter] = 0;
                iter = 0;           
            }
        }
        for(counter = 0; counter < param_counter; counter++)
            printf("%d\n",serial_int_values[counter]);
        printf("Power: %d\n",serial_int_values[3]);
        printfflush();

        /* Change color based on power usage */ 
        change_color(serial_int_values[3]);

    } 

    /*****************************************************
                            Events  
    *****************************************************/
    async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error)
    {
        uint8_t get_input[8] = {'#','L','W',3,'E',1,1,';'};
        
        switch(state) 
        {
            case 0:
                /* state zero: Send second configuration */ 
                call UartStream.send(get_input,18);
                state = 1;
                break;
            case 1:
                /* state one: Receive data from Watts up Pro */ 
                post receive_wup_data();
                break;
        }
                
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
        /* Configure the Watts up Pro */ 
        uint8_t serial_out[23]= {'#','C','W',18,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,';'};
        call Leds.led0Toggle();
        if(call UartStream.send(serial_out,23) == FAIL)
        {
            printf("Failed send\n");
        }
        printfflush();
 
    } 

    event void AMControl.startDone(error_t err) 
    {
        if (err == SUCCESS) 
        {
            // call MilliTimer.startPeriodic(2000);
        }
        else 
        {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) 
    {
        // do nothing
    }

    event void AMSend.sendDone(message_t* bufPtr, error_t error) 
    {
        if (&pkt == bufPtr) 
        {
            locked = FALSE;
        }
    }

}
 
