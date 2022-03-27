//
//  OnBoardingViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit

class OnBoardingViewController: UIPageViewController {
    
    private var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard.onboarding
        let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstStep")
        let secondVC = storyboard.instantiateViewController(withIdentifier: "GoogleSignInStep")
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "GoogleClassroomPermissionStep")
        let fourthVC = storyboard.instantiateViewController(withIdentifier: "FourthStep")
        let fifthVC = storyboard.instantiateViewController(withIdentifier: "FifthStep")
        let sixthVC  = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyStep")
        let seventhVC = storyboard.instantiateViewController(withIdentifier: "SeventhStep")
        let eighthVC = storyboard.instantiateViewController(withIdentifier: "FirstPeriodConfig")
        let ninthVC = storyboard.instantiateViewController(withIdentifier: "TimeTableConfig")
        return [firstVC, secondVC, thirdVC, fourthVC, fifthVC, sixthVC, seventhVC, eighthVC, ninthVC]
    }()
    
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([viewControllerList[0]], direction: .forward, animated: false, completion: nil)
    }
    
    
    func goNext() {
        if currentIndex + 1 < viewControllerList.count {
            self.setViewControllers([self.viewControllerList[self.currentIndex + 1]], direction: .forward, animated: true, completion: nil)
            currentIndex += 1
            print(currentIndex)
        }
    }
    
    func goBack() {
        if currentIndex - 1 > 0 {
            self.setViewControllers([self.viewControllerList[self.currentIndex - 1]], direction: .reverse, animated: true)
            currentIndex -= 1
        }
    }
}
