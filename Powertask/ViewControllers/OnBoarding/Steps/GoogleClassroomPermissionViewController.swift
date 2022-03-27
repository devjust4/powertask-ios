//
//  GoogleClassroomPermissionViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 5/3/22.
//

import UIKit
import GoogleSignIn
import SPIndicator

// Spopes de Google Classroom necesarios para solicitar los datos desde el servidor
let scopes = ["https://www.googleapis.com/auth/classroom.courses",
              "https://www.googleapis.com/auth/classroom.courses.readonly",
              "https://www.googleapis.com/auth/classroom.course-work.readonly",
              "https://www.googleapis.com/auth/classroom.student-submissions.me.readonly",
              "https://www.googleapis.com/auth/userinfo.email",
              "https://www.googleapis.com/auth/userinfo.profile"]
class GoogleClassroomPermissionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    /// Comprueba que el usuario tenga conexión, después comrpueba los permisos de Google y si el usuario no ha aprobado a la aplicación, muestra la pantalla para que la autorice
    @IBAction func authorize(_ sender: Any) {
        if  let networkReacheable = PTNetworkReachability.shared.reachabilityManager?.isReachable, networkReacheable {
            requestScopes(scopes: scopes) {
                NetworkingProvider.shared.initialDownload { user in
                    PTUser.shared.subjects = user.subjects
                    PTUser.shared.periods = user.periods
                    PTUser.shared.apiToken = user.apiToken
                    let dataLoadedNotification = Notification.Name("DataDonwload")
                    NotificationCenter.default.post(name: dataLoadedNotification, object: nil, userInfo: nil)
                    PTUser.shared.id = user.id
                    PTUser.shared.name = user.name
                    PTUser.shared.email = user.email
                    PTUser.shared.imageUrl = user.imageUrl
                    PTUser.shared.tasks = user.tasks
                    PTUser.shared.sessions = user.sessions
                    PTUser.shared.events = user.events
                    PTUser.shared.savePTUser()
                    LandscapeManager.shared.isFirstLaunch = true
                } failure: { error in
                    print("error en la descarga incial")
                }
                let image = UIImage.init(systemName: "checkmark.circle")!.withTintColor(UIColor(named: "AccentColor")!, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "Permisos concedidos", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .success, completion: nil)
                
                if let pageController = self.parent as? OnBoardingViewController {
                    pageController.goNext()
                }
            } failure: {
                let image = UIImage.init(systemName: "icloud.slash")!.withTintColor(.red, renderingMode: .alwaysOriginal)
                let indicatorView = SPIndicatorView(title: "No has autorizado a PowerTask", preset: .custom(image))
                indicatorView.present(duration: 3, haptic: .error, completion: nil)
            }
        } else {
            let image = UIImage.init(systemName: "icloud.slash")!.withTintColor(.red, renderingMode: .alwaysOriginal)
            let indicatorView = SPIndicatorView(title: "No tienes conexión a internet", preset: .custom(image))
            indicatorView.present(duration: 3, haptic: .error, completion: nil)
        }
    }
    
    /// Presenta la pantalla de solictud de Scopes de Google
    ///
    /// - Parameters: Un array de strings con cada scope de Google solicitado
    func requestScopes(scopes: [String], success: @escaping ()->(), failure: @escaping ()->()) {
        GIDSignIn.sharedInstance.addScopes(scopes, presenting: self) { user, error in
            guard error == nil else {
                success()
                return }
            guard let user = user else {
                failure()
                return }
            let grantedScopes = user.grantedScopes
            if grantedScopes == nil || !grantedScopes!.contains("https://www.googleapis.com/auth/classroom.courses") {
                failure()
            } else {
                success()
            }
        }
    }
}
