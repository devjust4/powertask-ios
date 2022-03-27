//
//  PrivacyPolicyViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    @IBOutlet weak var privacyPolicyTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privacyPolicyTextView.delegate = self
        privacyPolicyTextView.layer.cornerRadius = 20
    }
    
    @IBAction func acceptPolicy(_ sender: Any) {
        if let pageController = self.parent as? OnBoardingViewController {
            pageController.goNext()
        }
    }
    
}

extension PrivacyPolicyViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
            acceptButton.isEnabled = true
        }
    }
}
