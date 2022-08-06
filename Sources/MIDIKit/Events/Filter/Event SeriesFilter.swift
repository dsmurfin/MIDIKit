//
//  SeriesFilter.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event {
    /// An object that stores zero or more MIDI event filters, with a method to filter MIDI events through the filters.
    open class SeriesFilter {
        /// Filters to use, processed in series.
        public var filters: [MIDI.Event.Filter]
        
        /// An object that stores zero or more MIDI event filters, with a method to filter MIDI events through the filters.
        public init(filter: MIDI.Event.Filter) {
            filters = [filter]
        }
        
        /// An object that stores zero or more MIDI event filters, with a method to filter MIDI events through the filters.
        public init(filters: [MIDI.Event.Filter]) {
            self.filters = filters
        }
        
        /// Filter events based on the stored `filters`.
        public func filter(events: [MIDI.Event]) -> [MIDI.Event] {
            var events = events
            
            for filter in filters {
                events = filter.apply(to: events)
            }
            
            return events
        }
    }
}
