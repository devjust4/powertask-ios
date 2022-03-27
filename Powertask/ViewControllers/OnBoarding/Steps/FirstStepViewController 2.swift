//
//  FirstStepViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit

class FirstStepViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .left
        {
            if let pageController = parent as? OnBoardingViewController {
                pageController.goNext()
            }
        }
    }
}
