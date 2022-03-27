//
//  SubjectCell.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 6/2/22.
//  Eddited by Daniel Torres on 15/2/22.
//
protocol ColorButtonPushedProtocol {
    func instanceColorPicker(_ cell: SubjectTableViewCell)
    func colorPicked(_ cell: SubjectTableViewCell, color: String)
}

protocol SubjectSelectedDelegate {
    func markSubjectSelected(_ cell: SubjectTableViewCell, selected: Bool)
}

protocol PeriodSubjectTextViewProtocol: AnyObject{
    func didTextEndEditing(_ cell: SubjectTableViewCell, editingText: String?)
}

import UIKit
class SubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var subjectName: UITextField!
    @IBOutlet weak var checkSubject: UIButton!
    @IBOutlet weak var subjectColor: UIButton!
    var subjectColorDelegate: ColorButtonPushedProtocol?
    var selectedSubjectDelegate: SubjectSelectedDelegate?
    var delegate: PeriodSubjectTextViewProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subjectColor.layer.cornerRadius = 8
        subjectName?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func selectColor(_ sender: Any) {
        subjectColorDelegate?.instanceColorPicker(self)
    }
    
    @IBAction func checkSubject(_ sender: UIButton) {
        if checkSubject.image(for: .normal) == UIImage(systemName: "checkmark"){
            checkSubject.setImage(UIImage(systemName: "xmark"), for: .normal)
            checkSubject.tintColor = UIColor.red
            selectedSubjectDelegate?.markSubjectSelected(self, selected: false)
            subjectName.isEnabled = false
            subjectName.alpha = 0.5
            subjectColor.isEnabled = false
            subjectColor.alpha = 0.5
        }else {
            checkSubject.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkSubject.tintColor = UIColor(named: "AccentColor")
            selectedSubjectDelegate?.markSubjectSelected(self, selected: true)
            subjectName.isEnabled = true
            subjectName.alpha = 1
            subjectColor.isEnabled = true
            subjectColor.alpha = 1
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.didTextEndEditing(self, editingText: textField.text)
    }
}

extension SubjectTableViewCell: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        subjectColor.backgroundColor = color
        print(viewController.description)
        print(viewController.description[30..<40])
        subjectColorDelegate?.colorPicked(self, color: color.toHexString())
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
