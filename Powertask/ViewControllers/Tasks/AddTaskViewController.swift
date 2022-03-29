//
//  AddTaskViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 18/1/22.
//

import UIKit

// TODO: Validar campos de texto y poner limite de caracteres a la descripcion

protocol SaveNewTaskProtocol: AnyObject {
    func appendNewTask(newTask: PTTask)
}

class AddTaskViewController: UIViewController {
    var userIsEdditing = false
    var userTask: PTTask?
    var subject: PTSubject?
    var subtasks: [PTSubtask]?
    var delegate: SaveNewTaskProtocol?
    var newTask: Bool?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var subjectButton: UIButton!
    
    @IBOutlet weak var handoverDatePicker: UIDatePicker!
    @IBOutlet weak var handoverDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var markTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var subtaskLabel: UILabel!
    @IBOutlet weak var subtaskTable: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var handoverDateLabelToSubjectLabel: NSLayoutConstraint!
    @IBOutlet weak var handoverDatePickerToSubjectButton: NSLayoutConstraint!
    
    @IBOutlet weak var startdatePickerToSubjectButton: NSLayoutConstraint!
    @IBOutlet weak var startdateLabelToSubjectLabel: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionLabelToNote: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelToStartdateLabel: NSLayoutConstraint!
    @IBOutlet weak var markTextfieldToStartDatePicker: NSLayoutConstraint!
       
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Interface config
        taskNameTextField.borderStyle = .none
        markTextField.borderStyle = .none
        handoverDatePicker.minimumDate = Date()
        startDatePicker.minimumDate = Date()
        subtaskTable.delegate = self
        subtaskTable.dataSource = self
        
