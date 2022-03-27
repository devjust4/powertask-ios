//
//  EventTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 7/2/22.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventInfo: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventColor: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //eventColor.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        eventColor.backgroundColor = UIColor.clear
    }

}
