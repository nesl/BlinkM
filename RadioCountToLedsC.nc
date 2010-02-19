// $Id: RadioCountToLedsC.nc,v 1.6 2008/06/24 05:32:31 regehr Exp $

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "RadioCountToLeds.h"
 
#define ALL_MOTES 255
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module RadioCountToLedsC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
    interface BlinkM;
  }
}
implementation {

  message_t packet;

  bool locked;
  uint16_t counter = 0;
  
  event void Boot.booted() 
  {
    call BlinkM.stop_script();
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
  
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) 
  {
    call Leds.led2Toggle();
    dbg("RadioCountToLedsC", "Received packet of length %hhu.\n", len);
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}
    else 
    {
        radio_count_msg_t* rcm = (radio_count_msg_t*)payload;
        if(rcm->mote == TOS_NODE_ID || rcm->mote == ALL_MOTES)
        {
            switch(rcm->comm)
            { 
                case 0:   //go to rgb color now
                    call BlinkM.set_rgb_color(rcm->red,rcm->green,rcm->blue);
                    break;
                case 1:   //fade to rgb color
                    call BlinkM.fade_to_rgb_color(rcm->red,rcm->green,rcm->blue);
                    break;
                case 2:   //fade to hsb color
                    call BlinkM.fade_to_hsb_color(rcm->red,rcm->green,rcm->blue);
                    break;
                case 3:   //stop playing the script
                    call BlinkM.stop_script();
                    break;
                case 4:   //set the fade speed
                    call BlinkM.set_fade_speed(rcm->red);
                    break;
              
            }
        }
        return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) 
  {
    if (&packet == bufPtr) 
    {
      locked = FALSE;
    }
  }

  event void BlinkM.fade_to_rgb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.set_rgb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.set_fade_speedDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.fade_to_hsb_colorDone(error_t error)
  {
      //do nothing
  }

  event void BlinkM.stop_scriptDone(error_t error)
  {
    call AMControl.start();
  }
  async event void BlinkM.get_rgb_colorDone(error_t error, uint8_t red, uint8_t green, uint8_t blue)
  {
      //do nothing
  }
}
