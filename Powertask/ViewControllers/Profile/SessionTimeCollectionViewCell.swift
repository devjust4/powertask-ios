//
//  CompletedTaskCollectionViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/3/22.
//

import UIKit

class SessionTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
    }
}
