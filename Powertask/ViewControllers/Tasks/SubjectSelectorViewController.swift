//
//  SubjectSelectorViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 31/1/22.
//

import UIKit

class SubjectSelectorViewController: UIViewController {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var subjectPicker: UIPickerView!
    
    var subjects: [PTSubject]?
    var subject: PTSubject?
    weak var delegate: SubjectDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.layer.cornerRadius = 30
        subjects = PTUser.shared.subjects
        
        subjectPicker.delegate = self
        subjectPicker.dataSource = self
        
        
        if let subject = subject {
            if let subjectRow = subjects?.firstIndex(where: { subjectFound in
                subjectFound.name == subject.name
            }) {
                subjectPicker.selectRow(subjectRow, inComponent: 0, animated: true)
            }
        } else {
            subjectPicker.selectRow(0, inComponent: 0, animated: true)
            subject = subjects![0]
        }
    }

    @IBAction func okButton(_ sender: Any) {
        if let subject = subject {
            delegate?.subjectWasChosen(subject)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SubjectSelectorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subject = subjects![row]
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(subjects![row].color) ,
        ]
        return NSAttributedString(string: subjects![row].name, attributes: attributes)
    }
}

protocol SubjectDelegate: AnyObject {
    func subjectWasChosen(_ subject: PTSubject)
}
