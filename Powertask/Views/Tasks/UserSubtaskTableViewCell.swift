//
//  UserSubtaskTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 1/2/22.
//

import UIKit

// Uso del protocolo: https://stackoverflow.com/questions/51223395/gather-textfield-text-from-a-tableview-cell-swift

protocol SubtaskCellTextDelegate: AnyObject {
    func subtaskCellEndEditing(_ subtaskCell: UserSubtaskTableViewCell, didEndEditingWithText: String?)
}

protocol SubtaskCellDoneDelegate: AnyObject {
    func subtaskDonePushed(_ subtaskCell: UserSubtaskTableViewCell, subtaskDone: Bool?)
}

class UserSubtaskTableViewCell: UITableViewCell {

    @IBOutlet weak var subtaskNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    var subtaskTextDelegate: SubtaskCellTextDelegate?
    var subtaskDoneDelegate: SubtaskCellDoneDelegate?
    var subtaskDone: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subtaskNameTextField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingChanged)
        subtaskNameTextField.borderStyle = .none
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        subtaskTextDelegate?.subtaskCellEndEditing(self, didEndEditingWithText: sender.text)
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func doneButton(_ sender: Any) {
        if let done = subtaskDone {
            if done {
                subtaskDoneDelegate?.subtaskDonePushed(self, subtaskDone: false)
                doneButton.setImage(Constants.subTaskUndoneImage, for: .normal)
                subtaskDone = false
            } else {
                subtaskDoneDelegate?.subtaskDonePushed(self, subtaskDone: true)
                doneButton.setImage(Constants.subTaskDoneImage, for: .normal)
                subtaskDone = true
            }
        }
    }
}
