//
//  FirstPeriodConfigViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import UIKit
import SPIndicator
import DynamicColor

class FirstPeriodConfigViewController: UIViewController {
    var periodName: String?
    var periodStartDate: Date?
    var periodEndDate: Date?
    var selectedSubjects: [PTSubject]?
    @IBOutlet weak var newPeriodTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPeriodTable.delegate = self
        newPeriodTable.dataSource = self
    selectedSubjects = []
        if let subjects = PTUser.shared.subjects {
            for subject in subjects {
                selectedSubjects?.append(subject)
            }
        }
    }
    
    @IBAction func nextScreen(_ sender: Any) {
        if let periodName = periodName, let periodStartDate = periodStartDate, let periodEndDate = periodEndDate, let selectedSubjects = selectedSubjects {
            for subject in selectedSubjects {
                print("---\(subject.name)")
                print("***\(subject.color)")
                print(":::\(subject.id)")
            }
            var firstPeriod = PTPeriod(name: periodName, startDate: periodStartDate, endDate: periodEndDate, subjects: selectedSubjects)
            NetworkingProvider.shared.createPeriod(period: firstPeriod) { periodId in
                firstPeriod.id = periodId
                PTUser.shared.periods = [firstPeriod]
                print(firstPeriod)
                print(PTUser.shared.name)
                print(PTUser.shared.periods)
                let image = UIImage.init(systemName: "calendar.badge.plus")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Periodo agregado", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
                if let pageController = self.parent as? OnBoardingViewController {
                    pageController.goNext()
                }
            } failure: { msg in
                let image = UIImage.init(systemName: "calendar.badge.exclamationmark")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Error del servidor", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
            }
        } else {
            let image = UIImage.init(systemName: "rectangle.and.pencil.and.ellipsis")!.withTintColor(.red, renderingMode: .alwaysOriginal)
            let indicatorView = SPIndicatorView(title: "Rellena todos los datos", preset: .custom(image))
            indicatorView.present(duration: 3, haptic: .success, completion: nil)
        }
    }
}

extension FirstPeriodConfigViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            if let subject = PTUser.shared.subjects {
                return subject.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Detalles"
        case 1:
            return "Asignaturas"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! NameTableViewCell
                cell.setPeriodName.isEnabled = true
                cell.delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
                cell.periodTime.text =  "Inicio"
                cell.datePicker.isEnabled = true
                cell.delegate = self
                cell.datePicker.setDate(Date.now, animated: false)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! DateTableViewCell
                cell.periodTime.text = "Fin"
                cell.datePicker.isEnabled = true
                cell.delegate = self
                cell.datePicker.setDate(Date.now, animated: false)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as! SubjectTableViewCell
            if let subject = PTUser.shared.subjects?[indexPath.row] {
                cell.subjectName.text = subject.name
                cell.subjectColor.backgroundColor = UIColor(subject.color)
                cell.checkSubject.alpha = 1
                cell.subjectName.isEnabled = true
                cell.subjectColorDelegate = self
                cell.selectedSubjectDelegate = self
                cell.delegate = self
                cell.subjectName.isEnabled = true
                cell.subjectColor.isEnabled = true
                cell.checkSubject.isEnabled = true
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension FirstPeriodConfigViewController: ColorButtonPushedProtocol, PeriodSubjectTextViewProtocol, SubjectSelectedDelegate, PeriodDatePickerProtocol, PeriodNameTextFieldProtocol {
    func instanceColorPicker(_ cell: SubjectTableViewCell) {
        let colorViewController = UIColorPickerViewController()
        colorViewController.supportsAlpha = false
        colorViewController.delegate = cell
        self.present(colorViewController, animated: true, completion: nil)
    }
    
    func colorPicked(_ cell: SubjectTableViewCell, color: String) {
        if let index = newPeriodTable.indexPath(for: cell)?.row {
            PTUser.shared.subjects![index].color = color
        }
    }
    
    func didTextEndEditing(_ cell: SubjectTableViewCell, editingText: String?) {
        let indexPath = newPeriodTable.indexPath(for: cell)
        if let index = indexPath?.row, let text = editingText{
            PTUser.shared.subjects![index].name = text
        }
    }
    
    func markSubjectSelected(_ cell: SubjectTableViewCell, selected: Bool) {
        let indexPath = newPeriodTable.indexPath(for: cell)
        if let index = indexPath?.row{
            if selected {
                selectedSubjects?.append(PTUser.shared.subjects![index])
            } else {
                let index = selectedSubjects?.firstIndex(of:PTUser.shared.subjects![index])
                selectedSubjects?.remove(at: index!)
            }
        }
    }
    
    func didDateEndEditing(_ cell: DateTableViewCell, editingDate: Date?) {
        let indexPath = newPeriodTable.indexPath(for: cell)
        if let index = indexPath?.row {
            if index == 1 {
                periodStartDate = editingDate
            } else {
                periodEndDate = editingDate
            }
        }
    }
    
    func didTextEndEditing(_ cell: NameTableViewCell, editingText: String?) {
        periodName = editingText
    }
    
    
}
