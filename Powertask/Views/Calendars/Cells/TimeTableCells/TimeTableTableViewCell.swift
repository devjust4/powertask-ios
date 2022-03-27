//
//  TImeTableTableViewCell.swift
//  Powertask
//
//  Created by Daniel Torres on 15/2/22.
//

protocol TimeTableDelegate {
    func deleteBlock(_ cell: TimeTableTableViewCell)
    func addNewBlock(_ cell: TimeTableTableViewCell, newSubject: PTSubject?)
    func changeBlockDate(_ cell: TimeTableTableViewCell, startDate: Date?, endDate: Date?)
    func changeSubject(_ cell: TimeTableTableViewCell, newSubject: PTSubject)
}

import UIKit
import EventKit

class TimeTableTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectDropZone: UIView!
    @IBOutlet weak var subjectNameLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var deleteSubjectButton: UIButton!
    var cellSubject: PTSubject? {
        didSet {
            if let color = cellSubject?.color {
                //self.subjectDropZone.backgroundColor = UIColor(color)
                self.subjectDropZone.layer.borderWidth = 3
                self.subjectDropZone.layer.borderColor = UIColor(color).cgColor
            }
            self.subjectNameLabel.text = cellSubject?.name
            self.deleteSubjectButton.isHidden = false
            self.startDatePicker.isHidden = false
            self.startDateLabel.isHidden = false
            self.endDatePicker.isHidden = false
            self.endDateLabel.isHidden = false
            self.arrowImage.isHidden = false
        }
    }
    
    var startDate: Date? {
        didSet {
            self.endDatePicker.minimumDate = startDate
        }
    }
    var blockEditDelegate: TimeTableDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        let dropInteraction = UIDropInteraction(delegate: self)
        subjectDropZone.addInteraction(dropInteraction)
        subjectDropZone.layer.cornerRadius = 17
        startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: UIControl.Event.editingDidEnd)
        endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker){
        endDatePicker.minimumDate = sender.date
        blockEditDelegate?.changeBlockDate(self, startDate: sender.date, endDate: nil)
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
        blockEditDelegate?.changeBlockDate(self, startDate: nil, endDate: sender.date)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //TODO: esto hace falta? es funcional?
    override func prepareForReuse() {
        cellSubject = nil
        if let subject = cellSubject {
            //self.subjectDropZone.backgroundColor = UIColor(subject.color)
            self.subjectDropZone.layer.borderWidth = 3
            self.subjectDropZone.layer.borderColor = UIColor(subject.color).cgColor
            self.subjectNameLabel.text = subject.name
            setSubjectNil()
        }
    }
    
    @IBAction func deleteSubject(_ sender: Any) {
        blockEditDelegate?.deleteBlock(self)
        setSubjectNil()
    }
    
    func setSubjectNil() {
        subjectNameLabel.text = "Asignatura"
        subjectDropZone.backgroundColor = UIColor.systemGray6
        subjectDropZone.layer.borderWidth = 2
        subjectDropZone.layer.borderColor = UIColor.systemGray4.cgColor
        self.startDatePicker.isHidden = true
        self.startDateLabel.isHidden = true
        self.endDatePicker.isHidden = true
        self.endDateLabel.isHidden = true
        self.arrowImage.isHidden = true
        deleteSubjectButton.isHidden = true
    }
    
    func addBlock(){
        
    }
}

extension TimeTableTableViewCell: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        print("enter")
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: PTSubject.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: PTSubject.self) { subjectDragItem in
            if let subjects = subjectDragItem as? [PTSubject], let subject = subjects.first {
                // TODO: Y si la ha borrado?
                if self.cellSubject == nil {
                    self.blockEditDelegate?.addNewBlock(self, newSubject: subject)
                } else {
                    self.blockEditDelegate?.changeSubject(self, newSubject: subject)
                }
                self.cellSubject = subject
                
            }
        }
    }
}
