//
//  PowerTaskRequestLogger.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import Foundation
import Alamofire

class PTRequestLogger: EventMonitor {
    
    let queue = DispatchQueue(label: "com.just4.powertask.networklogger")
    func requestDidFinish(_ request: Request) {
        print(request.description)
    }
    
    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        guard let data = response.data else {
            return
        }
        if let json = try? JSONSerialization
            .jsonObject(with: data, options: .mutableContainers) {
            print(json)
        }
    }
}
