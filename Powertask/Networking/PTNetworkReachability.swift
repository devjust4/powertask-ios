//
//  PTNetworkReachability.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import Foundation
import Alamofire
import UIKit

class PTNetworkReachability {
  // 1
  let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")
  // 2
  func startNetworkMonitoring() {
    reachabilityManager?.startListening { status in
      switch status {
      case .notReachable:
        self.showOfflineAlert()
      case .reachable(.cellular):
        self.dismissOfflineAlert()
      case .reachable(.ethernetOrWiFi):
        self.dismissOfflineAlert()
      case .unknown:
        print("Unknown network state")
      }
    }
  }
  
  static let shared = PTNetworkReachability()
  let offlineAlertController: UIAlertController = {
    UIAlertController(title: "No Network", message: "Please connect to network and try again", preferredStyle: .alert)
  }()

  func showOfflineAlert() {
    let rootViewController = UIApplication.shared.windows.first?.rootViewController
    rootViewController?.present(offlineAlertController, animated: true, completion: nil)
  }

  func dismissOfflineAlert() {
    let rootViewController = UIApplication.shared.windows.first?.rootViewController
    rootViewController?.dismiss(animated: true, completion: nil)
  }
}
