//
//  Manager Add and Remove.swift
//  MIDIKit
//
//  Created by Steffan Andrews on 2021-02-21.
//

import Foundation
import CoreMIDI

extension MIDIIO.Manager {
	
	/// Adds a managed connected input to the `managedInputConnections` dictionary of the `Manager`.
	///
	/// - Parameters:
	///   - toOutput: Criteria for identifying a MIDI endpoint in the system to connect to.
	///   - tag: Internal unique tag to reference the managed item in the `Manager`.
	///   - receiveHandler: Event handler for received MIDI packets.
	///
	/// - throws: `MIDIIO.MIDIError`
	public func addInputConnection(
		toOutput: MIDIIO.EndpointIDCriteria,
		tag: String,
		receiveHandler: MIDIIO.ReceiveHandler
	) throws {
		
		let newCD = MIDIIO.InputConnection(
			toOutput: toOutput,
			receiveHandler: receiveHandler
		)
		
		// store the connection object in the manager,
		// even if subsequent connection fails
		managedInputConnections[tag] = newCD
		
		try newCD.connect(in: self)
		
	}
	
	/// Adds a managed connected output to the `managedOutputConnections` dictionary of the `Manager`.
	///
	/// - Parameters:
	///   - toInput: Criteria for identifying a MIDI endpoint in the system to connect to.
	///   - tag: Internal unique tag to reference the managed item in the `Manager`.
	///
	/// - throws: `MIDIIO.MIDIError`
	public func addOutputConnection(
		toInput: MIDIIO.EndpointIDCriteria,
		tag: String
	) throws {
		
		let newCS = MIDIIO.OutputConnection(
			toInput: toInput
		)
		
		// store the connection object in the manager,
		// even if subsequent connection fails
		managedOutputConnections[tag] = newCS
		
		try newCS.connect(in: self)
		
	}
	
	/// Creates a MIDI play-through (thru) connection.
	///
	/// If the connection is non-persistent, a managed thru connection will be added to the `managedThruConnections` dictionary of the `Manager` and its lifecycle will be that of the `Manager` or until removeThruConnection is called for the connection.
	///
	/// If the connection is persistent, it is instead stored persistently by the system and references will not be directly held in the `Manager`. To access persistent connections, the `unmanagedPersistentThrus` property will retrieve a list of connections from the system, if any match the owner ID passed as argument.
	///
	/// For every persistent thru connection your app creates, they should be assigned the same persistent ID (domain) so they can be managed or removed in future.
	///
	/// - Warning: Be careful when creating persistent thru connections, as they can become stale and orphaned if the endpoints used to create them cease to be relevant at any point in time.
	///
	/// - Note: Max 8 outputs and max 8 inputs are allowed when forming a thru connection.
	///
	/// - parameter outputs: Maximum of 8 `Endpoint`s.
	/// - parameter inputs: Maximum of 8 `Endpoint`s.
	/// - parameter tag: Unique `String` key to refer to the new object that gets added to `managedThruConnections` collection dictionary.
	/// - parameter lifecycle: If `false`, thru connection will expire when the app terminates. If `true`, the connection persists in the system indefinitely (even after system reboots) until explicitly removed.
	@available(swift, deprecated: 0.1, message: "Not yet available due to a CoreMIDI bug. May become available in future releases of MIDIKit.")
	public func addThruConnection(
		outputs: [MIDIIO.OutputEndpoint],
		inputs: [MIDIIO.InputEndpoint],
		tag: String,
		_ lifecycle: MIDIIO.ThruConnection.Lifecycle = .nonPersistent,
		params: MIDIThruConnectionParams? = nil
	) throws {
		
		fatalError("Feature is not implemented at this time due to a CoreMIDI bug. It may be available in future versions of MIDIKit if a workaround is found.")
		
//		let newCT = MIDIIO.ThruConnection(
//			outputs: outputs,
//			inputs: inputs,
//			lifecycle,
//			params: params
//		)
//		
//		// if non-persistent, add to managed array
//		if lifecycle == .nonPersistent {
//			// store the connection object in the manager,
//			// even if subsequent connection fails
//			managedThruConnections[tag] = newCT
//		}
//		
//		// otherwise, we won't store a reference to a persistent thru connection
//		// persistent connections are stored by the system
//		// to analyze or delete a persistent connection,
//		// access the `unmanagedPersistentThrus(ownerID:)` method.
//		
//		try newCT.create(in: self)
		
	}
	
