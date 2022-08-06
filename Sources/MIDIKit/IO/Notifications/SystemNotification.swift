//
//  SystemNotification.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

#if !os(tvOS) && !os(watchOS)

import Foundation
@_implementationOnly import CoreMIDI

extension MIDI.IO {
    /// Core MIDI subsystem notification.
    public enum SystemNotification: Equatable, Hashable {
        /// Some aspect of the current MIDI setup changed.
        ///
        /// This notification carries no data. This message is redundant if you’re explicitly handling other notifications.
        case setupChanged
        
        /// The system added a device, entity, or endpoint.
        case added(
            parent: MIDI.IO.Object?,
            child: MIDI.IO.Object
        )
        
        /// The system removed a device, entity, or endpoint.
        case removed(
            parent: MIDI.IO.Object?,
            child: MIDI.IO.Object
        )
        
        /// An object’s property value changed.
        case propertyChanged(
            object: MIDI.IO.Object,
            property: MIDI.IO.Object.Property
        )
        
        /// The system created or disposed of a persistent MIDI Thru connection.
        ///
        /// This notification carries no data.
        case thruConnectionChanged
        
        /// The system changed a serial port owner.
        ///
        /// This notification carries no data.
        case serialPortOwnerChanged
        
        /// A driver I/O error occurred.
        case ioError(
            device: MIDI.IO.Device,
            error: MIDI.IO.MIDIError
        )
        
        /// Other/unknown notification.
        ///
        /// Typically will never happen unless Apple adds additional cases to Core MIDI's `MIDINotificationMessageID` enum.
        case other(messageIDRawValue: Int32)
    }
}

extension MIDI.IO.SystemNotification {
    /// Converts an `InternalNotification` to `SystemNotification`.
    ///
    /// Cache must be supplied if there is a possibility of a `removed` notification, otherwise metadata will be missing.
    internal init?(
        _ internalNotification: MIDI.IO.InternalNotification,
        cache: MIDI.IO.ObjectCache?
    ) {
        switch internalNotification {
        case .setupChanged:
            self = .setupChanged
            
        case let .added(
            parentRef,
            parentType,
            childRef,
            childType
        ):
            
            let parent = MIDI.IO.Object(
                coreMIDIObjectRef: parentRef,
                coreMIDIObjectType: parentType
            )
            guard let child = MIDI.IO.Object(
                coreMIDIObjectRef: childRef,
                coreMIDIObjectType: childType
            )
            else { return nil }
            
            self = .added(
                parent: parent,
                child: child
            )
            
        case let .removed(
            parentRef,
            parentType,
            childRef,
            childType
        ):
            
            // we need to rely on data cache to get more information
            // since a Core MIDI 'removed' notification happens after the object is gone
            
            let parent = MIDI.IO.Object(
                coreMIDIObjectRef: parentRef,
                coreMIDIObjectType: parentType,
                using: cache
            )
            guard let child = MIDI.IO.Object(
                coreMIDIObjectRef: childRef,
                coreMIDIObjectType: childType,
                using: cache
            )
            else { return nil }
            
            self = .removed(
                parent: parent,
                child: child
            )
            
        case let .propertyChanged(
            forRef,
            forRefType,
            propertyName
        ):
            
            // specific notification
            guard let obj = MIDI.IO.Object(
                coreMIDIObjectRef: forRef,
                coreMIDIObjectType: forRefType
            ),
                let property = MIDI.IO.Object.Property(propertyName as CFString)
            else { return nil }
            
            self = .propertyChanged(
                object: obj,
                property: property
            )
            
        case .thruConnectionChanged:
            self = .thruConnectionChanged
            
        case .serialPortOwnerChanged:
            self = .serialPortOwnerChanged
            
        case let .ioError(
            deviceRef,
            error
        ):
            let device = MIDI.IO.Device(deviceRef)
            self = .ioError(
                device: device,
                error: error
            )
            
        case let .other(messageIDRawValue):
            self = .other(messageIDRawValue: messageIDRawValue)
        }
    }
}

extension MIDI.IO.SystemNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .setupChanged:
            return "setupChanged"
            
        case let .added(
            parent,
            child
        ):
            if let parent = parent {
                return "added(parent: \(parent), child: \(child))"
            } else {
                return "added(\(child))"
            }
            
        case let .removed(
            parent,
            child
        ):
            if let parent = parent {
                return "removed(parent: \(parent), child: \(child))"
            } else {
                return "removed(\(child))"
            }
            
        case let .propertyChanged(
            object,
            property
        ):
            return "propertyChanged(for: \(object), property: \(property))"
            
        case .thruConnectionChanged:
            return "thruConnectionChanged"
            
        case .serialPortOwnerChanged:
            return "serialPortOwnerChanged"
            
        case let .ioError(
            device,
            error
        ):
            return "ioError(device: \(device), error: \(error))"
            
        case let .other(messageIDRawValue):
            return "other(ID: \(messageIDRawValue))"
        }
    }
}

#endif