        // MARK: - Data injection
        if let task = userTask {
            
            if task.google_id == nil {
                handoverDatePicker.isHidden = true
                handoverDateLabel.isHidden = true
                handoverDateLabelToSubjectLabel.isActive = false
                handoverDatePickerToSubjectButton.isActive = false
                startdateLabelToSubjectLabel.isActive = true
                startdatePickerToSubjectButton.isActive = true
                markLabel.isHidden = true
                markTextField.isHidden = true
                descriptionLabelToNote.isActive = false
                descriptionLabelToStartdateLabel.isActive = true
                markTextfieldToStartDatePicker.isActive = false
                descriptionTextView.isEditable = true
            }else{
                doneButton.isHidden = true
                subjectButton.isEnabled = false
                markTextField.isEnabled = false
                descriptionTextView.isEditable = false
                taskNameTextField.isEnabled = false
            }
            
            taskNameTextField.text = task.name
            if let description = task.description{
                descriptionTextView.text = description
            }
            if let mark = task.mark {
                markTextField.text = String(format: "%.0f", mark)
            }
            
            if let subject = task.subject {
                subjectButton.setTitle(subject.name, for: .normal)
//                subjectButton.tintColor = UIColor(hex: subject.color)
            }
            if let dueDate = task.startDate {
                startDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(dueDate)), animated: false)
//                startDatePicker.setDate(dueDate, animated: false)
            }
            if let handoverDate = task.handoverDate {
                handoverDatePicker.setDate(Date(timeIntervalSince1970: TimeInterval(handoverDate)), animated: false)
//                startDatePicker.setDate(handoverDate, animated: false)
            }
            if Bool(truncating: task.completed as NSNumber){
                doneButton.setImage(Constants.taskDoneImage, for: .normal)
                doneButton.tintColor = Constants.appColor
            } else {
                doneButton.setImage(Constants.taskUndoneImage, for: .normal)
                doneButton.tintColor = .black
            }
            
            if let mark = task.mark{
                markTextField.text = String(mark)
            }
        } else {
            userIsEdditing = true
            handoverDatePicker.isHidden = true
            handoverDateLabel.isHidden = true
            handoverDateLabelToSubjectLabel.isActive = false
            handoverDatePickerToSubjectButton.isActive = false
            startdateLabelToSubjectLabel.isActive = true
            startdatePickerToSubjectButton.isActive = true
            markLabel.isHidden = true
            markTextField.isHidden = true
            descriptionLabelToNote.isActive = false
            descriptionLabelToStartdateLabel.isActive = true
            markTextfieldToStartDatePicker.isActive = false
        }
        
        if userIsEdditing {
            configInterfaceWhileEdditiing(isEdditing: true)
            descriptionTextView.isEditable = true
        }else{
            descriptionTextView.isEditable = false
            markTextField.isEnabled = false
            subjectButton.isEnabled = false
            taskNameTextField.isEnabled = false
        }
    }
    
    // MARK: - Navigation
    @IBAction func setTaskDone(_ sender: Any) {
        guard let task = userTask else {
            return
        }
        if Bool(truncating: task.completed as NSNumber) {
            doneButton.setImage(Constants.taskUndoneImage, for: .normal)
            doneButton.tintColor = .black
            userTask!.completed = 0
            NetworkingProvider.shared.toggleTask(task: task) { taskCompleted in
                print("toggle ok")
            } failure: { msg in
                print("error toggle")
            }

        } else {
            doneButton.setImage(Constants.taskDoneImage, for: .normal)
            doneButton.tintColor = Constants.appColor
            userTask!.completed = 1
        }

    }
    
    @IBAction func editTask(_ sender: Any) {
        if userIsEdditing {
            saveData()
            configInterfaceWhileEdditiing(isEdditing: false)
            userIsEdditing = false
            
            if newTask == true {
                if let task = userTask{
                    NetworkingProvider.shared.createTask(task: task, success: { taskId in
                        print("task create")
                    }, failure: { msg in
                        print("error creaating task")
                    })
                }
            }else{
                if let task = userTask{
                    NetworkingProvider.shared.editTask(task: task) { msg in
                        print("task save")
                    } failure: { msg in
                        print("error saving task")
                    }
                }
            }
        } else {
            configInterfaceWhileEdditiing(isEdditing: true)
            userIsEdditing = true
        }
    }
    
    @IBAction func addSubtask(_ sender: Any) {
        if let subtasks = userTask?.subtasks{
            userTask?.subtasks?.append(PTSubtask(name: nil, done: false))
            subtaskTable.beginUpdates()
            subtaskTable.insertRows(at: [IndexPath(row: subtasks.count, section: 0)], with: .automatic)
            subtaskTable.endUpdates()
        } else {
            if let _ = subtasks {
                subtasks?.append(PTSubtask(name: nil, done: false))
            } else {
                subtasks = [PTSubtask(name: nil, done: false)]
            }
            subtaskTable.reloadData()
        }
    }
    
    // MARK: - Supporting Functions
    func configInterfaceWhileEdditiing(isEdditing: Bool){
        startDatePicker.isEnabled = isEdditing
        addButton.isHidden = !isEdditing
        if let task = userTask{
            if task.google_id == nil{
                taskNameTextField.isEnabled = isEdditing
                markTextField.isEnabled = isEdditing
                descriptionTextView.isEditable = isEdditing
                descriptionTextView.isSelectable = isEdditing
                subjectButton.isEnabled = isEdditing
            }else{
                taskNameTextField.isEnabled = false
                markTextField.isEnabled = false
//                descriptionTextView.isEditable = false
//                descriptionTextView.isSelectable = false
            }
        }
        if isEdditing {
            editButton.title = "Guardar"
        } else {
            editButton.title = "Editar"
        }
    }
    
    func setSubject(subject: PTSubject){
        if let _ = userTask {
            userTask!.subject = subject
            subjectButton.setTitle(subject.name, for: .normal)
            subjectButton.tintColor = UIColor(subject.color)
        }
    }
    
    func saveData(){
        if let task = userTask {
            userTask!.name = taskNameTextField.text ?? "Tarea sin nombre"
            userTask!.description = descriptionTextView.text
            // TODO: Controlar nota FLOAT?
            userTask!.mark = Float(markTextField.text ?? "00")
            print(handoverDatePicker.date)
//            userTask!.handoverDate = handoverDatePicker.date
            Int(handoverDatePicker.date.timeIntervalSince1970)
            if !startDatePicker.isHidden {
//                userTask!.startDate = startDatePicker.date
                Int(startDatePicker.date.timeIntervalSince1970)
            }
            // TODO: falta perform date
        } else {
            var name = taskNameTextField.text
            var description = descriptionTextView.text
            var handoverDate = Int(handoverDatePicker.date.timeIntervalSince1970)
            var startDate: Int?
            if !startDatePicker.isHidden {
                var startDate = Int(handoverDatePicker.date.timeIntervalSince1970)
            }
            userTask = PTTask(name: name!, startDate: startDate, handoverDate: handoverDate, description: description!, completed: 0, subject: nil, subtasks: nil)
            delegate?.appendNewTask(newTask: userTask!)
        }
    }
    
    @IBAction func selectSubject(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "SubjectSelector") as? SubjectSelectorViewController {
            viewController.delegate = self
            viewController.subject = userTask?.subject
            self.present(viewController, animated: true, completion: nil)
    }
    
}
}

