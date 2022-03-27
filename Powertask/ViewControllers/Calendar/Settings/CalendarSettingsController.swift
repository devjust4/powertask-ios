//
//  CalendarSettingsController.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 2/2/22.
//

import UIKit

class CalendarSettingsController: UIViewController{
    
    @IBOutlet weak var SettingsOptions: UISegmentedControl!
    @IBOutlet weak var TimeTableView: UIView!
    @IBOutlet weak var PeriodView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func SegmentedSettings(_ sender: UISegmentedControl) {
        if SettingsOptions.selectedSegmentIndex == 0{
            PeriodView.isHidden = true
            TimeTableView.isHidden = false
        }else if SettingsOptions.selectedSegmentIndex == 1{
            PeriodView.isHidden = false
            TimeTableView.isHidden = true
        }
    }
}
