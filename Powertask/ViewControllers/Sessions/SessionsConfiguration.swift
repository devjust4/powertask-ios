//
//  SessionsConfiguration.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 23/3/22.
//

protocol SaveSessionConfiguration {
    func sessionConfigDidChanged(sessionConfig: [String: Double])
}

import UIKit
import Alamofire
class SessionsConfiguration: UIViewController, UITableViewDataSource, UITableViewDelegate, SessionStepperProtocol{
    
    @IBOutlet weak var tableView: UITableView!
    var sessionConfig: [String: Double]?
    var sessionTime: Double = 25
    var sessionsNumber: Double = 4
    var shortBreak: Double = 5
    var longBreak: Double = 10
    var delegate: SaveSessionConfiguration?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func stepperTimeChanged(_ cell: SessionsConfigurationTableViewCell, data: Double, stepperTag: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let _ = sessionConfig else { return }
        switch stepperTag {
        case 0:
            sessionConfig!["number"] = data
        case 1:
            sessionConfig!["time"] = data
        case 2:
            sessionConfig!["short"] = data
        case 3:
            sessionConfig!["long"] = data
        default:
            fatalError()
        }
        delegate?.sessionConfigDidChanged(sessionConfig: sessionConfig!)
        tableView.reloadRows(at: [indexPath], with: .none)
        // TODO: Guardar datos
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configurationCell", for: indexPath) as! SessionsConfigurationTableViewCell
        
        if indexPath.row == 0{
            guard let sessionNumber = sessionConfig?["number"] else { return cell}
            cell.titleLabel.text = "Numero de sesiones"
            cell.amountLabel.text = "\(Int(sessionNumber))"
            cell.amountStepper.value = sessionNumber
            cell.amountStepper.tag = 0
            cell.delegate = self
        }else if indexPath.row == 1{
            guard let sessionTime = sessionConfig?["time"] else { return cell}
            cell.titleLabel.text = "Duración"
            cell.amountLabel.text = "\(Int(sessionTime)) mins"
            cell.amountStepper.value = sessionTime
            cell.amountStepper.tag = 1
            cell.delegate = self
        }else if indexPath.row == 2{
            guard let shortBreak = sessionConfig?["short"] else { return cell}
            cell.titleLabel.text = "Descanso corto"
            cell.amountLabel.text = "\(Int(shortBreak)) mins"
            cell.amountStepper.value = shortBreak
            cell.amountStepper.tag = 2
            cell.delegate = self
        }else if indexPath.row == 3{
            guard let longBreak = sessionConfig?["long"] else { return cell}
            cell.titleLabel.text = "Descanso largo"
            cell.amountLabel.text = "\(Int(longBreak)) mins"
            cell.amountStepper.value = longBreak
            cell.amountStepper.tag = 3
            cell.delegate = self
        }
        
        return cell
    }
}
