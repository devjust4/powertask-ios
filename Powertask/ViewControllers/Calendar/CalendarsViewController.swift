//
//  CalendarsViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import FSCalendar
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
        swipeAction()
        retrieveSubjects()
        retrieveEvents()
        // TODO: Convertir titulo a boton para volver a la pagina de la fecha actual
        calendarView.appearance.eventSelectionColor = UIColor.lightGray
      
        // Prepara el menú de selección de creación de nuevo evento
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
    
    /// Instancia el controlador para crear un nuevo evento configurado según los parámetros pasados..
    ///
    /// - Parameter eventType: El tipo de evento a crear según la enumeración EventType.
    /// - Parameter isNewEvent: Booleano para controlar si es un nuevo evento.
    /// - Parameter event: El evento a modificar, si hubiera
    func instantiateNewEventController(eventType: EventType, isNewEvent: Bool, event: PTEvent?) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "newEventView") as? NewEventViewController {
            viewController.delegate = self
            viewController.isNewEvent = isNewEvent
            viewController.eventType = eventType
            if let event = event {
                viewController.event = event
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    /// Realiza la petición al servidor para obtener los eventos del usuario
    ///
    func retrieveEvents() {
        NetworkingProvider.shared.listEvents { events in
            PTUser.shared.events = events
            self.selectedDateEvents = self.getEventForDate(date: Date.now, events: events)
            self.calendarView.reloadData()
            self.eventListTable.reloadSections([0], with: .fade)
        } failure: { msg in
            print(msg)
        }
    }
    
    /// Realiza la petición al servidor para obtener las asignaturas del usuario
    ///
    func retrieveSubjects() {
        NetworkingProvider.shared.listSubjects { subjects in
            PTUser.shared.subjects = subjects
        } failure: { error in
            print(error)
        }
    }
    
    /// Filtra y ordena los eventos para la fecha que se le pasa como parámetro.
    ///
    /// - Parameter date: La fecha para la que se quieren obtener los eventos.
    /// - Parameter events: El diccionario de eventos recibido desde el servidor.
    /// - Returns: Array de eventos del día pasado como argumento.
    func getEventForDate(date: Date, events: [String : PTEvent]) -> [PTEvent]{
        let selectedDate = date.formatToString(using: .justDay)
        let selectedEvents = events.filter { event in
            let stringStartDate = event.value.startDate.formatToString(using: .justDay)
            let stringEndDate = event.value.endDate.formatToString(using: .justDay)
            if stringStartDate <= selectedDate && stringEndDate >= selectedDate {
                return true
            } else {
                return false
            }
        }

        return selectedEvents.values.sorted { event1, event2 in
            if event1.type == event2.type {
                return event1.startDate > event2.startDate
            } else {
                return event1.type > event2.type
            }
        }
    }
    
    /// Devuelve el texto a pintar en la celda del evento.
    ///
    /// - Parameter allDay: Booleano en formato entero que indica si el evento dura todo el día.
    /// - Parameter startDate: La fecha de inicio del evento.
    /// - Parameter endDate: La fecha de fin del evento.
    /// - Returns: El texto formateado para mostrar en la celda del evento.
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
    
    /// Configura y aplica el gesto vertical (arriba y abajo) para cambiar entre el calendario semanal y mensual.
    ///
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

// MARK: - Calendar Delegate and DataSource
extension CalendarsViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
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
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
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
}

// MARK: - TableView Delegate and DataSource
extension CalendarsViewController: UITableViewDelegate, UITableViewDataSource {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        guard let events = PTUser.shared.events else { return UIColor.white }
        if date.formatToString(using: .justDay) == Date.now.formatToString(using: .justDay) {
            return UIColor.white
        }
        let todayEvents = getEventForDate(date: date, events: events)
        for event in todayEvents {
            if event.type == EventType.vacation {
                return UIColor.red
            }
        }
        return UIColor.black
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let events = selectedDateEvents else { return 0 }
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let backgroundView = UIView()
        //TODO: Buscar un color de selección
        backgroundView.backgroundColor = UIColor(named: "AccentColor")
        guard let event = selectedDateEvents?[indexPath.row] else { return UITableViewCell() }
        // TODO: Si es tarea?
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
                cell?.eventInfo.text = getCellInfo(allDay: event.allDay, startDate:  event.startDate, endDate: event.endDate)
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CalendarsViewController: NewEventProtocol {
    func SaveNewEvent(event: PTEvent, isNewEvent: Bool) {
        if isNewEvent {
            NetworkingProvider.shared.createEvent(event: event) { id in
                PTUser.shared.events!["\(id)"] = event
                PTUser.shared.events!["\(id)"]?.id = id
                self.eventListTable.reloadSections([0], with: .fade)
            } failure: { msg in
                print(msg)
            }
        } else {
            NetworkingProvider.shared.editEvent(event: event) { msg in
                // TODO: Revisar porque no se está recargando bien la lista
                // TODO: Idear un método para que se actualicen siempre los dias
                PTUser.shared.events!["\(event.id)"] = event
                self.selectedDateEvents = self.getEventForDate(date: self.calendarView.selectedDate!, events: PTUser.shared.events!)
                self.eventListTable.reloadSections([0], with: .fade)
            } failure: { msg in
                print(msg)
            }
        }
    }
}
