module Test_Watts_up_telosbC
{
    uses interface Watts_up_telosb;
    uses interface Boot;
}
implementation
{
    event void Boot.booted()
    {
        call Watts_up_telosb.get_data();
    }

    event void Watts_up_telosb.get_dataDone(error_t error, uint16_t data)
    {
        /* do nothing */ 
        call Watts_up_telosb.get_data();
    }
}
