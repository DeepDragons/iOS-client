//
//  SplashViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 10/30/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: Constants.userHasWallet) {
            AppDelegate.shared.rootViewController.showMainScreen()
        } else {
            AppDelegate.shared.rootViewController.showWelcomeScreen()
        }
    }
}
