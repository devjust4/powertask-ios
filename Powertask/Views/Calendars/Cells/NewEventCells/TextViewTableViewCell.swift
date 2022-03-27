//
//  TextViewTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 4/2/22.
//

import UIKit

protocol CellTextViewProtocol: AnyObject {
    func textviewCellEndEditing(_ cell: TextViewTableViewCell, editChangedWithText: String)
}

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextView!
    var delegate: CellTextViewProtocol?
    var noteText: String = "" {
        didSet {
            textField?.text = noteText
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        textField?.delegate = self
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        noteText = textView.text
        self.delegate?.textviewCellEndEditing(self, editChangedWithText: textView.text)
    }
}
