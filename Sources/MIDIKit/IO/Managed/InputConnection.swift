//
//  InputConnection.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import Foundation
@_implementationOnly import CoreMIDI

extension MIDI.IO {
    
    /// A managed MIDI input connection created in the system by the `Manager`.
    /// This connects to an external output in the system and subscribes to its MIDI events.
    public class InputConnection: _MIDIIOManagedProtocol {
        
        // _MIDIIOManagedProtocol
        internal weak var midiManager: MIDI.IO.Manager?
        
        // MIDIIOManagedProtocol
        public private(set) var api: MIDI.IO.APIVersion
        public var midiProtocol: MIDI.IO.ProtocolVersion { api.midiProtocol }
        
        // class-specific
        
        public private(set) var outputCriteria: MIDI.IO.EndpointIDCriteria<MIDI.IO.OutputEndpoint>
        
        internal var outputEndpointRef: MIDI.IO.CoreMIDIEndpointRef? = nil
        
        internal var inputPortRef: MIDI.IO.CoreMIDIPortRef? = nil
        
        internal var receiveHandler: MIDI.IO.ReceiveHandler
        
        public private(set) var isConnected: Bool = false
        
        // init
        
        /// - Parameters:
        ///   - toOutput: Input to connect to.
        ///   - receiveHandler: Receive handler to use for incoming MIDI messages.
        ///   - midiManager: Reference to I/O Manager object.
        ///   - api: Core MIDI API version.
        internal init(toOutput: MIDI.IO.EndpointIDCriteria<MIDI.IO.OutputEndpoint>,
                      receiveHandler: MIDI.IO.ReceiveHandler.Definition,
                      midiManager: MIDI.IO.Manager,
                      api: MIDI.IO.APIVersion = .bestForPlatform()) {
            
            self.outputCriteria = toOutput
            self.receiveHandler = receiveHandler.createReceiveHandler()
            self.midiManager = midiManager
            self.api = api.isValidOnCurrentPlatform ? api : .bestForPlatform()
            
        }
        
        deinit {
            
            _ = try? disconnect()
            
        }
        
    }
    
}

extension MIDI.IO.InputConnection {
    
    /// Returns the output endpoint this connection is connected to.
    public var endpoint: MIDI.IO.OutputEndpoint? {
        
        guard let unwrappedOutputEndpointRef = outputEndpointRef
        else { return nil }
        
        return .init(unwrappedOutputEndpointRef)
        
    }
    
}

extension MIDI.IO.InputConnection {
    
    /// Connect to a MIDI Output.
    ///
    /// - Parameter manager: MIDI manager instance by reference
    ///
    /// - Throws: `MIDI.IO.MIDIError`
    internal func connect(in manager: MIDI.IO.Manager) throws {
        
        if isConnected { return }
        
        // if previously connected, clean the old connection
        _ = try? disconnect()
        
        guard let getOutputEndpointRef = outputCriteria
                .locate(in: manager.endpoints.outputs)?
                .coreMIDIObjectRef
        else {
            
            isConnected = false
            
            throw MIDI.IO.MIDIError.connectionError(
                "MIDI output with criteria \(outputCriteria) not found while attempting to form connection."
            )
            
        }
        
        self.outputEndpointRef = getOutputEndpointRef
        
        var newConnection = MIDIPortRef()
        
        // connection name must be unique, otherwise process might hang (?)
        
        switch api {
        case .legacyCoreMIDI:
            // MIDIInputPortCreateWithBlock is deprecated after macOS 11 / iOS 14
            try MIDIInputPortCreateWithBlock(
                manager.clientRef,
                UUID().uuidString as CFString,
                &newConnection,
                { [weak self] packetListPtr, srcConnRefCon in
                    guard let strongSelf = self else { return }
                    
                    let packets = packetListPtr.packets()
                    
                    strongSelf.midiManager?.eventQueue.async {
                        strongSelf.receiveHandler.packetListReceived(packets)
                    }
                }
            )
            .throwIfOSStatusErr()
            
        case .newCoreMIDI:
            guard #available(macOS 11, iOS 14, macCatalyst 14, tvOS 14, watchOS 7, *) else {
                throw MIDI.IO.MIDIError.internalInconsistency(
                    "New Core MIDI API is not accessible on this platform."
                )
            }
            
            try MIDIInputPortCreateWithProtocol(
                manager.clientRef,
                UUID().uuidString as CFString,
                self.api.midiProtocol.coreMIDIProtocol,
                &newConnection,
                { [weak self] eventListPtr, srcConnRefCon in
                    guard let strongSelf = self else { return }
                    
                    let packets = eventListPtr.packets()
                    let midiProtocol = MIDI.IO.ProtocolVersion(eventListPtr.pointee.protocol)
                    
                    strongSelf.midiManager?.eventQueue.async {
                        strongSelf.receiveHandler.eventListReceived(packets,
                                                                    protocol: midiProtocol)
                    }
                }
            )
            .throwIfOSStatusErr()
            
        }
        
        try MIDIPortConnectSource(
            newConnection,
            getOutputEndpointRef,
            nil
        )
        .throwIfOSStatusErr()
        
        inputPortRef = newConnection
        
        isConnected = true
        
    }
    
    /// Disconnects the connection if it's currently connected.
    /// 
    /// Errors thrown can be safely ignored and are typically only useful for debugging purposes.
    internal func disconnect() throws {
        
        isConnected = false
        
        guard let unwrappedInputPortRef = self.inputPortRef,
              let unwrappedOutputEndpointRef = self.outputEndpointRef else { return }
        
        defer { self.inputPortRef = nil }
        
        try MIDIPortDisconnectSource(unwrappedInputPortRef, unwrappedOutputEndpointRef)
            .throwIfOSStatusErr()
        
    }
    
    /// Refresh the connection.
    /// This is typically called after receiving a Core MIDI notification that system port configuration has changed or endpoints were added/removed.
    internal func refreshConnection(in manager: MIDI.IO.Manager) throws {
        
        guard outputCriteria
                .locate(in: manager.endpoints.outputs) != nil
        else {
            isConnected = false
            return
        }
        
        try connect(in: manager)
        
    }
    
}

extension MIDI.IO.InputConnection: CustomStringConvertible {
    
    public var description: String {
        
        var outputEndpointName: String = "?"
        if let unwrappedOutputEndpointRef = outputEndpointRef,
           let getName = try? MIDI.IO.getName(of: unwrappedOutputEndpointRef) {
            outputEndpointName = "\(getName)".quoted
        }
        
        var outputEndpointRefString: String = "nil"
        if let unwrappedOutputEndpointRef = outputEndpointRef {
            outputEndpointRefString = "\(unwrappedOutputEndpointRef)"
        }
        
        var inputPortRefString: String = "nil"
        if let unwrappedInputPortRef = inputPortRef {
            inputPortRefString = "\(unwrappedInputPortRef)"
        }
                
        return "InputConnection(criteria: \(outputCriteria), outputEndpointRef: \(outputEndpointRefString) \(outputEndpointName), inputPortRef: \(inputPortRefString), isConnected: \(isConnected))"
        
    }
    
}

extension MIDI.IO.InputConnection: MIDIIOReceivesMIDIMessagesProtocol {
    
    // empty
    
}
