//
//  ConciergeViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 28/2/22.
//

import UIKit
import GoogleSignIn

class ConciergeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Controla el inicio de la aplicación.
//        performSegue(withIdentifier: "toMain", sender: nil)
        if LandscapeManager.shared.isFirstLaunch {
            performSegue(withIdentifier: "toOnboarding", sender: nil)
        } else {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user == nil || error != nil {
                    if LandscapeManager.shared.isThereUserData {
                        self.performSegue(withIdentifier: "toMain", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "toMain", sender: nil)
                    }
                } else {
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                }
            }
        }
    }
}

class LandscapeManager {
    static let shared = LandscapeManager()
    // Comprueba si es la primera vez que se inicia la aplicación, a través de un booleano almacenado en UserDefaults
    var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: #function)
        } set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    // Comrpueba si existen datos del usuario guardados en UserDefaults
    var isThereUserData: Bool {
        get {
            let decoder = JSONDecoder()
            if let data = try? UserDefaults.standard.object(forKey: "user") as? Data, let loggedUser = try? decoder.decode(PTUser.self, from: data), let api = loggedUser.apiToken {
                loadUser(userFromDefaults: loggedUser)
                return true
            } else {
                return false
            }
        }
    }
    
    /// Asigna el usuario que se le pasa como parametro al Singleton PTUser.
    ///
    /// - Parameter userFromDefaults: The subject to be welcomed.
    func loadUser(userFromDefaults: PTUser) {
        PTUser.shared.id = userFromDefaults.id
        PTUser.shared.apiToken = userFromDefaults.apiToken
        PTUser.shared.name = userFromDefaults.name
        PTUser.shared.email = userFromDefaults.email
        PTUser.shared.imageUrl = userFromDefaults.imageUrl
        PTUser.shared.subjects = userFromDefaults.subjects
        PTUser.shared.periods = userFromDefaults.periods
        PTUser.shared.blocks = userFromDefaults.blocks
        PTUser.shared.events = userFromDefaults.events
        PTUser.shared.tasks = userFromDefaults.tasks
        PTUser.shared.sessions = userFromDefaults.sessions
    }
}

// Extensión de UIStoryboard para facilitar la instanciación de los Storyboard de las aplicación
extension UIStoryboard {
    static let onboarding = UIStoryboard(name: "OnBoarding", bundle: nil)
    static let main = UIStoryboard(name: "Main", bundle: nil)
}
