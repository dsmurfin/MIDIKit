//
//  Continue.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event {
    /// System Real Time: Continue
    /// (MIDI 1.0 / 2.0)
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "Continue (`0xFB`) is sent when a CONTINUE button is hit. A sequence will continue from its current location upon receipt of the next Timing Clock (`0xF8`)."
    public struct Continue: Equatable, Hashable {
        /// UMP Group (0x0...0xF)
        public var group: MIDI.UInt4 = 0x0
        
        public init(group: MIDI.UInt4 = 0x0) {
            self.group = group
        }
    }
    
    /// System Real Time: Continue
    /// (MIDI 1.0 / 2.0)
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "Continue (`0xFB`) is sent when a CONTINUE button is hit. A sequence will continue from its current location upon receipt of the next Timing Clock (`0xF8`)."
    ///
    /// - Parameters:
    ///   - group: UMP Group (0x0...0xF)
    @inline(__always)
    public static func `continue`(group: MIDI.UInt4 = 0x0) -> Self {
        .continue(
            .init(group: group)
        )
    }
}

extension MIDI.Event.Continue {
    /// Returns the raw MIDI 1.0 message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage of MIDIKit, but is provided publicly for introspection and debugging purposes.
    @inline(__always)
    public func midi1RawBytes() -> [MIDI.Byte] {
        [0xFB]
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
            0xFB,
            0x00, // pad empty bytes to fill 4 bytes
            0x00
        ) // pad empty bytes to fill 4 bytes
        
        return [word]
    }
}
