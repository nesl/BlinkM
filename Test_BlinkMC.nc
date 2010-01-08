module Test_BlinkMC @safe()
{
    uses interface BlinkM;
    uses interface Timer<TMilli> as Timer;
    uses interface Boot;
    uses interface Leds;
}
implementation
{
    uint32_t color;
    uint8_t state;
    

    event void Boot.booted()
    {
        color = 0;
        state = 0;
        call Timer.startPeriodic(2000);
        call BlinkM.set_fade_speed(10);
    }


    event void Timer.fired()
    {
        if(state == 0)
        {
            call BlinkM.fade_to_hsb_color(43,0xff,0xff);
            
        }
        else if(state == 1)
        {
            call BlinkM.fade_to_hsb_color(172,0xff,0xff);
        }
    }

    event void BlinkM.set_rgb_colorDone(error_t error)
    {
    }

    async event void BlinkM.get_rgb_colorDone(error_t error, uint8_t red, uint8_t green, uint8_t blue)
    {
    }

    event void BlinkM.fade_to_rgb_colorDone(error_t error)
    {
        if(state == 0)
            state = 1;
        else if(state == 1)
            state = 0;
    }

    event void BlinkM.set_fade_speedDone(error_t error)
    {
        call BlinkM.fade_to_hsb_color(172,0xff,0xff);
    }

    event void BlinkM.fade_to_hsb_colorDone(error_t error)
    {
        if(state == 0)
            state = 1;
        else if(state == 1)
            state = 0;

    }

}
