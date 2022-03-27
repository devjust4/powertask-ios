//
//  SessionsViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import SwiftUI
class SessionsViewController: UIViewController, transferTasksProtocol{
    func transferTasks(_ view: SesionsTasks, taskTitle: String) {
        selectTask.titleLabel?.text = taskTitle
    }
    

    @IBOutlet weak var selectTask: UIButton!
    @IBOutlet weak var countdownDesactive: UIView!
    @IBOutlet weak var countdownActive: UIView!
    var taskSelected: Bool?
    public var timeSession: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectTask?.layer.cornerRadius = 20
        selectTask?.layer.cornerCurve = .circular
        taskSelected = UserDefaults.standard.value(forKey: "taskSelected") as! Bool
        
        if taskSelected == true{
            defaultTimeRemainingActive = 40
        }
        // Do any additional setup after loading the view.
        
        if taskSelected == true{
            countdownActive.isHidden = false
            countdownDesactive.isHidden = true
        }else{
            countdownActive.isHidden = true
            countdownDesactive.isHidden = false
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConfiguration" {
                let controller = segue.destination as? SessionsConfiguration
            }
        }
    
    
    @IBAction func showConfiguration(_ sender: Any) {
        performSegue(withIdentifier: "showConfiguration", sender: self)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
