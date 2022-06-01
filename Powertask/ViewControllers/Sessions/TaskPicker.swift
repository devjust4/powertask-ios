//
//  SessionsTasks.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 24/3/22.
//

import UIKit
import Alamofire

protocol TaskPickerProtocol: AnyObject{
    func taskDidSelected(task: PTTask)
}

class TaskPicker: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: TaskPickerProtocol?
    var userTasks: [PTTask]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false

        userTasks = PTUser.shared.tasks
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        NetworkingProvider.shared.listTasks { tasks in
            PTUser.shared.tasks = tasks
            self.userTasks = PTUser.shared.tasks
            PTUser.shared.savePTUser()
            self.tableView.reloadData()
        } failure: { msg in
            print("ERROR-tasks")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let task = userTasks{
            return task.count
        }
        
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = PTUser.shared.tasks?[indexPath.row] {
            delegate?.taskDidSelected(task: task)
        }
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksSessionsCell", for: indexPath) as! SessionsTasksTableViewCell
        
        if let task = userTasks?[indexPath.row]{
            cell.taskTitle.text = task.name
            cell.taskDate.text = task.handoverDate?.description
            if let date = task.handoverDate {
                let date = (Date(timeIntervalSince1970: TimeInterval(date)))
                cell.taskDate.text = date.formatted(date: .long, time: .omitted)
            } else {
                cell.taskDate.text = "Sin fecha de entrega"
            }
            if let subject = task.subject {
                cell.taskColor.backgroundColor = UIColor(subject.color)
            } else {
                cell.taskColor.backgroundColor = UIColor(named: "AccentColor")!
            }
           
            return cell
        }
        
        return cell
        
    }
}
