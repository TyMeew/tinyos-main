/*									tab:4
 * "Copyright (c) 2005 Stanford University. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose, without fee, and without written
 * agreement is hereby granted, provided that the above copyright
 * notice, the following two paragraphs and the author appear in all
 * copies of this software.
 * 
 * IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
 * IF STANFORD UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 * 
 * STANFORD UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE
 * PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND STANFORD UNIVERSITY
 * HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
 * ENHANCEMENTS, OR MODIFICATIONS."
 *
 * "Copyright (c) 2000-2003 The Regents of the University  of California.  
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
 * A platform independent abstraction of an asynchronous 32KHz, 16-bit
 * timer for the CC2420. As these timers (the Alarm interface) are
 * usually part of an HAL, they are platform specific. But as the
 * CC2420 needs to be cross-platform, this component bridges between
 * the two, providing a platform-independent abstraction of
 * CC2420-specific Alarm. This is a Atmega128 implementation that
 * uses the Compare1A register.
 *
 * @author Philip Levis
 * @date   August 31 2005
 */

includes Atm128Timer;

generic configuration HplCC2420AlarmC() {
  provides interface Init;
  provides interface Alarm<T32khz, uint32_t>;
}

implementation {
  components new Atm128AlarmC(T32khz, uint16_t, ATM128_CLK16_DIVIDE_256, 2);
  components new Atm128CounterC(T32khz, uint16_t);
  components new TransformAlarmC(T32khz,uint32_t,T32khz,uint16_t,0) as TransformAlarm32;
  components new TransformCounterC(T32khz,uint32_t,T32khz,uint16_t,0,uint32_t) as TransformCounter32;
  components HplAtm128Timer1C as Timer1C;

  Init = Atm128AlarmC;
  Alarm = TransformAlarm32;//Atm128AlarmC;
  TransformAlarm32.AlarmFrom -> Atm128AlarmC;
  TransformAlarm32.Counter -> TransformCounter32;
  TransformCounter32.CounterFrom -> Atm128CounterC;
  Atm128CounterC.Timer -> Timer1C.Timer1;
  Atm128AlarmC.HplAtm128Timer -> Timer1C.Timer1;
  Atm128AlarmC.HplAtm128Compare -> Timer1C.Compare1A;
}
