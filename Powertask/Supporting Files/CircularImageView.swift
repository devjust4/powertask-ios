//
//  CircularImageView.swift
//  Powertask
//
//  Created by Daniel Torres on 1/3/22.
//

import Foundation
import UIKit

class CircularImageView: UIImageView {
    override func layoutSubviews(){
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
