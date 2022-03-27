//
//  SeventhStepViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import UIKit

class SeventhStepViewController: UIViewController {
    var dataLoaded: Bool?
    @IBOutlet weak var loadingView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataLoadedNotification = Notification.Name("DataDonwload")
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded(_:)), name: dataLoadedNotification, object: nil)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        // Se mueve a la siguiente pantalla si ya se han cargado los datos, si no muestra una ventana de carga
        if sender.direction == .left {
            if PTUser.shared.subjects != nil {
                if let new = PTUser.shared.new, new {
                    if let pageController = self.parent as? OnBoardingViewController {
                        pageController.goNext()
                    }
                } else {
                    performSegue(withIdentifier: "GoToMain", sender: nil)
                }
            } else {
                loadingView.isHidden = false
            }
        }
    }
    
    // Se lanza cuando los datos ya han sido descargados desde el servidor
    @objc func dataLoaded(_ notification: NSNotification) {
        dataLoaded = true
        if loadingView.isHidden == false {
            if PTUser.shared.new! {
                if let pageController = self.parent as? OnBoardingViewController {
                    pageController.goNext()
                }
            } else {
                performSegue(withIdentifier: "GoToMain", sender: nil)
            }
        }
    }
}
