//
//  SessionsConfigurationCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 23/3/22.
//

import UIKit

protocol SessionStepperProtocol: AnyObject{
    func stepperTimeChanged(_ cell: SessionsConfigurationTableViewCell, sessionTime: Double?)
}
class SessionsConfigurationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleConfiguration: UILabel!
    @IBOutlet weak var selectAmount: UIStepper!
    @IBOutlet weak var showAmount: UILabel!
    var delegate: SessionStepperProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
       // TODO: Tareas con más de una linea
        selectAmount.addTarget(self, action: #selector(didTimeChanged(_ :)), for: .valueChanged)
    }
    
    @objc func didTimeChanged(_ sender: UIStepper){
        delegate?.stepperTimeChanged(self, sessionTime: sender.value)
    }
}
