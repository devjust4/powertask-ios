//
//  PeriodsController.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 2/2/22.
//
import UIKit

class PeriodsController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var periods: [PTPeriod]?
    var deleteindexpath: IndexPath?
    var actualPeriod: [PTPeriod]?
    var previousPeriod: [PTPeriod]?
    var indexPeriod: Int?
    @IBOutlet var periodsTableView: UITableView!
    
    let confirmationAction = UIAlertController(title: "¿Estás seguro? Esta operación es irreversible", message: nil, preferredStyle: .actionSheet)
    override func viewDidLoad() {
        super.viewDidLoad()
        periodsTableView.dataSource = self
        periodsTableView.delegate = self
        
        confirmationAction.addAction(UIAlertAction(title: "Borrar", style: .destructive, handler: { action in
            _ = self.periodsTableView.indexPathForSelectedRow
            self.deleteRow(deleteindexpath: self.deleteindexpath!)
            
        }))
        confirmationAction.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.actualPeriod = self.getActualPeriods(periods: PTUser.shared.periods)
        self.previousPeriod = self.getPastPeriods(periods: PTUser.shared.periods)
        NetworkingProvider.shared.listPeriods { periods in
            PTUser.shared.periods = periods
            PTUser.shared.savePTUser()
            self.actualPeriod = self.getActualPeriods(periods: PTUser.shared.periods)
            self.previousPeriod = self.getPastPeriods(periods: PTUser.shared.periods)
            self.periodsTableView.reloadData()
        } failure: { msg in
            print("ERRRRRROR")
        }
    }
    
    func getActualPeriods(periods: [PTPeriod]?) -> [PTPeriod]? {
        return periods?.filter({ period in DateInterval(start: period.startDate, end: period.endDate).contains(Date.now) })
    }
    
    func getPastPeriods(periods: [PTPeriod]?) -> [PTPeriod]? {
        return periods?.filter({ period in !DateInterval(start: period.startDate, end: period.endDate).contains(Date.now) })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let actualPeriod = actualPeriod {
                return actualPeriod.count
            } else {
                return 0
            }
        }else if section == 1{
            if let previousPeriod = previousPeriod {
                return previousPeriod.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPeriodViewController") as! AddPeriodController
            viewController.period = actualPeriod![indexPath.row]
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }else if indexPath.section == 1{
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPeriodViewController") as! AddPeriodController
            viewController.period = previousPeriod![indexPath.row]
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let period = periods?[indexPath.row]
        indexPeriod = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodsTableViewCell
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodsTableViewCell
            if let name = actualPeriod?[indexPath.row].name{
                cell.periodName.text = name
            }
            return cell
        }
        
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodsTableViewCell
            if let name = previousPeriod?[indexPath.row].name{
                cell.periodName.text = name
            }
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Borrar") { (action, view, completion) in
            self.present(self.confirmationAction, animated: true, completion: nil)
            self.deleteindexpath = indexPath
        }
        delete.backgroundColor =  UIColor.systemRed
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var name = ""
        switch (section){
        case 0:
            name = "Periodos Actuales"
            break
        case 1:
            name = "Otros periodos"
            break
        default:
            name = ""
            break
        }
        return name
    }
    
    func deleteRow (deleteindexpath: IndexPath){
        if let index = PTUser.shared.periods?.firstIndex(where: { period in
            if deleteindexpath.section == 0 {
                return period.id == actualPeriod?[deleteindexpath.row].id
            } else {
                return period.id == previousPeriod?[deleteindexpath.row].id
            }
        }) {
            
            PTUser.shared.savePTUser()
            NetworkingProvider.shared.deletePeriod(period: PTUser.shared.periods![index]) { msg in
                PTUser.shared.periods?.remove(at: index)
                self.actualPeriod =  self.getActualPeriods(periods: PTUser.shared.periods)
                self.previousPeriod =  self.getPastPeriods(periods: PTUser.shared.periods)
                self.periodsTableView.deleteRows(at: [deleteindexpath], with: .left)
            } failure: { msg in
                print("no borrado")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPeriodDetail" {
            let controller = segue.destination as? AddPeriodController
            if sender == nil {
                controller?.isNewPeriod = true
                controller?.userIsEditing = true
                controller?.delegate = self
            } else {
                    controller?.isNewPeriod = false
                    controller?.period = sender as? PTPeriod
                    controller?.delegate = self
            }
        }
    }
    
    @IBAction func newPeriod(_ sender: UIButton) {
        performSegue(withIdentifier: "showPeriodDetail", sender: nil)
    }
    
}

extension PeriodsController: UpdatePeriodList {
    func updateList(){
        self.actualPeriod = self.getActualPeriods(periods: PTUser.shared.periods)
        self.previousPeriod = self.getPastPeriods(periods: PTUser.shared.periods)
        periodsTableView.reloadData()
    }
    
}
