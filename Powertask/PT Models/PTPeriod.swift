//
//  Periods.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 3/2/22.
//

import Foundation
struct PTPeriod: Codable {
    var id: Int?
    var name: String
    var startDate: Date
    var endDate: Date
    var subjects: [PTSubject]?
    var blocks: [PTBlock]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, subjects, blocks
        case startDate = "date_start"
        case endDate = "date_end"
    }
}
