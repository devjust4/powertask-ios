//
//  AllDaySwitchTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 9/3/22.
//

import UIKit

protocol AllDaySwitchChanged {
    func allDaySwitchHasChanged(newAllDayValue: Bool)
}

class AllDaySwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var allDaySwitch: UISwitch!
    var delegate: AllDaySwitchChanged?
    override func awakeFromNib() {
        super.awakeFromNib()
        allDaySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        delegate?.allDaySwitchHasChanged(newAllDayValue: allDaySwitch.isOn)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

