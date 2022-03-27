//
//  SessionsCountDown.swift
//  Powertask
//
//  Created by Andrea Martinez Bartolome on 21/3/22.
//

import UIKit
import SwiftUI
class SessionsCountDown: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentSwiftUIView()
        // Do any additional setup after loading the view.
    }
    
    func presentSwiftUIView() {
        let contenView = ContentView()
        let hostingController = UIHostingController(rootView: contenView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
    }
}
