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
            print(tasks)
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
        print("appearing")
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
                print("true")
//            }
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
            print(tasks.count)
            return tasks.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTaskDetail", sender: tableView.cellForRow(at:indexPath))
    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//            let delete = UIContextualAction(style: .normal, title: "Borrar") { (action, view, completion) in
//                if let task = self.userTasks {
//                    self.userTasks?.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .left)
//
//                    NetworkingProvider.shared.deleteTask(task: task[indexPath.row]) { msg in
//                        print("removed")
//                    } failure: { msg in
//                        print("error removing task")
//                    }
//                }
//            }
//            delete.backgroundColor =  UIColor(named: "DestructiveColor")
//
//            let edit = UIContextualAction(style: .normal, title: "Editar") { (action, view, completion) in
//                self.performSegue(withIdentifier: "showTaskDetail", sender: indexPath)
//                print(indexPath)
//                completion(false)
//            }
//            edit.backgroundColor =  UIColor(named: "MainColor")
//            let config = UISwipeActionsConfiguration(actions: [delete, edit])
//            config.performsFirstActionWithFullSwipe = false
//            return config
//        }

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
            if let date = task.startDate{
                var datePicker = (Date(timeIntervalSince1970: TimeInterval(date)))
                cell.taskDueDateLabel.text = datePicker.formatted(date: .long, time: .omitted)
            }
            // TODO: Pensar manera de diferenciar asignaturas
            cell.courseColorImage.backgroundColor = UIColor(task.subject!.color)
        }
        return cell
    }
}


