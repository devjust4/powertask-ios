//
//  PTRequestIncerceptor.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//
import Foundation
import Alamofire
import GoogleSignIn

class PTRequestInterceptor: RequestInterceptor {
    let retryLimit = 5
    let retryDelay: TimeInterval = 10
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        if let apiToken = PTUser.shared.apiToken {
            urlRequest.setValue(apiToken, forHTTPHeaderField: "api-token")
        }
        
        if let googleToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken {
            urlRequest.setValue(googleToken, forHTTPHeaderField: "token")
        }
        
//        urlRequest.setValue("1", forHTTPHeaderField: "new")
        
        completion(.success(urlRequest))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let response = request.task?.response as? HTTPURLResponse
        //Retry for 5xx status codes
        if let statusCode = response?.statusCode,
           (500...599).contains(statusCode),
           request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else {
            return completion(.doNotRetry)
        }
    }
}
