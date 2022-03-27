//
//  UserTaskTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 18/1/22.
//

import UIKit

protocol TaskCellDoneDelegate: AnyObject {
    func taskDonePushed(_ taskCell: UserTaskTableViewCell, taskDone: Bool?)
}

class UserTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var courseColorImage: UIImageView!
    var taskDoneDelegate: TaskCellDoneDelegate?
    var taskDone: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        courseColorImage.layer.cornerRadius = 2
       // TODO: Tareas con más de una linea
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func setTaskDone(_ sender: Any) {
        if let done = taskDone {
            if done {
                taskDoneDelegate?.taskDonePushed(self, taskDone: false)
                doneButton.setImage(Constants.taskUndoneImage, for: .normal)
                taskDone = false
            } else {
                taskDoneDelegate?.taskDonePushed(self, taskDone: true)
                doneButton.setImage(Constants.taskDoneImage, for: .normal)
                taskDone = true
            }
        }
    }
    
}
