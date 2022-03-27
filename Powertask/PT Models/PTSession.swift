//
//  Session.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

import Foundation


struct PTSession: Codable {
    var id: Int?
    var quantity: Int
    var duration: Int
    var totalTime: Int
    var task: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, duration, task
        case totalTime = "total_time"
    }
    
}

