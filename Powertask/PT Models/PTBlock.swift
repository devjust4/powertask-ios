//
//  Block.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

import Foundation

struct PTBlock: Codable {
    var timeStart: Date
    var timeEnd: Date
    var day : Int
    var subject: PTSubject
    
    enum CodingKeys: String, CodingKey {
        case day, subject
        case timeStart = "time_start"
        case timeEnd = "time_end"
    }
}

