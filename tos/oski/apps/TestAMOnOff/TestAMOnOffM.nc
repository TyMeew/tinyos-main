// $Id: TestAMOnOffM.nc,v 1.1.2.1 2005-06-20 01:09:28 scipio Exp $

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

/**
 *  Implementation of the OSKI TestAMOnOff application. This
 *  application has two versions: slave and master. A master is always
 *  on, and transmits data packets at 1Hz. Every 5s, it transmits a power
 *  message. When a slave hears a data message, it toggles its red led;
 *  when it hears a power message, it turns off its radio, which it turns
 *  back on in a few seconds. This essentially tests whether the AMService
 *  is turning the radio off appropriately.
 *
 *  @author Philip Levis
 *  @date   June 19 2005
 *
 **/

includes Timer;

module TestAMOnOffM {
  uses {
    interface Leds;
    interface Boot;
    interface Receive as PowerReceive;
    interface AMSend as PowerSend;
    interface Receive as DataReceive;
    interface AMSend as DataSend;
    interface Timer<TMilli> as MilliTimer;
    interface Service;
    interface ServiceNotify;
    interface Service as SecondService;
  }
}
implementation {

  message_t packet;

  bool locked;
  uint8_t counter = 0;
  
  event void Boot.booted() {
    call Service.start();
    //call SecondService.start();
    call MilliTimer.startPeriodicNow(1000);
  }
  
  event void MilliTimer.fired() {
    counter++;
#ifdef SERVICE_SLAVE
    if ((counter % 7) == 0) {
      if (!call Service.isRunning()) {
        call Service.start();
      }
    }
#endif
#ifdef SERVICE_MASTER
    if (locked) {
      return;
    }
    if (counter % 5) {
      if (call DataSend.send(AM_BROADCAST_ADDR, &packet, 0) == SUCCESS) {
        call Leds.led0Toggle();
        locked = TRUE;
      }
    }
    else {
      if (call PowerSend.send(AM_BROADCAST_ADDR, &packet, 0) == SUCCESS) {
        call Leds.led1Toggle();
        locked = TRUE;
      }
    }
#endif
  }

  event message_t* DataReceive.receive(message_t* bufPtr, 
	   			       void* payload, uint8_t len) {
#ifdef SERVICE_SLAVE 
    call Leds.led0Toggle();
#endif
    return bufPtr;
  }

  event message_t* PowerReceive.receive(message_t* bufPtr, 
	   			        void* payload, uint8_t len) {
#ifdef SERVICE_SLAVE 
    if (call Service.isRunning()) {
      call Service.stop();
    }
#endif
    return bufPtr;
  }
  
  event void PowerSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void DataSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void ServiceNotify.started() {
#ifdef SERVICE_SLAVE
    call Leds.led1On();
#endif
  }

  event void ServiceNotify.stopped() {
#ifdef SERVICE_SLAVE
    call Leds.led1Off();
#endif
  }
}




