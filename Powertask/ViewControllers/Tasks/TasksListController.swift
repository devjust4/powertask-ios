//
//  TasksViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import SwiftUI

class TasksListController: UITableViewController {
    
    var userTasks: [PTTask]?
    var subjects: [PTSubject]?
    
    
    @IBOutlet var tasksTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTasks = PTUser.shared.tasks
        NetworkingProvider.shared.listTasks { tasks in
            PTUser.shared.savePTUser()
            self.userTasks = PTUser.shared.tasks
            self.tasksTableView.reloadData()
        } failure: { msg in
            print("ERROR-tasks")
        }
        
        NetworkingProvider.shared.listSubjects { subjects in
            PTUser.shared.subjects = subjects
            self.subjects = PTUser.shared.subjects
        } failure: { error in
            print("ERROR-subjects")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tasksTableView.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskDetail" {
            if let indexpath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as? AddTaskViewController
                controller?.userTask = userTasks![indexpath.row]
            }else{
                let controller = segue.destination as? AddTaskViewController
                controller?.newTask = true
            }
        }
        
        func addNewTask(_ sender: Any) {
            performSegue(withIdentifier: "showTaskDetail", sender: self)
        }
        
    }
}

// MARK: - TableView Extension
extension TasksListController: SaveNewTaskProtocol, TaskCellDoneDelegate {
    func taskDonePushed(_ taskCell: UserTaskTableViewCell, taskDone: Bool?) {
        let indexPath = tasksTableView.indexPath(for: taskCell)
        if let row = indexPath?.row, let _ = userTasks,  let done = taskDone {
            userTasks![row].completed = done ? 1 : 0
        }
    }
    
    func appendNewTask(newTask: PTTask) {
        if let _ = userTasks {
            userTasks!.append(newTask)
        } else {
            userTasks = [newTask]
        }
    }
}

extension TasksListController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasks = PTUser.shared.tasks {
            return tasks.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTaskDetail", sender: tableView.cellForRow(at:indexPath))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! UserTaskTableViewCell
        if let task = userTasks?[indexPath.row] {
            if task.google_id == nil{
                cell.doneButton.configuration?.baseForegroundColor = UIColor.black
                cell.doneButton.isEnabled = true
            }else{
                cell.doneButton.configuration?.baseForegroundColor = UIColor.systemGray4
                cell.doneButton.isEnabled = false
            }
            cell.taskNameLabel.text = task.name
            cell.taskDone = Bool(truncating: task.completed as NSNumber)
            cell.taskDoneDelegate = self
            if Bool(truncating: task.completed as NSNumber) {
                cell.doneButton.setImage(Constants.taskDoneImage, for: .normal)
            } else {
                cell.doneButton.setImage(Constants.taskUndoneImage, for: .normal)
            }
            if let date = task.handoverDate{
                let date = Date(timeIntervalSince1970: Double(date))
                cell.taskDueDateLabel.text = date.formatted(date: .long, time: .omitted)
            } else {
                // Como el servidor no devuelve la fecha tal y como se espera se pintan fechas aletorias para la muestra
                cell.taskDueDateLabel.text = "\(Int.random(in: 1...31)) jun 2022"
            }
            cell.courseColorImage.backgroundColor = UIColor(task.subject!.color)
        }
        return cell
    }
}


