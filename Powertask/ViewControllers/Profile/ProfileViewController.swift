//
//  ProfileViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import SPIndicator

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet var uploadProgress: UIProgressView!
    @IBOutlet weak var editAndSaveButton: UIButton!
    @IBOutlet weak var widgetsCollectionView: UICollectionView!
    var userIsEditing: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveWidgetsData()
        userIsEditing = false
        changeViewWhileEditing(isEditing: userIsEditing!)
        widgetsCollectionView.delegate = self
        widgetsCollectionView.dataSource = self

        if let name = PTUser.shared.name {
            profileNameTextField.text = name
        }
        
        if let imageUrl = PTUser.shared.imageUrl, let url = URL(string: imageUrl) {
            profileImage.load(url: url)
        }
    }
    
    
    
    // MARK: - Navigation
    @IBAction func uploadNewImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @IBAction func editAndSaveProfileInfo(_ sender: Any) {
        if userIsEditing! {
            if profileNameTextField.text == "" {
                let image = UIImage.init(systemName: "multiply.circle")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Falta tu nombre", message: "El nombre es obligatorio", preset: .custom(image))
                indicatorView.present(duration: 5, haptic: .error, completion: nil)
            } else {
                PTUser.shared.name = profileNameTextField.text
                NetworkingProvider.shared.editNameInfo(name: profileNameTextField.text!) { msg in
                    let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Datos guardados", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .success, completion: nil)
                } failure: { msg in
                    print(msg)
                }
                userIsEditing = false
                changeViewWhileEditing(isEditing: userIsEditing!)
            }
        } else {
            userIsEditing = true
            changeViewWhileEditing(isEditing: userIsEditing!)
        }
    }
    // MARK: - Supporting function
    func retrieveWidgetsData() {
        NetworkingProvider.shared.getWidgetData { widgetsInfo in
            PTUser.shared.widgets = widgetsInfo
            self.widgetsCollectionView.reloadData()
        } failure: { error in
            print("error")
        }
    }

    func changeViewWhileEditing (isEditing: Bool) {
        if isEditing {
            profileNameTextField.borderStyle = .roundedRect
            profileNameTextField.isEnabled = true
            editImageButton.isHidden = false
            editAndSaveButton.setTitle("Guardar", for: .normal)
        } else {
            profileNameTextField.borderStyle = .none
            profileNameTextField.isEnabled = false
            editImageButton.isHidden = true
            editAndSaveButton.setTitle("Editar", for: .normal)
        }
    }
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let file = info[.editedImage] as? UIImage
        let url = info[.imageURL] as? URL
            
        if let file = file{
            NetworkingProvider.shared.uploadImage(image: file) { progressQuantity in
                self.uploadProgress.isHidden = false
                self.uploadProgress.progress = Float(progressQuantity)
            } success: { fileUrl in
                self.profileImage.image = file
                PTUser.shared.imageUrl = fileUrl
                self.uploadProgress.isHidden = true
                let image = UIImage.init(systemName: "checkmark.icloud")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Foto subida correctamente", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
            } failure: { error in
                self.uploadProgress.isHidden = true
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width: collectionView.frame.width/2.1, height: collectionView.frame.width/2.1)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let animation = CATransition()
        animation.duration = 0.3
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionTimeCollectionViewCell", for: indexPath) as! SessionTimeCollectionViewCell
            cell.minutesLabel.layer.add(animation, forKey: nil)
            cell.hoursLabel.layer.add(animation, forKey: nil)
            if let sessionTime = PTUser.shared.widgets?.sessionTime {
                cell.hoursLabel.text = "\(sessionTime.hours)h"
                cell.minutesLabel.text = "\(sessionTime.minutes)m"
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DaysUntilPeriodEndsCollectionViewCell", for: indexPath) as! DaysUntilPeriodEndsCollectionViewCell
            cell.dayUntilEndLabel.layer.add(animation, forKey: nil)
            if let daysLeft = PTUser.shared.widgets?.periodDays {
                cell.dayUntilEndLabel.text = "\(daysLeft.days) días"
                cell.daysUntilEndProgress.setProgressWithAnimation(duration: 1.0, fromValue: 0, tovalue: daysLeft.percentage)
            }
                return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompletedTasksCollectionViewCell", for: indexPath) as! CompletedTasksCollectionViewCell
            cell.numberOfTaskCompletedLabel.layer.add(animation, forKey: nil)
            cell.numberOfTask.layer.add(animation, forKey: nil)
            if let tasks = PTUser.shared.widgets?.taskCounter {
                cell.numberOfTaskCompletedLabel.text = String(tasks.completed)
                cell.numberOfTask.text = "de \(tasks.total)"
            }
                return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AverageGradeCollectionViewCell", for: indexPath) as! AverageGradeCollectionViewCell
            cell.averageGradeLabel.layer.add(animation, forKey: nil)
            if let averageMark = PTUser.shared.widgets?.averageMark {
                cell.averageGradeLabel.text = String(averageMark.average)
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
