//
//  TextFieldTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/2/22.
//

import UIKit

protocol CellTextFieldProtocol: AnyObject {
    func didTextEndEditing(_ cell: TextFieldTableViewCell, editingText: String?)
}

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cell: UIView!
    var delegate: CellTextFieldProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(didEditChanged(_:)), for: .editingChanged)
    }
    
    @objc func didEditChanged(_ sender: UITextField) {
        delegate?.didTextEndEditing(self, editingText: sender.text)
           }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
