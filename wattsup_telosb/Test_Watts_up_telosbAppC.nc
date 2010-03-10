configuration Test_Watts_up_telosbAppC
{
}
implementation
{
    components Test_Watts_up_telosbC, Watts_up_telosbC, MainC;

    Test_Watts_up_telosbC.Watts_up_telosb -> Watts_up_telosbC; 
    Test_Watts_up_telosbC.Boot -> MainC;
}
