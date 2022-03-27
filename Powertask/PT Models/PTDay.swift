//
//  Day.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

import Foundation

struct PTDay: Codable {
    var vacation: [PTEvent]?
    var exam: [PTEvent]?
    var personal: [PTEvent]?
}
