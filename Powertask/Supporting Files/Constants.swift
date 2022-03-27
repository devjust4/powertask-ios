//
//  Constants.swift
//  Powertask
//
//  Created by Daniel Torres on 18/1/22.
//

import Foundation
import UIKit

final class Constants {
    // MARK: - Colors
    static let appColor = UIColor(red:0.19, green:0.69, blue:0.77, alpha:1.00)

    // MARK: - Button Configuration

    static let taskButtonConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular, scale: .large)
    static let subTaskButtonConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .large)

    static let taskDoneImage = UIImage(systemName: "checkmark.circle", withConfiguration: taskButtonConfig)
    static let subTaskDoneImage = UIImage(systemName: "checkmark.circle", withConfiguration: subTaskButtonConfig)


   static let taskUndoneImage = UIImage(systemName: "circle", withConfiguration: taskButtonConfig)
    static let subTaskUndoneImage = UIImage(systemName: "circle", withConfiguration: subTaskButtonConfig)
    
}

// MARK:- Date Extensions
extension DateFormatter {
   static let monthYear: DateFormatter = {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(abbreviation: "GMT")
       formatter.locale = Locale(identifier: "ES")
      formatter.dateFormat = "MMMM 'de' Y"
      return formatter
   }()
    
    static let justDay: DateFormatter = {
        let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "d M Y"
        return formatter
    }()
    
    static let serverDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Date {
   func formatToString(using formatter: DateFormatter) -> String {
      return formatter.string(from: self)
   }
}
