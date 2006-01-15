/// $Id: Atm128AlarmC.nc,v 1.1.2.4 2006-01-15 23:44:54 scipio Exp $

/**
 * Copyright (c) 2004-2005 Crossbow Technology, Inc.  All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL CROSSBOW TECHNOLOGY OR ANY OF ITS LICENSORS BE LIABLE TO 
 * ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL 
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
 * IF CROSSBOW OR ITS LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
 * DAMAGE. 
 *
 * CROSSBOW TECHNOLOGY AND ITS LICENSORS SPECIFICALLY DISCLAIM ALL WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS 
 * ON AN "AS IS" BASIS, AND NEITHER CROSSBOW NOR ANY LICENSOR HAS ANY 
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR 
 * MODIFICATIONS.
 */

/// @author Martin Turon <mturon@xbow.com>

generic module Atm128AlarmC(typedef frequency_tag, 
			    typedef timer_size @integer(),
			    uint8_t prescaler,
			    int mindt)
{
  provides interface Init @atleastonce();
  provides interface Alarm<frequency_tag, timer_size> as Alarm @atmostonce();

  uses interface HplAtm128Timer<timer_size>;
  uses interface HplAtm128Compare<timer_size>;
}
implementation
{
  command error_t Init.init() {
    atomic {
      call HplAtm128Compare.stop();
      call HplAtm128Timer.set(0);
      call HplAtm128Timer.start();
      call HplAtm128Timer.setScale(prescaler);
    }
    return SUCCESS;
  }
  
  async command timer_size Alarm.getNow() {
    return call HplAtm128Timer.get();
  }

  async command timer_size Alarm.getAlarm() {
    return call HplAtm128Compare.get();
  }

  async command bool Alarm.isRunning() {
    return call HplAtm128Compare.isOn();
  }

  async command void Alarm.stop() {
    call HplAtm128Compare.stop();
  }

  async command void Alarm.start( timer_size dt ) 
  {
    call Alarm.startAt( call HplAtm128Timer.get(), dt);
  }

  async command void Alarm.startAt( timer_size t0, timer_size dt ) {
    timer_size now;
    timer_size expires, guardedExpires;

    now = call HplAtm128Timer.get();
    dbg("Atm128AlarmC", "   starting timer at %llu with dt %llu\n", (uint64_t)t0, (uint64_t) dt);
    /* We require dt >= mindt to avoid setting an interrupt which is in
       the past by the time we actually set it. mindt should always be
       at least 2, because you cannot set an interrupt one cycle in the
       future. It should be more than 2 if the timer's clock rate is
       very high (e.g., equal to the processor clock). */
    if (dt < mindt)
      dt = mindt;

    expires = t0 + dt;

    guardedExpires = expires - mindt;

    /* t0 is assumed to be in the past. If it's numerically greater than
       now, that just represents a time one wrap-around ago. This requires
       handling the t0 <= now and t0 > now cases separately. 

       Note also that casting compared quantities to timer_size produces
       predictable comparisons (the C integer promotion rules would make it
       hard to write correct code for the possible timer_size size's) */
    if (t0 <= now)
      {
	/* if it's in the past or the near future, fire now (i.e., test
	   guardedExpires <= now in wrap-around arithmetic). */
	if (guardedExpires >= t0 && // if it wraps, it's > now
	    guardedExpires <= now) 
	  call HplAtm128Compare.set(call HplAtm128Timer.get() + mindt);
	else
	  call HplAtm128Compare.set(expires);
      }
    else
      {
	/* again, guardedExpires <= now in wrap-around arithmetic */
	if (guardedExpires >= t0 || // didn't wrap so < now
	    guardedExpires <= now)
	  call HplAtm128Compare.set(call HplAtm128Timer.get() + mindt);
	else
	  call HplAtm128Compare.set(expires);
      }
    call HplAtm128Compare.reset();
    call HplAtm128Compare.start();
  }

  async event void HplAtm128Compare.fired() {
    call HplAtm128Compare.stop();
    dbg("Atm128AlarmC", " Compare fired, signal alarm above.\n");
    signal Alarm.fired();
  }

  async event void HplAtm128Timer.overflow() {
  }
}
