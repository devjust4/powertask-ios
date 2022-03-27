//
//  ButtonTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/2/22.
//

import UIKit

protocol CellButtonPushedDelegate: AnyObject {
    func cellButtonPushed(_ cell: ButtonTableViewCell)
}

protocol CellButtonSubjectDelegate: AnyObject {
    func subjectSelected(_ subject: PTSubject)
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    var buttonDelegate: CellButtonPushedDelegate?
    var subjectDelegate: CellButtonSubjectDelegate?
    var subject: PTSubject?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func buttonPushed(_ sender: UIButton) {
        buttonDelegate?.cellButtonPushed(self)
    }
}

extension ButtonTableViewCell: SubjectDelegate {
    func subjectWasChosen(_ subject: PTSubject) {
        self.button.setTitle(subject.name, for: .normal)
        self.button.setTitleColor(UIColor(subject.color), for: .normal)
        subjectDelegate?.subjectSelected(subject)
    }
}
