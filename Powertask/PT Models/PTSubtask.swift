//
//  PTSubtask.swift
//  Powertask
//
//  Created by Daniel Torres on 18/2/22.
//

import Foundation

struct PTSubtask: Codable {
    var id: Int?
    var name: String?
    var completed: Int?
    
    init(name: String?, done: Bool) {
        self.name = name
        self.completed = Int(truncating: done as! NSNumber)
    }
}
