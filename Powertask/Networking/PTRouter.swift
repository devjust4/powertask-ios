//
//  PTRouter.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit
import Alamofire

enum PTRouter {
    case login
    case listSubjects
    case editSubject(PTSubject)
    
    case listTasks
    case createTask(PTTask)
    case editTask(PTTask)
    case deleteTask(PTTask)
    case toogleTask(PTTask)
    case toogleSubtask(PTSubtask)
    
    case listEvents
    case createEvent(PTEvent)
    case editEvent(PTEvent)
    case deleteEvent(PTEvent)
    
    case listPeriods
    case createPeriod(PTPeriod)
    case editPeriod(PTPeriod)
    case deletePeriod(PTPeriod)
    
    case listSessions
    case createSession(PTSession)
    case deleteSession(PTSession)
    
    case initialDownload
    case editProfile(String)
    case getWidgetsInfo

  var baseURL: String {
      return "http://powertask.kurokiji.com/public/api"
  }

  var path: String {
    switch self {
    case .login:
        return "/loginRegister"
    case .listSubjects:
        return "/subject/list"
    case .editSubject(let subject):
        return "/task/edit/\(subject.id)"
    
    case .listTasks:
        return "/task/list"
    case .createTask:
        return "/task/create"
    case .editTask(let task):
        return "/task/edit/\(task.id)"
    case .deleteTask(let task):
        return "/task/delete/\(task.id)"
    case .toogleTask(let task):
        return "/task/toggle/\(task.id)"
    case .toogleSubtask(let subtask):
        return "/subtask/toggle/\(subtask.id)"
   
    case .listEvents:
        return "/event/list"
    case .createEvent(let event):
        return "/event/create"
    case .editEvent(let event):
        if let eventId = event.id {
            return "/event/edit/\(eventId)"
        } else {
            return "/event/edit/"
        }
    case .deleteEvent(let event):
        if let eventId = event.id {
            return "/event/delete/\(eventId)"
        } else {
            return "/event/delete/"
        }
    case .listPeriods:
        return "/period/list"
    case .createPeriod:
        return "/period/create"
    case .editPeriod(let period):
        return "/period/edit/\(period.id)"
    case .deletePeriod(let period):
        return "/period/delete/\(period.id!)"
   
    case .listSessions:
        return "/session/list"
    case .createSession:
        return "/session/create"
    case .deleteSession(let session):
        return "/session/delete/\(session.id)"
    
    case .initialDownload:
        return "/student/initialDownload"
    case .editProfile:
        return "/student/edit"
    case .getWidgetsInfo:
        return "/student/widget/getAllWidgetInfo"
    }
  }

  var method: HTTPMethod {
    switch self {

    case .editSubject(_), .editTask(_), .toogleTask(_), .toogleSubtask(_), .editEvent(_), .editPeriod(_), .editProfile:
        return .put
    case .listSubjects, .listTasks, .listEvents, .listPeriods, .listSessions, .initialDownload, .getWidgetsInfo:
        return .get
    case .login, .createTask(_), .createEvent(_), .createPeriod(_), .createSession(_):
        return .post
    case .deleteTask(_), .deleteEvent(_), .deletePeriod(_), .deleteSession(_):
        return .delete
    }
  }

  var parameters: [String: String]? {
    switch self {
    case .login, .listSubjects, .deleteTask(_), .listTasks, .toogleTask(_), .toogleSubtask(_), .listEvents, .deleteEvent(_), .listPeriods, .deletePeriod(_), .listSessions, .deleteSession(_), .initialDownload, .getWidgetsInfo:
        return nil
        
    case .editSubject(let subject):
        return ["name" : subject.name ?? "" , "color" : subject.color ?? "#000000"]
        
 
    case .createTask(let task), .editTask(let task):
        if let subjectId = task.subject?.id {
            return ["name" : task.name,
                    "date_start" : "fecha de prueba",
                    "description" : task.description ?? "",
                    "subject_id" : String(subjectId)]
        } else {
            return ["name" : task.name,
                    "date_start" : "fecha de prueba",
                    "description" : task.description ?? ""]
        }
        
    case .createEvent(let event), .editEvent(let event):
        if let subjectId = event.subject?.id {
            return ["name": event.name,
                    "type": event.type.rawValue,
                    "all_day" : String(event.allDay),
                    "timestamp_start": String(event.startDate.timeIntervalSince1970),
                    "timestamp_end": String(event.endDate.timeIntervalSince1970),
                    "subject_id": String(subjectId)
            ]
        } else {
            return ["name": event.name,
                    "type": event.type.rawValue,
                    "all_day" : String(event.allDay),
                    "timestamp_start": String(event.startDate.timeIntervalSince1970),
                    "timestamp_end": String(event.endDate.timeIntervalSince1970),
            ]
        }
    
    case .createPeriod(let period), .editPeriod(let period):
        if let data = try? JSONSerialization.data(withJSONObject: period.subjects!) {
            return ["name": period.name,
                    "date_start": String(period.startDate.timeIntervalSince1970),
                    "date_end": String(period.endDate.timeIntervalSince1970),
                    "subjects" : String(data: data, encoding: String.Encoding.utf8)!
                    ]
        }
        
        return ["name": period.name,
                "date_start": String(period.startDate.timeIntervalSinceReferenceDate),
                "date_end": String(period.endDate.timeIntervalSinceReferenceDate),
        ]


    case .createSession(let session):
        if let taskId = session.task {
            return ["quantity": String(session.quantity),
                    "duration": String(session.duration),
                    "total_time": String(session.duration),
                    "task_id": String(taskId),
            ]
        } else {
            return ["quantity": String(session.quantity),
                    "duration": String(session.duration),
                    "total_time": String(session.duration),
            ]
        }
    case .editProfile(let name):
        return ["name": name]
    }
  }
}

extension PTRouter: URLRequestConvertible {
  func asURLRequest() throws -> URLRequest {
    let url = try baseURL.asURL().appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.method = method
      
    if method == .get {
      request = try URLEncodedFormParameterEncoder()
        .encode(parameters, into: request)
    } else if method == .post || method == .put {
      request = try JSONParameterEncoder().encode(parameters, into: request)
      request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
    return request
  }
}

