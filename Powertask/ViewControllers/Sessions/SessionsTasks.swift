//
//  SessionsTasks.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 24/3/22.
//

import UIKit
import Alamofire

protocol transferTasksProtocol: AnyObject{
    func transferTasks(_ view: SesionsTasks, taskTitle: String)
}

class SesionsTasks: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: transferTasksProtocol?
    var userTasks: [PTUser]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        NetworkingProvider.shared.listTasks { tasks in
            PTUser.shared.tasks = tasks
            self.userTasks = PTUser.shared.tasks as! [PTUser]
            PTUser.shared.savePTUser()
            self.tableView.reloadData()
            print(tasks)
        } failure: { msg in
            print("ERROR-tasks")
        }
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
        UserDefaults.standard.set(true, forKey: "taskSelected")
        delegate?.transferTasks(self, taskTitle: "ok")
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksSessionsCell", for: indexPath) as! SessionsTasksTableViewCell
        
        if let task = userTasks?[indexPath.row]{
            cell.titleTask.text = task.name
            return cell
        }
        
        return cell
        
    }
}
