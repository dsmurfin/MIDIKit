//
//  MIDIIO Constants.swift
//  MIDIKit
//
//  Created by Steffan Andrews on 2021-02-21.
//

import CoreMIDI

extension MIDIIO {
	
	/// Size of `MIDIPacketList` struct memory.
	@inline(__always) @usableFromInline
	internal static let sizeOfMIDIPacketList = MemoryLayout<MIDIPacketList>.size
	
	/// Size of `MIDIPacket` struct memory.
	@inline(__always) @usableFromInline
	internal static let sizeOfMIDIPacket = MemoryLayout<MIDIPacket>.size
	
	/// Size of `MIDIPacketList` header.
	///
	/// The `MIDIPacketList` struct consists of two fields, numPackets(`UInt32`) and packet (an Array of 1 instance of `MIDIPacket`).
	///
	/// The packet is supposed to be a "An open-ended array of variable-length MIDIPackets." but for convenience it is instantiated with one instance of a `MIDIPacket`.
	///
	/// To determine the size of the header portion of this struct, we can get the size of a UInt32, or subtract the size of a single packet from the size of a packet list. We will opt for the latter.
	@inline(__always) @usableFromInline
	internal static let sizeOfMIDIPacketListHeader = sizeOfMIDIPacketList - sizeOfMIDIPacket
	
	/// Size of `MIDIPacket` header.
	///
	/// The `MIDIPacket` struct consists of a timestamp (`MIDITimeStamp`), a length (`UInt16`) and data (an Array of 256 instances of `Byte`).
	///
	/// The data field is supposed to be a "A variable-length stream of MIDI messages." but for convenience it is instantiated as 256 bytes.
	///
	/// To determine the size of the header portion of this struct, we can add the size of the `timestamp` and `length` fields, or subtract the size of the 256 `Byte`s from the size of the whole packet. We will opt for the former.
	@inline(__always) @usableFromInline
	internal static let sizeOfMIDIPacketHeader = MemoryLayout<MIDITimeStamp>.size + MemoryLayout<UInt16>.size
	
	/// Size of both `MIDIPacketList` header and `MIDIPacket` header
	@inline(__always) @usableFromInline
	internal static let sizeOfMIDICombinedHeaders = sizeOfMIDIPacketListHeader + sizeOfMIDIPacketHeader
	
}
