//
//  RootViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/15/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private var current: UIViewController
    
    init() {
        self.current = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Splash") as! SplashViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.current = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Splash") as! SplashViewController
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    func showMainScreen() {
        let mainVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Main") as! MainViewController
        addChild(mainVC)
        mainVC.view.frame = view.bounds
        view.addSubview(mainVC.view)
        mainVC.didMove(toParent: self)
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        
        current = mainVC
    }
    
    func showWelcomeScreen() {
        let welcomeVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
        let new = UINavigationController(rootViewController: welcomeVC)
        addChild(new)
        new.view.frame = view.bounds
        view.addSubview(new.view)
        new.didMove(toParent: self)
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        
        current = new
    }
}
