//
//  TimeTableViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

import UIKit
import SPIndicator

class TimeTableViewController: UIViewController {
    
    @IBOutlet weak var timeTable: UITableView!
    @IBOutlet weak var subjectsCollection: UICollectionView!
    let weekDays = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    var blocks:  [Int : [PTBlock]]?
    var subjects: [PTSubject]?
    var currentPeriod: PTPeriod?
    var timeTableEdited: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subjectsCollection.dragDelegate = self
        subjectsCollection.dragInteractionEnabled = true
        subjectsCollection.dataSource = self
        timeTable.dataSource = self
        timeTable.delegate = self
        timeTableEdited = false

        if let periods = PTUser.shared.periods {
            currentPeriod = periods.first(where: { period in
                period.startDate.timeIntervalSince1970 < Date.now.timeIntervalSince1970 && period.endDate.timeIntervalSince1970 > Date.now.timeIntervalSince1970
            })
        }
        subjects = currentPeriod?.subjects
        blocks = filterAllBlocks(blocks: currentPeriod?.blocks)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Recoge el diccionario de bloques, lo aplana como array y lo envía al servidor
        if var period = currentPeriod, let blocks = blocks, timeTableEdited! {
            let mapBlocks = blocks.values.map({$0})
            period.blocks = mapBlocks.flatMap {$0}
            let index = PTUser.shared.periods?.firstIndex(where: { period in
                period.id == currentPeriod!.id
            })
            if let index = index {
                PTUser.shared.periods?[index] = period
                PTUser.shared.savePTUser()
                NetworkingProvider.shared.editPeriod(period: period) { msg in
                    let image = UIImage.init(systemName: "calendar.badge.plus")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Horario guardado", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                } failure: { msg in
                    let image = UIImage.init(systemName: "calendar.badge.exclamationmark")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Error del servidor", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Supporting functions
    /// Devuelve un array de bloques según el `weekay` pasado.
    ///
    /// - Parameter blocks: Array de bloques.
    /// - Parameter weekday: Día de la semana del que se quieren obtener los bloques [0-6].
    /// - Returns: Array de bloques.
    func filterBlockByDay(blocks: [PTBlock] ,weekDay: Int) -> [PTBlock]{
        return blocks.filter { block in
            block.day == weekDay
        }
    }
    
    /// Prepara los bloques pasados ordenandolos por día de la semana.
    ///
    /// - Parameter blocks: Array de bloques opcional.
    /// - Returns: Diccionario de arrays de bloques cuya clabe coincide con el día de la semana.
    func filterAllBlocks(blocks: [PTBlock]?) -> [Int : [PTBlock]]? {
        if let blocks = blocks {
            let monday = filterBlockByDay(blocks: blocks, weekDay: 0)
            let thuesday = filterBlockByDay(blocks: blocks, weekDay: 1)
            let wednesday = filterBlockByDay(blocks: blocks, weekDay: 2)
            let tursday = filterBlockByDay(blocks: blocks, weekDay: 3)
            let friday = filterBlockByDay(blocks: blocks, weekDay: 4)
            let saturday = filterBlockByDay(blocks: blocks, weekDay: 5)
            let sunday = filterBlockByDay(blocks: blocks, weekDay: 6)
            return [0 : monday, 1 : thuesday, 2 : wednesday, 3 : tursday, 4 : friday, 5 : saturday, 6 : sunday]
        } else {
            return [0 : [], 1 : [], 2 : [], 3 : [], 4 : [], 5 : [], 6 : []]
        }
    }
}

// MARK: - Funciones para draguear las asignaturas
extension TimeTableViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let subjects = subjects else {
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
        let item = subjects[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

// MARK: - Funciones de la colección de asignaturas
extension TimeTableViewController: UICollectionViewDataSource {
    // Cuenta el número de asignaturas y se lo pasa a la colección
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let subjects = subjects {
            return subjects.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // carga cada una de las celdas con la info necesaria
        if let subjects = subjects, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCollectionCell", for: indexPath) as? SubjectCollectionViewCell {
            cell.subjectName.text = subjects[indexPath.row].name
            cell.subjectBackground.layer.borderColor = UIColor(subjects[indexPath.row].color).cgColor
            cell.subjectBackground.layer.borderWidth = 3
            cell.subjectBackground.layer.cornerRadius = 17
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

// MARK: - Funciones de la tabla de bloques
extension TimeTableViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weekDays[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let blocks = blocks, let count = blocks[section]?.count {
            // Se suma uno para dejar uno vacío para añadir nuevos bloques
            return count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "timeBlockCell", for: indexPath) as? TimeTableTableViewCell {
            cell.blockEditDelegate = self
            if let selectedBlocks = blocks?[indexPath.section], selectedBlocks.indices.contains(indexPath.row){
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

// MARK: - Funciones relativas a los protocolos de la celda
extension TimeTableViewController: TimeTableDelegate {
    func addNewBlock(_ cell: TimeTableTableViewCell, newSubject: PTSubject?) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section], let subject = newSubject {
            blocks?[indexPath.section]?.append(PTBlock(timeStart: Date.now, timeEnd: Date.now, day: indexPath.section, subject: subject))
            timeTable.beginUpdates()
            timeTable.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            timeTable.endUpdates()
            timeTableEdited = true
        }
    }
    
    func deleteBlock(_ cell: TimeTableTableViewCell) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section]?[indexPath.row] {
            // blocks![indexPath.section]![indexPath.row].subject = nil
            blocks![indexPath.section]!.remove(at: indexPath.row)
            timeTable.beginUpdates()
            timeTable.deleteRows(at: [indexPath], with: .automatic)
            timeTable.endUpdates()
            timeTableEdited = true
        }
    }
    
    func changeSubject(_ cell: TimeTableTableViewCell, newSubject: PTSubject) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section] {
            blocks![indexPath.section]![indexPath.row].subject = newSubject
        }
        timeTableEdited = true
    }
    
    func changeBlockDate(_ cell: TimeTableTableViewCell, startDate: Date?, endDate: Date?) {
        if let indexPath = timeTable.indexPath(for: cell), let _ = blocks?[indexPath.section] {
            if let startDate = startDate {
                blocks![indexPath.section]![indexPath.row].timeStart = startDate
            }
            if let endDate = endDate {
                blocks![indexPath.section]![indexPath.row].timeEnd = endDate
            }
        }
        timeTableEdited = true
    }
}
