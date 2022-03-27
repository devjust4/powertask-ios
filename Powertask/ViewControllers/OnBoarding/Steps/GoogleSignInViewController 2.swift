//
//  GoogleSignInViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit
import GoogleSignIn
import SPIndicator

class GoogleSignInViewController: UIViewController {
    let signInConfig = GIDConfiguration.init(clientID: "399583491262-t0eqglos49o9iau47dker4v27bm2mt0j.apps.googleusercontent.com")
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var signInWithGoogleButton: GIDSignInButton!
    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        signInWithGoogleButton.colorScheme = .light
        signInWithGoogleButton.style = .wide
        pageControl.numberOfPages = 7
        pageControl.currentPage = 1
    }
    
    
    
    
    // MARK: - Navigation
    
    @IBAction func signInWithGoogle(_ sender: Any) {
        if  let networkReacheable = PTNetworkReachability.shared.reachabilityManager?.isReachable, networkReacheable {
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                NetworkingProvider.shared.registerOrLogin { token, new in
                    self.loadingView.isHidden = false
                    PTUser.shared.apiToken = token
                    PTUser.shared.new = new
                    
                    if let pageController = self.parent as? OnBoardingViewController {
                        let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                        let indicatorView = SPIndicatorView(title: "Sesión iniciada correctamente", preset: .custom(image))
                        indicatorView.present(duration: 3, haptic: .success, completion: nil)
                        pageController.goNext()
                    }
                } failure: { error in
                    let image = UIImage.init(systemName: "icloud.slash")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                    let indicatorView = SPIndicatorView(title: "Ha habído un error en el inicio de sesión", preset: .custom(image))
                    indicatorView.present(duration: 3, haptic: .error, completion: nil)
                    return
                }
 
            }
        } else {
            let image = UIImage.init(systemName: "icloud.slash")!.withTintColor(.red, renderingMode: .alwaysOriginal)
            let indicatorView = SPIndicatorView(title: "No tienes conexión a internet", preset: .custom(image))
            indicatorView.present(duration: 3, haptic: .error, completion: nil)
        }
    }
    
}
