//
//  FourthStepViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit

class FourthStepViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
       // let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
       // rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        //view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .left
        {
            if let pageController = parent as? OnBoardingViewController {
                pageController.goNext()
            }
        }
        
        if sender.direction == .right
        {
            if let pageController = parent as? OnBoardingViewController {
                pageController.goBack()
            }
        }
    }
}
