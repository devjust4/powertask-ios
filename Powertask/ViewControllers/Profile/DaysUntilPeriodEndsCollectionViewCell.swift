//
//  DaysUntilPeriodEndsCollectionViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/3/22.
//

import UIKit

class DaysUntilPeriodEndsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayUntilEndLabel: UILabel!
    @IBOutlet weak var daysUntilEndProgress: CircularProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
    }
}