extension AddTaskViewController: SubjectDelegate, SubtaskCellTextDelegate, SubtaskCellDoneDelegate {
    func subtaskDonePushed(_ subtaskCell: UserSubtaskTableViewCell, subtaskDone: Bool?) {
        let indexPath = subtaskTable.indexPath(for: subtaskCell)
        if let row = indexPath?.row, let _ = userTask, let done = subtaskDone {
            userTask!.subtasks![row].completed = Int(truncating: done as! NSNumber)
        }
    }
    
    func subtaskCellEndEditing(_ subtaskCell: UserSubtaskTableViewCell, didEndEditingWithText: String?) {
        let indexPath = subtaskTable.indexPath(for: subtaskCell)
        if let row = indexPath?.row, let subtaskName = didEndEditingWithText {
            if let _ = userTask {
                userTask?.subtasks?[row].name = subtaskName
            } else if let _ = subtasks {
                subtasks?[row].name = subtaskName
            }
        }
    }
    
    func subjectWasChosen(_ newSubject: PTSubject) {
        print("elegido")
        subjectButton.setTitle(newSubject.name, for: .normal)
        subjectButton.tintColor = UIColor(newSubject.color) 
        subject = newSubject
        if let _ = userTask {
            userTask!.subject = newSubject
        }
    }
}

extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userTask = userTask, let subtasks = userTask.subtasks {
            return subtasks.count
        } else if let subtasks = subtasks {
            return subtasks.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Borrar") { (action, view, completion) in
            if let _ = self.userTask?.subtasks?[indexPath.row]{
                self.userTask?.subtasks?.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        delete.backgroundColor =  UIColor(named: "DestructiveColor")
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtaskCell") as? UserSubtaskTableViewCell
        if let subtask = userTask?.subtasks?[indexPath.row] {
            cell?.subtaskNameTextField.text = subtask.name
            cell?.subtaskTextDelegate = self
            cell?.subtaskDoneDelegate = self
            if userIsEdditing {
                cell?.subtaskNameTextField.isEnabled = true
            } else {
                cell?.subtaskNameTextField.isEnabled = false
            }
            if subtask.completed == 1 {
                cell?.doneButton.setImage(Constants.subTaskDoneImage, for: .normal)
                cell?.subtaskDone = true
            } else if subtask.completed == 0{
                cell?.doneButton.setImage(Constants.subTaskUndoneImage, for: .normal)
                cell?.subtaskDone = false
            }
        } else {
            cell?.subtaskTextDelegate = self
            cell?.subtaskDoneDelegate = self
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
