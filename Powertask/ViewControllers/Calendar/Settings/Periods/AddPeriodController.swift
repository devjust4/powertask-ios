//
//  AddPeriodController.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 6/2/22.
//
import UIKit
import SwiftUI
import SPIndicator

protocol UpdatePeriodList {
    func updateList()
}

class AddPeriodController: UIViewController {
    
    var period: PTPeriod?
    var subjects: [PTSubject]?
    var selectedSubjects: [PTSubject]?
    var userIsEditing: Bool?
    var delegate: UpdatePeriodList?
    var isNewPeriod: Bool?
    
    @IBOutlet weak var periodTableView: UITableView!
    @IBOutlet weak var editPeriod: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSubjects = period?.subjects
        subjects = PTUser.shared.subjects
        if let isNewPeriod = isNewPeriod, isNewPeriod {
            period = PTPeriod(id: nil, name: "Nombre del periodo", startDate: Date.now, endDate: Date.now, subjects: [], blocks: nil)
            selectedSubjects = []
            userIsEditing = true
            editPeriod.title = "Guardar"
        } else {
            userIsEditing = false
        }
        periodTableView.dataSource = self
        periodTableView.delegate = self
        periodTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let periodController = self.presentingViewController as? PeriodsController{
            periodController.updateList()
        }
    }
    
    // MARK: - Navigation
    // Valida los datos introducidos, pinta la pantalla según la edición esté activa y envia la petición al servidor.
    @IBAction func editPeriod(_ sender: Any) {
        if let editing = userIsEditing, editing {
            if let period = period {
                if let noSubjects = period.subjects?.isEmpty, noSubjects {
                    let image = UIImage.init(systemName: "xmark.circle")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Debes tener al menos una asignatura", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .error, completion: nil)
                } else if period.name == "" {
                    let image = UIImage.init(systemName: "rectangle.and.pencil.and.ellipsis")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Debes asignar un nombre al periodo", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .error, completion: nil)
                } else if period.startDate.timeIntervalSince1970 >= period.endDate.timeIntervalSince1970 {
                    let image = UIImage.init(systemName: "xmark.circle")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Comprueba las fechas", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .error, completion: nil)
                } else {
                    userIsEditing = false
                    editPeriod.title = "Editar"
                    if let isNewPeriod = isNewPeriod, isNewPeriod{
                        NetworkingProvider.shared.createPeriod(period: period) { periodId in
                            self.period!.id = periodId
                            PTUser.shared.periods?.append(self.period!)
                            self.delegate?.updateList()
                            let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                            let indicatorView = SPIndicatorView(title: "Periodo añadido", preset: .custom(image))
                            indicatorView.present(duration: 3, haptic: .success, completion: nil)
                        } failure: { msg in
                            
                        }
                        self.isNewPeriod = false
                        
                    } else {
                        if let index = PTUser.shared.periods?.firstIndex(where: { userPeriod in
                            period.id == userPeriod.id
                        }) {
                            NetworkingProvider.shared.editPeriod(period: period) { msg in
                                PTUser.shared.periods?[index] = period
                                PTUser.shared.savePTUser()
                                self.delegate?.updateList()
                                let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                                let indicatorView = SPIndicatorView(title: "Periodo guardado", preset: .custom(image))
                                indicatorView.present(duration: 3, haptic: .success, completion: nil)
                            } failure: { msg in
                                
                            }
                        }
                    }
                }
            }
        } else {
            userIsEditing =  true
            editPeriod.title = "Guardar"
        }
        
        periodTableView.reloadData()
    }
}

// MARK: - Funciones de la tabla que compone la vista
extension AddPeriodController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            if let subject = subjects {
                return subject.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section){
        case 0:
            return "Detalles"
        case 1:
            return "Asignaturas"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! NameTableViewCell
                cell.setPeriodName.isEnabled = userIsEditing! ? true : false
                cell.setPeriodName.text = period?.name
                cell.delegate = self
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
                cell.periodTime.text =  "Inicio"
                cell.datePicker.isEnabled = userIsEditing! ? true : false
                cell.delegate = self
                if period?.startDate == nil{
                    cell.datePicker.setDate(Date.now, animated: false)
                }else{
                    cell.datePicker.setDate((period?.startDate)!, animated: false)
                }
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
                cell.periodTime.text = "Fin"
                cell.datePicker.isEnabled = userIsEditing! ? true : false
                cell.delegate = self
                if period?.endDate == nil{
                    cell.datePicker.setDate(Date.now, animated: false)
                }else{
                    cell.datePicker.setDate((period?.endDate)!, animated: false)
                }
                return cell
            }
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as! SubjectTableViewCell
            
            if let subjectForCell = subjects?[indexPath.row] {
                cell.subjectName.text = subjectForCell.name
                cell.subjectColor.backgroundColor = UIColor(hexString: subjectForCell.color)
                if let bool = period?.subjects?.contains(where: { subject in
                    return subject.id == subjectForCell.id
                }), bool {
                    cell.checkSubject.setImage(UIImage(systemName: "checkmark"), for: .normal)
                    cell.checkSubject.tintColor = UIColor(named: "AccentColor")
                    if userIsEditing! {
                        cell.subjectName.isEnabled = true
                        cell.subjectColor.isEnabled = true
                        cell.subjectName.alpha = 1
                        cell.subjectColor.alpha = 1
                    } else {
                        cell.subjectName.isEnabled = false
                        cell.subjectColor.isEnabled = false
                        cell.subjectName.alpha = 1
                        cell.subjectColor.alpha = 1
                    }
                    
                } else {
                    cell.checkSubject.setImage(UIImage(systemName: "xmark"), for: .normal)
                    cell.checkSubject.tintColor = UIColor.red
                    cell.subjectName.isEnabled = false
                    cell.subjectName.alpha = 0.5
                    cell.subjectColor.isEnabled = false
                    cell.subjectColor.alpha = 0.5
                }
                
                cell.subjectColorDelegate = self
                cell.selectedSubjectDelegate = self
                cell.delegate = self
                if let editing = userIsEditing, editing == true {
                    cell.checkSubject.isEnabled = true
                } else {
                    cell.checkSubject.isEnabled = false
                }
            }
            return cell
        }
        return cell
    }
}

