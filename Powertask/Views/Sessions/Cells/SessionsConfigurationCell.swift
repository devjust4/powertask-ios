//
//  SessionsConfigurationCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 23/3/22.
//

import UIKit

protocol SessionStepperProtocol: AnyObject{
    func stepperTimeChanged(_ cell: SessionsConfigurationTableViewCell, data: Double, stepperTag: Int)
}
class SessionsConfigurationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountStepper: UIStepper!
    @IBOutlet weak var amountLabel: UILabel!
    var delegate: SessionStepperProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
       // TODO: Tareas con más de una linea
        amountStepper.addTarget(self, action: #selector(didQuantityChanged(_ :)), for: .valueChanged)
    }
    
    override func prepareForReuse() {
        amountStepper.value = 0
    }
    
    @objc func didQuantityChanged(_ sender: UIStepper){
        delegate?.stepperTimeChanged(self, data: sender.value, stepperTag: sender.tag)
    }
}
