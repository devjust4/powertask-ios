//
//  PeriodDateTableViewCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 6/2/22.
//
import UIKit

protocol PeriodDatePickerProtocol: AnyObject{
    func didDateEndEditing(_ cell: DateTableViewCell, editingDate: Date?)
}

class DateTableViewCell: UITableViewCell{
    
    @IBOutlet weak var periodTime: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var delegate: PeriodDatePickerProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(datePickerChanged(_ :)), for: .valueChanged)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker){
        delegate?.didDateEndEditing(self, editingDate: sender.date)
    }
}
