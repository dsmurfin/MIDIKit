//
//  MIDIIOReceiveHandlerProtocol.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

/// MIDI I/O Receive Handler Protocol.
///
/// For operating system backwards compatibility, both `MIDIReadBlock` (old Core MIDI API) and `MIDIReceiveBlock` (new Core MIDI API) must be handled.
public protocol MIDIIOReceiveHandlerProtocol {
    /// CoreMIDI `MIDIReadBlock`
    /// (deprecated after macOS 11 / iOS 14)
    @inline(__always)
    func packetListReceived(
        _ packets: [MIDI.IO.Packet.PacketData]
    )
    
    /// CoreMIDI `MIDIReceiveBlock`
    /// (introduced in macOS 11 / iOS 14)
    @available(macOS 11, iOS 14, macCatalyst 14, *)
    @inline(__always)
    func eventListReceived(
        _ packets: [MIDI.IO.Packet.UniversalPacketData],
        protocol midiProtocol: MIDI.IO.ProtocolVersion
    )
}
