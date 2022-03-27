//
//  CompletedTasksCollectionViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/3/22.
//

import UIKit

class CompletedTasksCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberOfTaskCompletedLabel: UILabel!
    @IBOutlet weak var numberOfTask: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
    }
}
