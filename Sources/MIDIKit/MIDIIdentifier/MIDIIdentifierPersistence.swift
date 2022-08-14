//
//  MIDIIdentifierPersistence.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// Defines persistence behavior of a MIDI unique ID in the system.
public enum MIDIIdentifierPersistence {
    /// The unique ID will be randomly generated every time it is created in the system.
    ///
    /// This is generally not recommended and is provided mainly for testing purposes.
    case none
        
    /// Provide a preferred MIDI endpoint unique ID value, without attaching any persistent storage mechanism.
    ///
    /// In the event a collision with an existing unique ID in the system, a new random ID will be generated until there are no collisions.
    case unmanaged(MIDIIdentifier)
        
    /// The MIDI endpoint's unique ID is managed automatically and persistently stored in `UserDefaults`. The `standard` suite is used by default unless specified.
    ///
    /// If a unique ID does not yet exist for this object, one will be generated randomly.
    ///
    /// In the event a collision with an existing MIDI endpoint unique ID in the system, a new random ID will be generated until there are no collisions.
    /// The ID will then be cached in `UserDefaults` using the key string provided - if the key exists, it will be overwritten.
    case managed(
        userDefaultsKey: String,
        suite: UserDefaults = .standard
    )
        
    /// Supply handlers to facilitate persistently reading and storing the MIDI endpoint's unique ID.
    ///
    /// This is useful if you need more control over where you want to persist this information.
    ///
    /// In the event a collision with an existing MIDI endpoint unique ID in the system, a new random ID will be generated until there are no collisions.
    /// The ID will then be passed into the `storeHandler` closure in order to store the updated ID.
    case manualStorage(
        readHandler: () -> MIDIIdentifier?,
        storeHandler: (MIDIIdentifier?) -> Void
    )
}

// MARK: - Read/Write Methods

extension MIDIIdentifierPersistence {
    /// Reads the unique ID from the persistent storage, if applicable.
    public func readID() -> MIDIIdentifier? {
        switch self {
        case .none:
            return nil
            
        case let .unmanaged(uniqueID: uniqueID):
            return uniqueID
            
        case let .managed(userDefaultsKey: key, suite: suite):
            // test to see if key does not exist first
            // otherwise just calling integer(forKey:) returns 0 if key does not exist
            guard suite.object(forKey: key) != nil
            else { return nil }
            
            let readInt = suite.integer(forKey: key)
            
            guard let int32Exactly = Int32(exactly: readInt)
            else { return nil }
            
            return MIDIIdentifier(int32Exactly)
            
        case .manualStorage(readHandler: let readHandler, storeHandler: _):
            if let readInt = readHandler() {
                return MIDIIdentifier(readInt)
            }
            
            return nil
        }
    }
    
    /// Writes the unique ID to the persistent storage, if applicable.
    public func writeID(_ newValue: MIDIIdentifier?) {
        switch self {
        case .none:
            return // no storage
        
        case .unmanaged(uniqueID: _):
            return // no storage
        
        case let .managed(userDefaultsKey: key, suite: suite):
            suite.setValue(newValue, forKey: key)
            
        case .manualStorage(readHandler: _, storeHandler: let storeHandler):
            storeHandler(newValue)
        }
    }
}
