#!/usr/bin/env "python -W ignore::DeprecationWarning"

"""
parameters:
    - the first parameter to this application is a MOTECOM string.
"""

import sys
import time
import signal

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
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, RadioCountMsg.RadioCountMsg)

<<<<<<< HEAD:py_RadioCountToLeds/BlinkMRadio.py
        toggle = 0

        while 1:

            time.sleep(2)
            if toggle == 0:
                red = 255
                green = 255
                blue = 255
                toggle = 1
            else:
                red = 0
                green = 255
                blue = 0
                toggle = 0
            self.set_output(1,red,green,blue,255)

    def set_output(self,comm,red,green,blue,mote):
        bmsg = RadioCountMsg.RadioCountMsg()
        bmsg.set_counter(100)
        bmsg.set_comm(1);
        bmsg.set_red(red)
        bmsg.set_green(green)
        bmsg.set_blue(blue)
        bmsg.set_mote(255);
        self.mif.sendMsg(self.tos_source, 0xFFFF, bmsg.get_amType(), 4001, bmsg)



=======
        time.sleep(1)

        bmsg = RadioCountMsg.RadioCountMsg()
        bmsg.set_red(255)
        bmsg.set_green(0)
        bmsg.set_blue(0)
        bmsg.set_counter(100)
        self.mif.sendMsg(self.tos_source, 0xFFFF, bmsg.get_amType(), 4001, bmsg)

>>>>>>> 1f8274fd3bdbd5d139b444ec6095c497e40d2fe6:py_RadioCountToLeds/BlinkMRadio.py
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
