module BlinkMP
{
    uses interface Leds;
    uses interface I2CPacket<TI2CBasicAddr>; 
    uses interface Resource as I2CResource;
    provides interface BlinkM;
}
implementation
{

    /*****************************************************
                            Constants  
    *****************************************************/
    
    /* Default Blink Address */ 
    uint16_t BlinkM_Addr = 0x09;

    /* Specifies the state (currently in which function)  
    * state     command
    * 0         set_rgb_color 
    * 1         fade_to_rgb_color    
    * 2         fade_to_hsb_color
    * 3         Reserved
    * 4         Reserved 
    * 5         get_rgb_color
    * 6         set_fade_speed
    * 7         stop_script
    * 255       idle state */
    uint8_t state = 255;

    /* data pointers */ 
    uint8_t one_bit_data[1];
    uint8_t two_bit_data[2];
    uint8_t three_bit_data[3];
    uint8_t four_bit_data[4];

    /*****************************************************
                            Functions  
    *****************************************************/

    void change_color(uint8_t com, uint8_t red, uint8_t green, uint8_t blue)
    {
        four_bit_data[0] = com;
        four_bit_data[1] = red;
        four_bit_data[2] = green;
        four_bit_data[3] = blue;
    }

    error_t check_state()
    {
        uint8_t dup_state;
        atomic
        {
            dup_state = state;
        }
        if(dup_state != 255)
            return FAIL;
        return SUCCESS;
    }
    

    /*****************************************************
                            Commands  
    *****************************************************/

    /* This command sets the BlinkM to an RGB color immediately */ 
    command error_t BlinkM.set_rgb_color(uint8_t red, uint8_t green, uint8_t blue)
    {
        if(check_state() == FAIL)
           return FAIL; 
        atomic
        {
            state = 0; 
        }
        
        change_color('n', red, green, blue);
        call I2CResource.request();
        return SUCCESS;
    }
    
    /* This command returns the current RGB color */ 
    command error_t BlinkM.get_rgb_color()
    {
        if(check_state() == FAIL)
           return FAIL; 
        atomic
        {
            state = 5;
        }
        one_bit_data[0] = 'g';
        call I2CResource.request();
        return SUCCESS; 
    }

    /* This command tells BlinkM to fade from the current color to the RGB
     * color specified */ 
    command error_t BlinkM.fade_to_rgb_color(uint8_t red, uint8_t green, uint8_t blue)
    {
        if(check_state() == FAIL)
           return FAIL; 
        atomic
        {
            state = 1; 
        }
        
        change_color('c', red, green, blue);
        call I2CResource.request();
        return SUCCESS;
    }

    /* This command tells BlinkM to fade from the current color to the HSB
     * (Hue, Saturation, Brightness) color specified.*/ 
    command error_t BlinkM.fade_to_hsb_color(uint8_t hue, uint8_t sat, uint8_t bri)
    {
        if(check_state() == FAIL)
            return FAIL;
        atomic
        {
            state = 2; 
        }
        
        change_color('h', hue, sat, bri);
        call I2CResource.request();
        return SUCCESS;
    }

    /* This command sets how fast color fading happens */ 
    command error_t BlinkM.set_fade_speed(uint8_t speed)
    {
        if(check_state() == FAIL)
            return FAIL;
        atomic
        {
            state = 6;
        }

        two_bit_data[0] = 'f';
        two_bit_data[1] = speed;
        call I2CResource.request();
        return SUCCESS;
    }

    /* This command tells the BlinkM to stop playing a script
     * Note: The BlinkM comes playing a default script */ 
    command error_t BlinkM.stop_script()
    {
        if(check_state() == FAIL)
            return FAIL;
        atomic
        {
            state = 7;
        }

        one_bit_data[0] = 'o';
        call I2CResource.request();
        return SUCCESS; 

    }

    /*****************************************************
                            Tasks  
    *****************************************************/


    task void set_rgb_task()
    {
        signal BlinkM.set_rgb_colorDone(SUCCESS);
    }

    task void fade_to_rgb_task()
    {
        signal BlinkM.fade_to_rgb_colorDone(SUCCESS);
    }

    task void set_fade_speed_task()
    {   
        signal BlinkM.set_fade_speedDone(SUCCESS);
    }

    task void fade_to_hsb_task()
    {
        signal BlinkM.fade_to_hsb_colorDone(SUCCESS);
    }

    task void stop_script_task()
    {
        signal BlinkM.stop_scriptDone(SUCCESS);
    }

    /*****************************************************
                            Events  
    *****************************************************/


    async event void I2CPacket.readDone(error_t error, uint16_t add, uint8_t length, uint8_t* data)
    {

        uint8_t dup_state;
        atomic
        {
            dup_state = state;
        }
        if(dup_state == 5)
        {
            signal BlinkM.get_rgb_colorDone(SUCCESS,data[0],data[1],data[2]);
        }
        call I2CResource.release(); 
        atomic
        {
            state = 255;
        }
    }

    async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data)
    { 
        uint8_t dup_state;
        
        call Leds.led1On();
        atomic
        {
            dup_state = state;
        }
        switch(dup_state)
        {
            
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 6:
                call I2CResource.release();
                atomic
                {
                    state = 255;
                }
                switch(dup_state)
                {
                    case 0:
                        post set_rgb_task();
                        break;
                    case 1:
                        post fade_to_rgb_task();
                        break; 
                    case 2:
                        post fade_to_hsb_task();
                        break;
                    case 6:
                        post set_fade_speed_task();
                        break;
                }
                break;
            case 5:
                if(call I2CPacket.read(I2C_START|I2C_STOP, BlinkM_Addr,3,
                            three_bit_data) != SUCCESS)
                {
                    call I2CResource.release();
                    atomic
                    {
                        state = 255;
                    }
                    signal BlinkM.get_rgb_colorDone(FAIL,0x00,0x00,0x00);
                }
                break;
            case 7:
                call I2CResource.release();
                atomic
                {
                    state = 255;
                }
                post stop_script_task();
                break;
        }

    }

    event void I2CResource.granted()
    {
        uint8_t dup_state;
        atomic
        {
            dup_state = state;
        }
        switch(dup_state)
        {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
                if(call I2CPacket.write(I2C_START|I2C_STOP, BlinkM_Addr, 4
                            , four_bit_data) != SUCCESS)
                {
                    call I2CResource.release();

                    atomic
                    {
                        state = 255;
                    }
                    switch(dup_state)
                    {
                        case 0:
                            signal BlinkM.set_rgb_colorDone(FAIL);
                        case 1:
                            signal BlinkM.fade_to_rgb_colorDone(FAIL);
                        case 2: 
                            signal BlinkM.fade_to_hsb_colorDone(FAIL);
                    }
                }
                break;
            case 5: 
            case 7:
                if(call I2CPacket.write(I2C_START|I2C_STOP, BlinkM_Addr,1,
                            one_bit_data) != SUCCESS)
                {
                    call I2CResource.release();
                    atomic
                    {
                        state = 255;
                    }
                    if(dup_state == 5)
                        signal BlinkM.get_rgb_colorDone(FAIL,0x00,0x00,0x00);
                    else if(dup_state == 7)
                        signal BlinkM.stop_scriptDone(FAIL);
                }
                break;
            case 6:
                if(call I2CPacket.write(I2C_START|I2C_STOP, BlinkM_Addr,2,
                            two_bit_data) != SUCCESS)
                {
                    call I2CResource.release();
                    atomic
                    {
                        state = 255;
                    }
                    signal BlinkM.set_fade_speedDone(FAIL);
                }
                break;

        }
    }
}
