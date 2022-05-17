//
//  CalendarsViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import FSCalendar
import EventKit
import UIColorHexSwift
import GoogleSignIn
import SPIndicator

class CalendarsViewController: UIViewController {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var eventListTable: UITableView!
    @IBOutlet weak var addEventPullDownButton: UIButton!
    @IBOutlet weak var calendarTitle: UILabel!
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    var selectedDateEvents: [PTEvent]?
    let noEventsMessages = ["😄 No hay nada!", "🌴 Día libre, yaaaay!", "🍹 Aprovecha el día", "💪🏻 Toma, toma!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate = self
        calendarView.dataSource = self
        eventListTable.delegate = self
        eventListTable.dataSource = self
        calendarView.select(Date.now)
        calendarView.locale = Locale(identifier: "ES")
        calendarTitle.text = calendarView.currentPage.addingTimeInterval(43200).formatToString(using: .monthYear)
        calendarView.appearance.titleSelectionColor = UIColor.white
        calendarView.appearance.eventSelectionColor = UIColor.lightGray
        swipeAction()
                
        NetworkingProvider.shared.listEvents { events in
            PTUser.shared.events = events
            self.selectedDateEvents = self.getEventForDate(date: Date.now, events: events)
            self.calendarView.reloadData()
            self.eventListTable.reloadSections([0], with: .fade)
        } failure: { msg in
            print(msg)
        }
        
        
        
        
        // TODO: Convertir titulo a boton para volver a la pagina de la fecha actual
        
        
        
        // TODO: Pasar esto a una función
        let eventMenu = UIAction(title: "Examen", image: UIImage(systemName: "doc.plaintext")) { (action) in
            self.instantiateNewEventController(eventType: EventType.exam, isNewEvent: true, event: nil)
        }
        
        let vacationMenu = UIAction(title: "Festivo", image: UIImage(systemName: "heart")) { (action) in
            self.instantiateNewEventController(eventType: EventType.vacation, isNewEvent: true, event: nil)
        }
        
        let personalMenu = UIAction(title: "Personal", image: UIImage(systemName: "person")) { (action) in
            self.instantiateNewEventController(eventType: EventType.personal, isNewEvent: true, event: nil)
        }
        
        let menu = UIMenu(title: "Nuevo evento", options: .displayInline, children: [eventMenu, vacationMenu, personalMenu])
        addEventPullDownButton.menu = menu
        addEventPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NetworkingProvider.shared.listEvents { events in
            PTUser.shared.events = events
            PTUser.shared.savePTUser()
            self.selectedDateEvents = self.getEventForDate(date: Date.now, events: events)
            self.calendarView.reloadData()
            self.eventListTable.reloadSections([0], with: .fade)
        } failure: { msg in
            print(msg)
        }
        
    }
    
