//
//  PasscodeLockPresenter.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/7/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

public class PasswordLockPresenter {
    
    private var mainWindow: UIWindow?

    private lazy var passwordLockWindow: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.makeKeyAndVisible()
        
        return window
    }()
    
    public var isPasscodePresented = false
    let passcodeLockVC: AppLockerViewController
    
    init(mainWindow window: UIWindow?, viewController: AppLockerViewController) {
        
        mainWindow = window
        mainWindow?.windowLevel = UIWindow.Level(rawValue: 1)
        passcodeLockVC = viewController
    }
    
    public func presentPasscodeLock() {
        guard UserDefaults.standard.bool(forKey: Constants.userHasWallet) else { return }
        guard !isPasscodePresented else { return }
        
        isPasscodePresented = true
        
        passwordLockWindow.windowLevel = UIWindow.Level(rawValue: 2)
        passwordLockWindow.isHidden = false
        
        mainWindow?.windowLevel = UIWindow.Level(rawValue: 1)
        mainWindow?.endEditing(true)
        
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = stb.instantiateViewController(withIdentifier: "AppLocker") as? AppLockerViewController else { return }
        let userDismissCompletionCallback = vc.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [weak self] in
            
            userDismissCompletionCallback?()
            
            self?.dismissPasscodeLock()
        }
        
        passwordLockWindow.rootViewController = passcodeLockVC
    }
    
    public func dismissPasscodeLock(_ animated: Bool = true) {
        isPasscodePresented = false
        mainWindow?.windowLevel = UIWindow.Level(rawValue: 1)
        mainWindow?.makeKeyAndVisible()
        
        if animated {
            
            animatePasscodeLockDismissal()
            
        } else {
            
            passwordLockWindow.windowLevel = UIWindow.Level(rawValue: 0)
            passwordLockWindow.rootViewController = nil
        }
    }
    
    internal func animatePasscodeLockDismissal() {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                
                self?.passwordLockWindow.alpha = 0
            },
            completion: { [weak self] _ in
                
                self?.passwordLockWindow.windowLevel = UIWindow.Level(rawValue: 0)
                self?.passwordLockWindow.rootViewController = nil
                self?.passwordLockWindow.alpha = 1
            }
        )
    }
}
