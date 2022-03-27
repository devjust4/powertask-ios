//
//  PTWidget.swift
//  Powertask
//
//  Created by Daniel Torres on 8/3/22.
//

import Foundation

struct PTWidgets: Codable {
    var sessionTime: PTSessionTime
    var periodDays: PTPeriodDays
    var averageMark: PTAverageMark
    var taskCounter: PTTaskCounter
}

struct PTSessionTime: Codable {
    var hours: Int
    var minutes: Int
}

struct PTPeriodDays: Codable {
    var days: Int
    var percentage: Float
}

struct PTAverageMark: Codable {
    var average: Float
}

struct PTTaskCounter: Codable {
    var completed: Int
    var total: Int
}
