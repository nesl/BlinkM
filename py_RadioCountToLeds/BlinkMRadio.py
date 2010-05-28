#!/usr/bin/env "python -W ignore::DeprecationWarning"

import sys
import time
import signal
import serial

# import msg from parent directory
sys.path.append("..")

#tos stuff
import RadioCountMsg
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

class BlinkMRadio:

    def __init__(self, motestring):

        ### start tos mote interface
#        self.mif = MoteIF.MoteIF()
#        self.tos_source = self.mif.addSource(motestring)
#        self.mif.addListener(self, RadioCountMsg.RadioCountMsg)
#        power_range = 11000
#        num_colors = 7
#        color_width= power_range/num_colors
#        print "color_width: ",color_width
        ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=1)
        ser.write('#C,W,18,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1;')
        ser.write('#L,W,3,E,1,1;')

        while 1:

            data = ser.readline()
            data = data.strip().split(',')
            data = data[3:6]
            if len(data) == 3:
                power = int(data[0])
                print data[0]
                try:
                    if(power < color_width):
                        red = 0xff
                        green = 0x00
                        blue = 0x00
                    elif(power < 2*color_width and power >= color_width):
                        red = 0xff
                        green = 0xa5
                        blue = 0x00
                    elif(power < 3*color_width and power >=
                            2*color_width):
                        red = 0xff
                        green = 0xff
                        blue = 0x00
                    elif(power < 4*color_width and power >=
                            3*color_width):
                        red = 0x00
                        green = 0x80
                        blue = 0x00
                    elif(power < 5*color_width and power >=
                            4*color_width):
                        red = 0x00
                        green = 0x00
                        blue = 0xff
                    elif(power < 6*color_width and power >=
                            5*color_width):
                        red = 0x4b
                        green = 0x00
                        blue = 0x82
                    else:
                        red = 0xee
                        green = 0x82
                        blue = 0xee

                    self.set_output(1,red,green,blue,255)
                except:
                    pass

    def set_output(self,comm,red,green,blue,mote):
        bmsg = RadioCountMsg.RadioCountMsg()
        bmsg.set_counter(100)
        bmsg.set_comm(1);
        bmsg.set_red(red)
        bmsg.set_green(green)
        bmsg.set_blue(blue)
        bmsg.set_mote(255);
        self.mif.sendMsg(self.tos_source, 0xFFFF, bmsg.get_amType(), 4001, bmsg)



    def receive(self, src, msg):
        """ This is the registered listener function for TinyOS messages.
        """
        print msg.getAddr(), msg


    def main_loop(self):
        # wait for everything to start up
        while 1:
            time.sleep(1)

def main():

    if '-h' in sys.argv:
        print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:telosb"
        sys.exit()

    cf = BlinkMRadio(sys.argv[1])
    cf.main_loop()  # don't expect this to return...


if __name__ == "__main__":
    main()
