//
//  Event Filter Channel Voice Tests.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

#if shouldTestCurrentPlatform

import XCTest
import MIDIKit

final class MIDIEventFilter_ChannelVoice_Tests: XCTestCase {
    func testMetadata() {
        // isChannelVoice
        
        let events = kEvents.ChanVoice.oneOfEachEventType
        
        events.forEach {
            XCTAssertTrue($0.isChannelVoice)
            XCTAssertFalse($0.isSystemCommon)
            XCTAssertFalse($0.isSystemExclusive)
            XCTAssertFalse($0.isSystemRealTime)
            XCTAssertFalse($0.isUtility)
        }
        
        // isChannelVoice(ofType:)
        
        XCTAssertTrue(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofType: .noteOn)
        )
        
        XCTAssertFalse(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofType: .noteOff)
        )
        
        // isChannelVoice(ofTypes:)
        
        XCTAssertTrue(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofTypes: [.noteOn])
        )
        
        XCTAssertTrue(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofTypes: [.noteOn, .noteOff])
        )
        
        XCTAssertFalse(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofTypes: [.noteOff, .cc])
        )
        
        XCTAssertFalse(
            MIDI.Event.noteOn(1, velocity: .unitInterval(1.0), channel: 1, group: 0)
                .isChannelVoice(ofTypes: [])
        )
    }
    
    // MARK: - Convenience Static Constructors
    
    func testOnlyCC_ControllerNumber() {
        let events = [
            kEvents.ChanVoice.cc,
            kEvents.ChanVoice.noteOn
        ]
        
        XCTAssertEqual(
            events.filter(chanVoice: .onlyCC(2)),
            []
        )
        XCTAssertEqual(
            events.filter(chanVoice: .onlyCC(11)),
            [kEvents.ChanVoice.cc]
        )
        
        XCTAssertEqual(
            events.filter(chanVoice: .onlyCCs([2])),
            []
        )
        XCTAssertEqual(
            events.filter(chanVoice: .onlyCCs([11])),
            [kEvents.ChanVoice.cc]
        )
        
        XCTAssertEqual(
            events.filter(chanVoice: .keepCC(2)),
            [kEvents.ChanVoice.noteOn]
        )
        XCTAssertEqual(
            events.filter(chanVoice: .keepCC(11)),
            [
                kEvents.ChanVoice.cc,
                kEvents.ChanVoice.noteOn
            ]
        )
        
        XCTAssertEqual(
            events.filter(chanVoice: .keepCCs([2])),
            [kEvents.ChanVoice.noteOn]
        )
        XCTAssertEqual(
            events.filter(chanVoice: .keepCCs([11])),
            [
                kEvents.ChanVoice.cc,
                kEvents.ChanVoice.noteOn
            ]
        )
        
        XCTAssertEqual(
            events.filter(chanVoice: .dropCC(2)),
            [
                kEvents.ChanVoice.cc,
                kEvents.ChanVoice.noteOn
            ]
        )
        XCTAssertEqual(
            events.filter(chanVoice: .dropCC(11)),
            [kEvents.ChanVoice.noteOn]
        )
        
        XCTAssertEqual(
            events.filter(chanVoice: .dropCCs([2])),
            [
                kEvents.ChanVoice.cc,
                kEvents.ChanVoice.noteOn
            ]
        )
        XCTAssertEqual(
            events.filter(chanVoice: .dropCCs([11])),
            [kEvents.ChanVoice.noteOn]
        )
    }
}

#endif
