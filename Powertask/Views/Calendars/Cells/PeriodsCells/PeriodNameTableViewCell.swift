//
//  PeriodNameTableViewCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 7/2/22.
//
import UIKit

protocol PeriodNameTextFieldProtocol: AnyObject {
    func didTextEndEditing(_ cell: NameTableViewCell, editingText: String?)
}

class NameTableViewCell: UITableViewCell{
    
    @IBOutlet weak var setPeriodName: UITextField!
    var delegate: PeriodNameTextFieldProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        setPeriodName.addTarget(self, action: #selector(didEditChanged(_:)), for: .editingChanged)
    }
    
    @objc func didEditChanged(_ sender: UITextField){
        delegate?.didTextEndEditing(self, editingText: sender.text)
    }
}
