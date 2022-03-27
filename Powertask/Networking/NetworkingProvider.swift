//
//  NetworkingProvider.swift
//  Powertask
//
//  Created by Daniel Torres on 18/2/22.
//

import Foundation
import Alamofire
import UIKit

class NetworkingProvider {
    static let shared = NetworkingProvider()
    private init() {}
    
    private let kBaseUrl = "http://powertask.kurokiji.com/public/api/"
    let statusOk = 200...499
    
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 120
        let networkLogger = PTRequestLogger()
        let interceptor = PTRequestInterceptor()
        return Session(configuration: configuration, interceptor: interceptor, eventMonitors: [networkLogger])
    }()
    
    // MARK: - Register Request
    func registerOrLogin(success: @escaping (_ token: String, _ new: Bool) -> (), failure: @escaping (_ error: String) ->()) {
        sessionManager.request(PTRouter.login).responseDecodable (of: PTResponse.self) { response in
            if let token = response.value?.token, let new = response.value?.new {
                success(token, Bool(truncating: new as NSNumber))
            } else {
                failure("No token")
            }
        }
    }
    
    func initialDownload(success: @escaping (_ user: PTUser) -> (), failure: @escaping (_ error: String)->()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        sessionManager.request(PTRouter.initialDownload).responseDecodable(of: PTResponse.self, decoder: decoder) { response in
            print(response.debugDescription)
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let student = response.value?.student {
                        success(student)
                    } else {
                        failure("There is a problem decodding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student not found")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    func getWidgetData(success: @escaping (_ widgetsInfo: PTWidgets) -> (), failure: @escaping (_ error: String) -> ()) {
        sessionManager.request(PTRouter.getWidgetsInfo).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let widgetsInfo = response.value?.widgets {
                        success(widgetsInfo)
                    } else {
                        failure("There is a problem decodding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student not found")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    //MARK: - Subjects Request
    func listSubjects(success: @escaping (_ subjects: [PTSubject]) -> (), failure: @escaping (_ error: String) ->()) {
        sessionManager.request(PTRouter.listSubjects).responseDecodable (of: PTResponse.self) { response in
            print(response.debugDescription)

            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let subjects = response.value?.subjects {
                        success(subjects)
                    } else {
                        failure("There is a problem decodding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student not found")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func editSubject(subject: PTSubject, success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.editSubject(subject)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    success("Subject edited properly")
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator error")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Subject by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Task Requests
    public func listTasks(success: @escaping (_ tasks: [PTTask])->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.listTasks).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            print(response.debugDescription)
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let tasks = response.value?.tasks {
                        success(tasks)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student doesn't have tasks")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func createTask(task: PTTask, success: @escaping (_ taskId: Int)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.createTask(task)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 201:
                    if let taskId = response.value?.id {
                        success(taskId)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors")
                    }
                case 401:
                    failure("Invalid token.")
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func editTask(task: PTTask, success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.editTask(task)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        success(response)
                    } else {
                        failure ("There is a problem decoding data")
                    }
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Task by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func deleteTask(task: PTTask, success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.deleteTask(task)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        success(response)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Task by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func toggleTask(task: PTTask, success: @escaping (_ taskCompleted: Bool)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.toogleTask(task)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let taskCompleted = response.value?.response {
                        success((taskCompleted as NSString).boolValue)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Task by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Subtask Requests
    public func toggleSubtask(subtask: PTSubtask, success: @escaping (_ subtaskCompleted: Bool)->(), failure: @escaping (_ msg: String?)->(), subtaskID: Int) {
        sessionManager.request(PTRouter.toogleSubtask(subtask)).validate(statusCode: 200...600).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let subtaskCompleted = response.value?.response {
                        success((subtaskCompleted as NSString).boolValue)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        // "Task by that id doesn't exist."
                        failure(error)
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Event Request
    public func createEvent(event: PTEvent, success: @escaping (_ id: Int)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.createEvent(event)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 201:
                    if let id = response.value?.id {
                        success(id)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func editEvent(event: PTEvent, success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.editEvent(event)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    success("Event edited properly.")
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors.")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Event by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func deleteEvent(event: PTEvent,success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.deleteEvent(event)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    success("Event deleted successfully.")
                case 401:
                    failure("Invalid token.")
                case 404:
                    failure("Event by that id does not exist.")
                default:
                    failure("There is a problem connecting to the server.")
                }
            }
        }
    }
    
    public func listEvents(success: @escaping (_ events: [String : PTEvent])->(), failure: @escaping (_ msg: String?)->()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        sessionManager.request(PTRouter.listEvents).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self, decoder: decoder) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let events = response.value?.events {
                        success(events)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("User doesn't have events.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Periods Request
    public func listPeriods(success: @escaping (_ periods: [PTPeriod])->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.listPeriods).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            print(response.debugDescription)
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let periods = response.value?.periods {
                        success(periods)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Period doesn't have blocks.")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student doesn't have blocks")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    public func createPeriod(period: PTPeriod, success: @escaping (_ periodId: Int)->(), failure: @escaping (_ msg: String?)->()) {
        var parameters: Parameters {
            ["name": period.name,
                    "date_start": String(period.startDate.timeIntervalSince1970),
                    "date_end": String(period.endDate.timeIntervalSince1970),
                    "subjects" : period.subjects ?? "Sin asignaturas"
            ]
        }
        print(parameters)
        sessionManager.request("http://powertask.kurokiji.com/public/api/period/create", method: .post, parameters: period, encoder: JSONParameterEncoder.default).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            print(response.debugDescription)
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 201:
                    if let periodId = response.value?.id {
                        success(periodId)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func editPeriod(period: PTPeriod,success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        print("--- justo antes de enviar vale \(period.startDate.timeIntervalSince1970)")
        var parameters: Parameters {
            ["name": period.name,
                    "date_start": String(period.startDate.timeIntervalSince1970),
                    "date_end": String(period.endDate.timeIntervalSince1970),
                    "subjects" : period.subjects ?? "Sin asignaturas",
                    "blocks" : period.blocks ?? "Sin bloques",
            ]
        }
        
        sessionManager.request("http://powertask.kurokiji.com/public/api/period/edit/\(period.id ?? 0)", method: .put, parameters: period, encoder: JSONParameterEncoder.default).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            print("--- body \(response.request?.httpBody?.debugDescription)")
            print(NSString(data: (response.request?.httpBody)!, encoding: String.Encoding.utf8.rawValue))
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        // "Period edited properly"
                        success(response)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Validator errors")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func deletePeriod(period: PTPeriod,success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.deletePeriod(period)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        success(response)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Period by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Sessions Request
    public func createSession(session: PTSession,success: @escaping (_ sessionId: Int)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.createSession(session)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 201:
                    if let sessionId = response.value?.id {
                        success(sessionId)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    failure("Validator errors.")
                case 401:
                    failure("Invalid token.")
                case 412:
                    failure("Empty Data")
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func deleteSession(session: PTSession,success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.deleteSession(session)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        success(response)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Session by that id doesn't exist.")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    public func listSessions(success: @escaping (_ sessions: [PTSession]?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.listSessions).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let sessions = response.value?.sessions {
                        success(sessions)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("Student doesn't have sessions.")
                    }
                case 401:
                    failure("Invalid token.")
                case 404:
                    if let error = response.value?.response {
                        failure(error)
                    } else {
                        failure("User not found")
                    }
                default:
                    failure("There is a problem connecting to the server")
                }
            }
        }
    }
    
    // MARK: - Profile requests
    
    public func uploadImage(image: UIImage?, progress: @escaping ( _ progressQuantity: Double) -> (),success: @escaping (_ url: String)->(), failure: @escaping (_ msg: String?)->()) {
        if let file = image?.jpegData(compressionQuality: 0.1){
            sessionManager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(file, withName: "image", fileName: "profile.png" , mimeType: "image/png")
                
            }, to: "http://powertask.kurokiji.com/public/api/student/uploadImage", method: .post).validate(statusCode: statusOk).uploadProgress(closure: { progressQuantity in
                progress(progressQuantity.fractionCompleted)
            }).responseDecodable (of: PTResponse.self) { response in
                if let httpCode = response.response?.statusCode {
                    switch httpCode {
                    case 200:
                        if let imageUrl = response.value?.url{
                            success(imageUrl)
                        } else {
                            failure("There is a problem decoding data")
                        }
                    case 401:
                        failure("Invalid token.")
                    default:
                        failure("There is a problem connecting to the server")
                    }
                }
            }
        }
    }
    
    public func editNameInfo(name: String ,success: @escaping (_ msg: String?)->(), failure: @escaping (_ msg: String?)->()) {
        sessionManager.request(PTRouter.editProfile(name)).validate(statusCode: statusOk).responseDecodable(of: PTResponse.self) { response in
            if let httpCode = response.response?.statusCode {
                switch httpCode {
                case 200:
                    if let response = response.value?.response {
                        success(response)
                    } else {
                        failure("There is a problem decoding data")
                    }
                case 400:
                    failure("Validator errors.")
                case 401:
                    failure("Invalid token.")
                default:
                    failure("There is a problem connecting to the server.")
                }
            }
        }
    }
    
}

