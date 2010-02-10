
interface BlinkM
{
    /* This command sets the BlinkM to an RGB color immediately */ 
    command error_t set_rgb_color(uint8_t red, uint8_t green, uint8_t blue);

    event void set_rgb_colorDone(error_t error);

    /* This command returns the current RGB color */ 
    command error_t get_rgb_color();

    async event void get_rgb_colorDone(error_t error, uint8_t red, 
            uint8_t green, uint8_t blue);

   /* This command tells BlinkM to fade from the current color to the RGB
    * color specified */ 
    command error_t fade_to_rgb_color(uint8_t red, uint8_t green, uint8_t blue);

   event void fade_to_rgb_colorDone(error_t error); 

   /* This command sets how fast color fading happens. */ 
    command error_t set_fade_speed(uint8_t speed);

    event void set_fade_speedDone(error_t error);

    /* This command tells BlinkM to fade from the current color to the HSB
     * (Hue, Saturation, Brightness) color specified. */ 
    command error_t fade_to_hsb_color(uint8_t hue, uint8_t sat, 
            uint8_t bri);

    event void fade_to_hsb_colorDone(error_t error);

    /* This command tells BlinkM to stop playing a script */ 
    command error_t stop_script();

    event void stop_scriptDone(error_t error);
}
