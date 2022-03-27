//
//  SessionsConfiguration.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 23/3/22.
//

import UIKit
import Alamofire
class SessionsConfiguration: UIViewController, UITableViewDataSource, UITableViewDelegate, SessionStepperProtocol{

    @IBOutlet weak var tableView: UITableView!
    var amountFirst: Double?
    var amountSecond: Double?
    var amountThird: Double?
    var amountFourth: Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func stepperTimeChanged(_ cell: SessionsConfigurationTableViewCell, sessionTime: Double?) {
        let indexPath = tableView.indexPath(for: cell)
        if let index = indexPath?.row{
            if index == 0{
                amountFirst = sessionTime
            }else if index == 1{
                amountSecond = sessionTime
            }else if index == 2{
                amountThird = sessionTime
            }else if index == 3{
                amountFourth = sessionTime
            }
        }
        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var name = ""
        switch (section){
        case 0:
            name = "Sesiones"
            break
        default:
            name = ""
            break
        }
        
        return name
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configurationCell", for: indexPath) as! SessionsConfigurationTableViewCell
        
        if indexPath.row == 0{
            cell.titleConfiguration.text = "Tiempo de sesion"
            cell.showAmount.text = "\(String(describing: amountFirst))"
            cell.delegate = self
            return cell
        }else if indexPath.row == 1{
            cell.titleConfiguration.text = "Numero de sesiones"
            cell.showAmount.text = (String(describing: amountSecond))
            cell.delegate = self
            return cell
        }else if indexPath.row == 2{
            cell.titleConfiguration.text = "Descanso corto"
            cell.showAmount.text = (String(describing: amountThird))
            cell.delegate = self
            return cell
        }else if indexPath.row == 3{
            cell.titleConfiguration.text = "Descanso largo"
            cell.showAmount.text = (String(describing: amountFourth))
            cell.delegate = self
            return cell
        }
        
        return cell
        
    }
}
