//
//  User.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

import Foundation
import GoogleSignIn

class PTUser: Codable {
    static let shared = PTUser()
    private init() {}
    
    var id: Int?
    var new: Bool?
    var name: String?
    var email: String?
    var imageUrl: String?
    var apiToken: String?
    var tasks: [PTTask]?
    var subjects: [PTSubject]?
    var periods: [PTPeriod]?
    var sessions: [PTSession]?
    var events: [String : PTEvent]?
    var blocks: [PTBlock]?
    var widgets: PTWidgets?
    
    func savePTUser(){
        UserDefaults.standard.setCodableObject(PTUser.shared, forKey: "user")
    }
    
    func loadPTUser(){
        if let user = UserDefaults.standard.codableObject(dataType: PTUser.self, key: "user") {
            PTUser.shared.id = user.id
            PTUser.shared.name = user.name
            PTUser.shared.email = user.email
            PTUser.shared.apiToken = user.apiToken
            PTUser.shared.imageUrl = user.imageUrl
            PTUser.shared.subjects = user.subjects
            PTUser.shared.periods = user.periods
            PTUser.shared.blocks = user.blocks
            PTUser.shared.events = user.events
            PTUser.shared.tasks = user.tasks
            PTUser.shared.sessions = user.sessions
            PTUser.shared.widgets = user.widgets
        } else {
            print("Not yet saved with key user)")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, new, email, tasks, subjects, periods, sessions, events, blocks, widgets
        case imageUrl = "image_url"
        case apiToken = "api_token"
    }
}


extension UserDefaults {
    func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {
        let encoded = try? JSONEncoder().encode(data)
        set(encoded, forKey: defaultName)
    }
    
    func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {
        guard let userDefaultData = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: userDefaultData)
    }
}

