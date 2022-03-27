//
//  TimeTableConfigViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import UIKit
import SPIndicator

class TimeTableConfigViewController: UIViewController {
    @IBOutlet weak var timeTable: UITableView!
    @IBOutlet weak var subjectsCollection: UICollectionView!
    let weekDays = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    var blocks:  [Int : [PTBlock]]?
    var colors: [UIColor]?
    var subjects: [PTSubject]?
    var sendableBlocks: [PTBlock]?
    override func viewDidLoad() {
        super.viewDidLoad()
        subjectsCollection.dragDelegate = self
        subjectsCollection.dragInteractionEnabled = true
        subjectsCollection.dataSource = self
        timeTable.dataSource = self
        timeTable.delegate = self
        blocks = [0 : [], 1 : [], 2 : [], 3 : [], 4 : [], 5 : [], 6 : []]
    }
    
    @IBAction func endConfig(_ sender: Any) {
        if var period = PTUser.shared.periods?[0], let blocks = blocks {
            // FIXME: CHAPUZA COJONUDA. ARREGLAR!!
            let mapBlocks = blocks.values.map({$0})
            period.blocks = mapBlocks.flatMap {$0}
            if let blocks = period.blocks, !blocks.isEmpty {
                NetworkingProvider.shared.editPeriod(period: period) { msg in
                    let image = UIImage.init(systemName: "calendar.badge.plus")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Horario guardado", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                    self.performSegue(withIdentifier: "GoToMain", sender: nil)
                } failure: { msg in
                    let image = UIImage.init(systemName: "calendar.badge.exclamationmark")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Error del servidor", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                }
            } else {
                let image = UIImage.init(systemName: "rectangle.and.pencil.and.ellipsis")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Rellena tu horario", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
            }
        }
    }
    func filterBlockByDay(blocks: [PTBlock] ,weekDay: Int) -> [PTBlock]{
        return blocks.filter { block in
            block.day == weekDay
        }
    }
}

extension TimeTableConfigViewController: UICollectionViewDragDelegate {
    // Codifica el elemento seleccionado para poder ser arrastrado
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let subjects = PTUser.shared.subjects else {
            // TODO: Esto no es muy elegante. Pensar soluciones
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
        let item = subjects[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension TimeTableConfigViewController: UICollectionViewDataSource {
    // Cuenta el número de asignaturas y se lo pasa a la colección
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let subjects = PTUser.shared.subjects {
             return subjects.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // carga cada una de las celdas con la info necesaria
        if let subjects = PTUser.shared.subjects, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCollectionCell", for: indexPath) as? SubjectCollectionViewCell {
            cell.subjectName.text = subjects[indexPath.row].name
            cell.subjectBackground.layer.borderColor = UIColor(subjects[indexPath.row].color).cgColor
            //cell.subjectBackground.backgroundColor = UIColor(subjects[indexPath.row].color)
            cell.subjectBackground.layer.borderWidth = 3
            cell.subjectBackground.layer.cornerRadius = 17
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension TimeTableConfigViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weekDays[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // TODO: QUE ES ESTO?
        if let blocks = blocks, let count = blocks[section]?.count {
            return count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "timeBlockCell", for: indexPath) as? TimeTableTableViewCell {
            cell.blockEditDelegate = self
            if let selectedBlocks = blocks?[indexPath.section], selectedBlocks.indices.contains(indexPath.row) {
                let block = selectedBlocks[indexPath.row]
                cell.cellSubject = selectedBlocks[indexPath.row].subject
                cell.startDatePicker.date = block.timeStart
                cell.endDatePicker.date = block.timeEnd
            } else {
                cell.setSubjectNil()
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension TimeTableConfigViewController: TimeTableDelegate {
    func changeSubject(_ cell: TimeTableTableViewCell, newSubject: PTSubject) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section] {
                blocks![indexPath.section]![indexPath.row].subject = newSubject
        }
    }
    
    func changeBlockDate(_ cell: TimeTableTableViewCell, startDate: Date?, endDate: Date?) {
        //TODO: OJO! Revisar que el bloque existe
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section] {
            if let startDate = startDate {
                blocks![indexPath.section]![indexPath.row].timeStart = startDate
            }
            if let endDate = endDate {
                blocks![indexPath.section]![indexPath.row].timeEnd = endDate
            }
        }
    }
    
    func addNewBlock(_ cell: TimeTableTableViewCell, newSubject: PTSubject?) {
        if let indexPath = timeTable.indexPath(for: cell), let subject = newSubject {
            blocks![indexPath.section]?.append(PTBlock(timeStart: Date.now, timeEnd: Date.now, day: indexPath.section, subject: subject))
            timeTable.beginUpdates()
            timeTable.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            timeTable.endUpdates()
        }
    }
    
    func deleteBlock(_ cell: TimeTableTableViewCell) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section]?[indexPath.row] {
           // blocks![indexPath.section]![indexPath.row].subject = nil
            blocks![indexPath.section]!.remove(at: indexPath.row)
            timeTable.beginUpdates()
            timeTable.deleteRows(at: [indexPath], with: .automatic)
            timeTable.endUpdates()
        }
    }
    
    
}
