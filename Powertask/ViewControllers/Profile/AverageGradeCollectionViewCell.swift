//
//  AverageGradeCollectionViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/3/22.
//

import UIKit

class AverageGradeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var averageGradeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
    }
}