    func instantiateNewEventController(eventType: EventType, isNewEvent: Bool, event: PTEvent?) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "newEventView") as? NewEventViewController {
            viewController.delegate = self
            viewController.isNewEvent = isNewEvent
            viewController.eventType = eventType
            if let event = event {
                viewController.event = event
            }
            //viewController.selectedDate = calendarView.selectedDate
            self.present(viewController, animated: true, completion: nil)
        }
    }
    func getEventForDate(date: Date, events: [String : PTEvent]) -> [PTEvent]{
        //        let selectedEvents = events.filter { event in
        //            return DateInterval(start: event.value.startDate, end: event.value.endDate).contains(date)
        //let selectedDate = date.formatToString(using: .justDay)
        let selectedDate = date.formatted(date: .complete, time: .omitted)
        let selectedEvents = events.filter { event in
            let startDate = event.value.startDate.formatted(date: .complete, time: .omitted)
            let endDate = event.value.startDate.formatted(date: .complete, time: .omitted)
            // print("selección \(selectedDate) empieza: \(startDate) termina: \(endDate) ")
            if startDate <= selectedDate && endDate >= selectedDate {
                return true
            } else {
                return false
            }
        }
        
        let events2 = selectedEvents.values
        
        let sortedTypes = events2.sorted { event1, event2 in
            // festivo
            // todo el dia
            // examen
            //eventos normales
            return event1.type > event2.type
            
//            if event1.type == event2.type {
//                return event1.startDate > event2.startDate
//            } else {
//                return event1.type > event2.type
//            }
        }
        
        let sortedEvents = sortedTypes.sorted { event1, event2 in
            // festivo
            // todo el dia
            // examen
            //eventos normales
            return event1.startDate > event2.startDate
            
//            if event1.type == event2.type {
//                return event1.startDate > event2.startDate
//            } else {
//                return event1.type > event2.type
//            }
        }
        
        return sortedEvents
    }
    
    func getCellInfo(allDay: Int, startDate: Date, endDate: Date) -> String{
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd/MM/YY"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:MM"
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "dd/MM 'a las' HH:MM"
        
        if Bool(truncating: allDay as NSNumber) {
            return "Todo el día"
        } else {
            if dayFormatter.string(from: startDate) == dayFormatter.string(from: endDate) {
                return "\(timeFormatter.string(from: startDate)) hasta \(timeFormatter.string(from: endDate))"
            } else {
                return "\(dateTimeFormatter.string(from: startDate)) hasta \(dateTimeFormatter.string(from: endDate))"
            }
        }
    }
    
    func swipeAction() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        calendarView.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        calendarView.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            calendarView.setScope(.week, animated: true)
        case .down:
            calendarView.setScope(.month, animated: true)
        default:
            calendarView.setScope(.month, animated: true)
        }
    }
}

// MARK:- Calendar Delegate and DataSource
extension CalendarsViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        if let events = PTUser.shared.events {
            selectedDateEvents = getEventForDate(date: date, events: events)
        }
        eventListTable.reloadSections([0,0], with: .fade)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let events = PTUser.shared.events else { return 0 }
        let todayEvents = getEventForDate(date: date, events: events)
        let personalAndExam = todayEvents.filter { event in
            event.type == EventType.exam || event.type == EventType.personal
        }
        return personalAndExam.count
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendarTitle.text = calendarView.currentPage.addingTimeInterval(43200).formatToString(using: .monthYear)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarViewHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        guard let events = PTUser.shared.events else { return [UIColor.clear] }
        let thisDateEvents = getEventForDate(date: date, events: events)
        var colors: [UIColor] = []
        let examnEvents = thisDateEvents.filter { event in
            event.type == EventType.exam
        }
        let personalEvents = thisDateEvents.filter { event in
            event.type == EventType.personal
        }
        for exam in examnEvents {
            if let color = exam.subject?.color {
                colors.append(UIColor(color))
            }
        }
        for _ in personalEvents {
            colors.append(UIColor.lightGray)
        }
        return colors
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 2.2)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if date.formatToString(using: .justDay) == Date.now.formatToString(using: .justDay) {
            return UIColor.white
        }
        guard let events = PTUser.shared.events else { return UIColor.black }
        let todayEvents = getEventForDate(date: date, events: events)
        for event in todayEvents {
            if event.type == EventType.vacation {
                return UIColor.red
            }
        }
        return UIColor.black
    }
}

