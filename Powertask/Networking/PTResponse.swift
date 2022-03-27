//
//  SPTResponse.swift
//  Powertask
//
//  Created by Daniel Torres on 18/2/22.
//

import Foundation

struct PTResponse: Decodable {
    var response: String?
    var new: Int?
    var id: Int?
    var token: String?
    var tasks: [PTTask]?
    var courses: [PTCourse]?
    var sessions: [PTSession]?
    var events: [String : PTEvent]?
    var subjects: [PTSubject]?
    var blocks: [PTBlock]?
    var url: String?
    var student: PTUser?
    var widgets: PTWidgets?
    var periods: [PTPeriod]?
}
