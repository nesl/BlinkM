configuration Test_BlinkMAppC
{
}
implementation
{
    components new TimerMilliC() as Timer;
    components Test_BlinkMC, BlinkMC, MainC,LedsC;    

    Test_BlinkMC.Leds -> LedsC;

    Test_BlinkMC.Boot -> MainC;

    Test_BlinkMC.BlinkM -> BlinkMC;

    Test_BlinkMC.Timer -> Timer;
}