// MARK:- TableView Delegate and DataSource
extension CalendarsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let events = selectedDateEvents else { return 1 }
        if events.isEmpty {
            return 1
        } else {
            return events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let backgroundView = UIView()
        // FIXME: Refactorizar esto
        backgroundView.backgroundColor = UIColor(named: "AccentColor")
        if let _ = selectedDateEvents, selectedDateEvents!.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noEventsCell") as! NoEventsTableViewCell
            let text = noEventsMessages.randomElement()
            cell.noEventMessage.text = text
            return cell
        }
        guard let event = selectedDateEvents?[indexPath.row] else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noEventsCell") as! NoEventsTableViewCell
            let text = noEventsMessages.randomElement()
            cell.noEventMessage.text = text
            return cell
        }
        switch event.type {
        case .vacation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "allDayRow") as? AllDayEventTableViewCell
            cell?.selectedBackgroundView = backgroundView
            cell?.eventColorImage.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(CGFloat(0.6))
            cell?.eventNameLabel.text = event.name
            cell?.eventNameLabel.textColor = UIColor.white
            cell?.eventImage.image = UIImage(systemName: "heart.fill")
            cell?.eventImage.tintColor = UIColor.white
            return cell!
        case .exam, .personal:
            if Bool(truncating: event.allDay as NSNumber) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "allDayRow") as? AllDayEventTableViewCell
                cell?.backgroundColor = UIColor(named: "AccentColor")
                cell?.selectedBackgroundView = backgroundView
                cell?.eventColorImage.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(CGFloat(0.6))
                cell?.eventNameLabel.text = event.name
                cell?.eventNameLabel.textColor = UIColor.white
                cell?.eventImage.image = UIImage(systemName: "24.circle.fill")
                cell?.eventImage.tintColor = UIColor.white
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventRow") as? EventTableViewCell
                cell?.selectedBackgroundView = backgroundView
                cell?.eventTitle.text = event.name
                cell?.eventColor.backgroundColor = UIColor(event.subject?.color ?? "#00000")
                cell?.eventInfo.text = getCellInfo(allDay: event.allDay, startDate:  event.startDate, endDate: event.endDate)
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedDateEvents!.isEmpty {
            if let event = selectedDateEvents?[indexPath.row] {
                switch event.type {
                case EventType.personal:
                    instantiateNewEventController(eventType: EventType.personal, isNewEvent: false, event: event)
                case EventType.exam:
                    instantiateNewEventController(eventType: EventType.exam, isNewEvent: false, event: event)
                case EventType.vacation:
                    instantiateNewEventController(eventType: EventType.vacation, isNewEvent: false, event: event)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let event = self.selectedDateEvents?[indexPath.row], let superEvent = PTUser.shared.events?["\(event.id!)"]{
                PTUser.shared.events?.removeValue(forKey: "\(event.id!)")
                self.selectedDateEvents = self.getEventForDate(date: self.calendarView.selectedDate!, events: PTUser.shared.events!)
                self.calendarView.reloadData()
                if selectedDateEvents!.isEmpty {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
                NetworkingProvider.shared.deleteEvent(event: event) { msg in
                    let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Evento eliminado", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                } failure: { msg in
                    print("errror eliminando")
                }
                
            } else {
                print("no hay evento coincidente")
            }
        }
    }
}

extension CalendarsViewController: NewEventProtocol {
    func SaveNewEvent(event: PTEvent, isNewEvent: Bool) {
        if isNewEvent {
            NetworkingProvider.shared.createEvent(event: event) { id in
                PTUser.shared.events!["\(id)"] = event
                PTUser.shared.events!["\(id)"]?.id = id
                PTUser.shared.savePTUser()
                //self.eventListTable.reloadSections([0], with: .fade)
                self.eventListTable.reloadData()
                self.calendarView.reloadData()
                let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Evento guardado", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
            } failure: { msg in
                print(msg)
            }
        } else {
            NetworkingProvider.shared.editEvent(event: event) { msg in
                // TODO: Revisar porque no se está recargando bien la lista
                // TODO: Idear un método para que se actualicen siempre los dias
                // FIXME: Que pasa cuando el evento no se ha creado en la base datos y no tiene id?
                PTUser.shared.events!["\(event.id!)"] = event
                self.selectedDateEvents = self.getEventForDate(date: self.calendarView.selectedDate!, events: PTUser.shared.events!)
                self.calendarView.reloadData()
                self.eventListTable.reloadSections([0], with: .fade)
                let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Evento actualizado", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
            } failure: { msg in
                print(msg)
            }
        }
    }
}

extension Date {
    func contains(dateToCheck: Date, date1: Date, date2: Date) -> Bool {
       // let dateToCheckInterval = DateInterval(start: <#T##Date#>, end: <#T##Date#>)
        return true
    }
    
    func isContained(date1: Date, date2: Date, dateToCheck: Date) -> Bool {
        
        return true
    }
}
