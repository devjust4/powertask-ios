//
//  SessionsTasksCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 24/3/22.
//

import UIKit
class SessionsTasksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet var taskDate: UILabel!
    @IBOutlet var taskColor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
