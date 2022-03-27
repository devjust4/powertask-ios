//
//  DatePickerTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/2/22.
//

import UIKit

protocol CellDatePickerProtocol: AnyObject {
    func didSelectDate(_ cell: DatePickerTableViewCell, dateSelected: Date)
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var label: UILabel!
    var delegate: CellDatePickerProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(didEditChanged(_:)), for: .valueChanged)
    }

    @objc func didEditChanged(_ sender: UIDatePicker) {
        delegate?.didSelectDate(self, dateSelected: sender.date)
           }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
