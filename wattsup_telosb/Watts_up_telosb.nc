interface Watts_up_telosb
{
    command error_t get_data();

    event void get_dataDone(error_t error, uint16_t data);
}