extension AddPeriodController: PeriodNameTextFieldProtocol, PeriodDatePickerProtocol, PeriodSubjectTextViewProtocol, ColorButtonPushedProtocol, UIColorPickerViewControllerDelegate, SubjectSelectedDelegate{
    
    // Recibe la celda que ha sido editada y el texto que se ha introducido dentro de su textField.
    func didTextEndEditing(_ cell: SubjectTableViewCell, editingText: String?) {
        if let index = periodTableView.indexPath(for: cell)?.row {
            PTUser.shared.subjects?[index].name = editingText!
            if let indexInSelectedSubjects = selectedSubjects?.firstIndex(where: { subject in
                subject.id == PTUser.shared.subjects?[index].id
            }) {
                selectedSubjects?[indexInSelectedSubjects].name = editingText!
            }
            if let indexInPeriodSubject = period?.subjects?.firstIndex(where: { subject in
                subject.id == PTUser.shared.subjects?[index].id
            }) {
                period?.subjects?[indexInPeriodSubject].name = editingText!
            }
        }
    }
    
    // Recibe la celda que ha sido editada y la fecha introducida en su datePicker
    func didDateEndEditing(_ cell: DateTableViewCell, editingDate: Date?) {
        let indexPath = periodTableView.indexPath(for: cell)
        if let index = indexPath?.row, let date = editingDate {
            if index == 1{
                period?.startDate = date
            }
            if index == 2{
                period?.endDate = date
            }
        }
    }
    
    // Recibe la celda que ha sido editada y el texto que se ha introducido dentro de su textView.
    func didTextEndEditing(_ cell: NameTableViewCell, editingText: String?) {
        if let text = editingText {
            period?.name = text
        }
    }
    
    // Recibe la celda de la signatura seleccionada/deseleccionada y su valor (seleccionado o no)
    func markSubjectSelected(_ cell: SubjectTableViewCell, selected: Bool) {
        if let subjectIndex = periodTableView.indexPath(for: cell)?.row {
            if selected {
                if let subject = subjects?[subjectIndex] {
                    selectedSubjects?.append(subject)
                }
            } else {
                if let subjectToRemove = subjects?[subjectIndex], let indexToRemove = selectedSubjects?.firstIndex(where: { subject in
                    subject.id == subjectToRemove.id
                }) {
                    selectedSubjects?.remove(at: indexToRemove)
                }
            }
            period!.subjects = selectedSubjects
        }
    }
    
    // Recibe la celda de la asignatura cuyo color se ha modificado y el color seleccionado en formato hexadecimal como un String
    func colorPicked(_ cell: SubjectTableViewCell, color: String) {
        if let index = periodTableView.indexPath(for: cell)?.row {
            PTUser.shared.subjects?[index].color = color
            if let indexInSelectedSubjects = selectedSubjects?.firstIndex(where: { subject in
                subject.id == PTUser.shared.subjects?[index].id
            }) {
                selectedSubjects?[indexInSelectedSubjects].color = color
            }
            if let indexInPeriodSubject = period?.subjects?.firstIndex(where: { subject in
                subject.id == PTUser.shared.subjects?[index].id
            }) {
                period?.subjects?[indexInPeriodSubject].color = color
            }
        }
    }
    
    // Instancia el colorPicker del sistema
    func instanceColorPicker(_ cell: SubjectTableViewCell) {
        let colorViewController = UIColorPickerViewController()
        colorViewController.delegate = cell
        colorViewController.supportsAlpha = false
        self.present(colorViewController, animated: true, completion: nil)
    }
}


