//
//  UnofficialBusSelect.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event {
    /// Unofficial Bus Select (Status `0xF5`)
    ///
    /// "Some vendors have produced boxes with a single MIDI input, and multiple MIDI outputs. The Bus Select message specifies which of the outputs further data should be sent to. This is not an official message; the vendors in question should have used a SysEx command." -- [David Van Brink's MIDI Spec](https://www.cs.cmu.edu/~music/cmsip/readings/davids-midi-spec.htm)
    ///
    /// - Note: May be removed in a future release of MIDIKit.
    public struct UnofficialBusSelect: Equatable, Hashable {
        /// Bus Number
        public var bus: MIDI.UInt7 = 0
        
        /// UMP Group (0x0...0xF)
        public var group: MIDI.UInt4 = 0x0
        
        public init(
            bus: MIDI.UInt7 = 0,
            group: MIDI.UInt4 = 0x0
        ) {
            self.bus = bus
            self.group = group
        }
    }
    
    /// Unofficial Bus Select (Status `0xF5`)
    ///
    /// "Some vendors have produced boxes with a single MIDI input, and multiple MIDI outputs. The Bus Select message specifies which of the outputs further data should be sent to. This is not an official message; the vendors in question should have used a SysEx command." -- [David Van Brink's MIDI Spec](https://www.cs.cmu.edu/~music/cmsip/readings/davids-midi-spec.htm)
    ///
    /// - Parameters:
    ///   - bus: Bus Number (0x00...0x7F)
    ///   - group: UMP Group (0x0...0xF)
    @inline(__always)
    public static func unofficialBusSelect(
        bus: MIDI.UInt7,
        group: MIDI.UInt4 = 0x0
    ) -> Self {
        .unofficialBusSelect(
            .init(
                bus: bus,
                group: group
            )
        )
    }
}

extension MIDI.Event.UnofficialBusSelect {
    /// Returns the raw MIDI 1.0 message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage of MIDIKit, but is provided publicly for introspection and debugging purposes.
    @inline(__always)
    public func midi1RawBytes() -> [MIDI.Byte] {
        [0xF5, bus.uInt8Value]
    }
    
    /// Returns the raw MIDI 2.0 UMP (Universal MIDI Packet) message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage of MIDIKit, but is provided publicly for introspection and debugging purposes.
    @inline(__always)
    public func umpRawWords() -> [MIDI.UMPWord] {
        let umpMessageType: MIDI.IO.Packet.UniversalPacketData
            .MessageType = .systemRealTimeAndCommon
        
        let mtAndGroup = (umpMessageType.rawValue.uInt8Value << 4) + group
        
        let word = MIDI.UMPWord(
            mtAndGroup,
            0xF5,
            bus.uInt8Value,
            0x00
        ) // pad empty bytes to fill 4 bytes
        
        return [word]
    }
}
