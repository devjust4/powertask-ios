//
//  Subjects.swift
//  Powertask
//
//  Created by Daniel Torres on 31/1/22.
//
// prueba

import Foundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreServices


final class PTSubject: NSObject, NSItemProviderReading, NSItemProviderWriting, Codable {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(UTType.data.identifier as String)]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> PTSubject {
        let decoder = JSONDecoder()
            do {
              //Here we decode the object back to it's class representation and return it
                let subject = try decoder.decode(PTSubject.self, from: data)
                print(subject)
              return subject
            } catch {
              fatalError()
            }
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(UTType.data.identifier as String)]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        print("load data")
        let progress = Progress(totalUnitCount: 100)
            do {
              //Here the object is encoded to a JSON data object and sent to the completion handler
              let data = try JSONEncoder().encode(self)
              progress.completedUnitCount = 100
              completionHandler(data, nil)
            } catch {
              completionHandler(nil, error)
            }
            return progress
    }
    
    var id: Int
    var name: String
    var color: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
    }
}