	/// Adds a managed virtual input to the `managedInputs` dictionary of the `Manager` and creates the MIDI port in the system.
	///
	/// The lifecycle of the MIDI port exists for as long as the `Manager` instance exists, or until `.remove(::)` is called.
	///
	/// - Parameters:
	///   - name: Name of the endpoint as seen in the system.
	///   - tag: Internal unique tag to reference the managed item in the `Manager`.
	///   - uniqueID: System-global unique identifier for the port. If nil, a random available ID will be assigned and returned if successful.
	///   - receiveHandler: Event handler for received MIDI packets.
	///
	/// A note on `uniqueID`:
	///
	/// It is required that the `uniqueID` be stored persistently in a data store of your choosing, and supplied when recreating the same port. This allows other applications to identify the port and reconnect to it, as the port name is not used to identify a MIDI port since MIDI ports are allowed to have the same name, but must have unique IDs.
	///
	/// It is best practise to re-store the `uniqueID` every time this method is called, since these IDs are temporal and not registered or reserved in the system in any way. Since ID collisions are possible, a new available random ID will be obtained and returned if that happens, and that updated ID should be stored in-place of the old one in your data store.
	///
	/// Do not generate the number yourself. Rather, if no ID is yet stored, pass `nil` for `uniqueID` and allow the method to generate the new ID for you, then store it. Next time the same port is added, fetch that ID and supply it as the `uniqueID`, remembering to re-store the returned `uniqueID` once more in the event that there was a collision and a new ID has been returned.
	///
	/// - throws: `MIDIIO.MIDIError`
	/// - Returns: The port's effective `uniqueID`.
	public func addInput(
		name: String,
		tag: String,
		uniqueID: MIDIIO.Endpoint.UniqueID? = nil,
		receiveHandler: MIDIIO.ReceiveHandler
	) throws -> MIDIIO.Endpoint.UniqueID {
		
		let newVD = MIDIIO.Input(
			name: name,
			uniqueID: uniqueID,
			receiveHandler: receiveHandler
		)
		
		managedInputs[tag] = newVD
		
		try newVD.create(in: self)
		
		guard let uniqueID = newVD.uniqueID else {
			throw MIDIIO.MIDIError.connectionError("Could not read virtual MIDI endpoint unique ID.")
		}
		
		return uniqueID
		
	}
	
	/// Adds a managed virtual output to the `managedOutputs` dictionary of the `Manager`.
	///
	/// The lifecycle of the MIDI port exists for as long as the `Manager` instance exists, or until `.remove(::)` is called.
	///
	/// - Parameters:
	///   - name: Name of the endpoint as seen in the system.
	///   - tag: Internal unique tag to reference the managed item in the `Manager`.
	///   - uniqueID: System-global unique identifier for the port. If nil, a random available ID will be assigned and returned if successful.
	///
	/// A note on `uniqueID`:
	///
	/// It is required that the `uniqueID` be stored persistently in a data store of your choosing, and supplied when recreating the same port. This allows other applications to identify the port and reconnect to it, as the port name is not used to identify a MIDI port since MIDI ports are allowed to have the same name, but must have unique IDs.
	///
	/// It is best practise to re-store the `uniqueID` every time this method is called, since these IDs are temporal and not registered or reserved in the system in any way. Since ID collisions are possible, a new available random ID will be obtained and returned if that happens, and that updated ID should be stored in-place of the old one in your data store.
	///
	/// Do not generate the number yourself. Rather, if no ID is yet stored, pass `nil` for `uniqueID` and allow the method to generate the new ID for you, then store it. Next time the same port is added, fetch that ID and supply it as the `uniqueID`, remembering to re-store the returned `uniqueID` once more in the event that there was a collision and a new ID has been returned.
	///
	/// - throws: `MIDIIO.MIDIError`
	/// - Returns: The port's effective `uniqueID`.
	public func addOutput(
		name: String,
		tag: String,
		uniqueID: MIDIIO.Endpoint.UniqueID? = nil
	) throws -> MIDIIO.Endpoint.UniqueID {
		
		let newVS = MIDIIO.Output(
			name: name,
			uniqueID: uniqueID
		)
		
		managedOutputs[tag] = newVS
		
		try newVS.create(in: self)
		
		guard let uniqueID = newVS.uniqueID else {
			throw MIDIIO.MIDIError.connectionError("Could not read virtual MIDI endpoint unique ID.")
		}
		
		return uniqueID
		
	}
	
}

extension MIDIIO.Manager {
	
	public enum ManagedType: CaseIterable, Hashable {
		case inputConnection
		case outputConnection
		case thruConnection
		case input
		case output
	}
	
	public enum TagSelection: Hashable {
		case all
		case withTag(String)
	}
	
	// individual methods
	
	/// Remove a managed MIDI endpoint or connection.
	public func remove(_ type: ManagedType,
					   _ tagSelection: TagSelection) {
		
		switch type {
		case .inputConnection:
			switch tagSelection {
			case .all:
				managedInputConnections.removeAll()
			case .withTag(let tag):
				managedInputConnections[tag] = nil
			}
			
		case .outputConnection:
			switch tagSelection {
			case .all:
				managedOutputConnections.removeAll()
			case .withTag(let tag):
				managedOutputConnections[tag] = nil
			}
			
		case .thruConnection:
			switch tagSelection {
			case .all:
				managedThruConnections.removeAll()
			case .withTag(let tag):
				managedThruConnections[tag] = nil
			}

		case .input:
			switch tagSelection {
			case .all:
				managedInputs.removeAll()
			case .withTag(let tag):
				managedInputs[tag] = nil
			}
			
		case .output:
			switch tagSelection {
			case .all:
				managedOutputs.removeAll()
			case .withTag(let tag):
				managedOutputs[tag] = nil
			}
				
		}
		
	}
	
	/// Remove all managed MIDI endpoints and connections.
	///
	/// What is unaffected, and not reset:
	/// - Persistent thru connections stored in the system.
	/// - Notification handler attached to the `Manager`.
	/// - `clientName` property
	/// - `model` property
	/// - `manufacturer` property
	public func reset() {
		
		ManagedType.allCases.forEach {
			remove($0, .all)
		}
		
	}
	
}

