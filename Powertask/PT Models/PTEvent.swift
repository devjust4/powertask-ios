//
//  Event.swift
//  Powertask
//
//  Created by Daniel Torres on 1/2/22.
//

import Foundation

struct PTEvent: Codable {
    var id: Int?
    var name: String
    var type: EventType
    var allDay: Int
    var notes: String?
    var startDate: Date
    var endDate: Date
    var subject: PTSubject?

    enum CodingKeys: String, CodingKey {
        case id, name, type, subject, notes
        case allDay = "all_day"
        case startDate = "timestamp_start"
        case endDate = "timestamp_end"
    }
}



enum EventType: String, Comparable, Codable  {
    case vacation
    case exam
    case personal
    
    static func < (lhs: EventType, rhs: EventType) -> Bool {
        switch lhs {
        case .personal, .exam:
            if rhs == .vacation {
                return true
            } else {
                return false
            }
        case .vacation:
            return false
        }
    }
}
