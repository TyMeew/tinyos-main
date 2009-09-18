/*
 * Copyright (c) 2007, Vanderbilt University
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE VANDERBILT UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE VANDERBILT
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE VANDERBILT UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE VANDERBILT UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * Author: Miklos Maroti
 */

#include <RadioConfig.h>

#ifdef TFRAMES_ENABLED
#error "You cannot use Ieee154MessageC with TFRAMES_ENABLED defined"
#endif

configuration RF230Ieee154MessageC
{
	provides 
	{
		interface SplitControl;

		interface Ieee154Send;
		interface Receive as Ieee154Receive;
		interface SendNotifier;

		interface Ieee154Packet;
		interface Packet;
		interface Resource as RadioSendResource[uint8_t clint];

		interface PacketAcknowledgements;
		interface LowPowerListening;
		interface PacketLink;

		interface RadioChannel;

		interface PacketField<uint8_t> as PacketLinkQuality;
		interface PacketField<uint8_t> as PacketTransmitPower;
		interface PacketField<uint8_t> as PacketRSSI;

		interface LocalTime<TRadio> as LocalTimeRadio;
		interface PacketTimeStamp<TRadio, uint32_t> as PacketTimeStampRadio;
		interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
	}
}

implementation
{
	components RF230RadioC;

	SplitControl = RF230RadioC;

	Ieee154Send = RF230RadioC.Ieee154Send;
	Ieee154Receive = RF230RadioC.Ieee154Receive;
	SendNotifier = RF230RadioC.Ieee154Notifier;

	Packet = RF230RadioC.PacketForIeee154Message;
	Ieee154Packet = RF230RadioC;
	RadioSendResource = RF230RadioC;

	PacketAcknowledgements = RF230RadioC;
	LowPowerListening = RF230RadioC;
	PacketLink = RF230RadioC;

	RadioChannel = RF230RadioC;

	PacketLinkQuality = RF230RadioC.PacketLinkQuality;
	PacketTransmitPower = RF230RadioC.PacketTransmitPower;
	PacketRSSI = RF230RadioC.PacketRSSI;

	LocalTimeRadio = RF230RadioC;
	PacketTimeStampMilli = RF230RadioC;
	PacketTimeStampRadio = RF230RadioC;
}
