//
//  AppLockerViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 5/31/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import BiometricAuthentication

protocol AppLockerVCDelegate {
    func pinSet()
}

class AppLockerViewController: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var delegate: AppLockerVCDelegate?
    public var dismissCompletionCallback: (()->Void)?
    public var successCallback: (() -> Void)?
    public var purpose: String!
    public var animateOnDismiss = true
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var tmp = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.tintColor = UIColor.darkText
        passwordContainerView.highlightedColor = .red
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticateUser()
    }
    
    func authenticateUser() {
        passwordContainerView.clearInput()
        if BioMetricAuthenticator.canAuthenticate() && purpose != PassCodePresentingPurpose.createPin {
            let bimetricType = BioMetricAuthenticator.shared.defaultAuthenticationMethod
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "We use \(bimetricType) to unlock your Dragon ETH Wallet", fallbackTitle: "Fallback title", cancelTitle: "Cancel", success: { [weak self] in
                self?.validationSuccess()
            }) { [weak self] (error) in
                print(error)
                self?.validationFail()
            }
        }
    }
    
    fileprivate func setupView() {
        if purpose == PassCodePresentingPurpose.createPin {
            passwordContainerView.tintColor = UIColor.darkText
            passwordContainerView.highlightedColor = .red
            passwordContainerView.touchAuthenticationEnabled = false
            infoLabel.text = "Please create 6 digit pin code"
        } else {
            infoLabel.text = "Please enter your pin"
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AppLockerViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if purpose == PassCodePresentingPurpose.createPin  {
            if tmp == "" {
                tmp = input
                passwordContainerView.clearInput()
                infoLabel.text = "Please confirm pin"
            } else if tmp == input {
                // save pin to keychain!
                do {
                    let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                    try pinItem.savePassword(input)
                    UserDefaults.standard.set(true, forKey: Constants.userHasWallet)
                    validationSuccess()
                } catch {
                    fatalError("Error updating keychain - \(error)")
                }
            } else {
                validationFail()
            }
         return
        }
        
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
    
    internal func dismissPasscodeLock(completionHandler: (() -> Void)? = nil) {
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss, completion: { [weak self]  in
                self?.dismissCompletionCallback?()
                completionHandler?()
                self?.delegate?.pinSet()
            })
            return
            // if pushed in a navigation controller
        } else if navigationController != nil {
            navigationController?.popViewController(animated: animateOnDismiss)
        }
        dismissCompletionCallback?()
        completionHandler?()
    }
}

private extension AppLockerViewController {
    func validation(_ input: String) -> Bool {
        do {
            let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let pin = try pinItem.readPassword()
            return input == pin
        } catch {
            fatalError("Error reading seed phrase from keychain - \(error)")
        }
    }
    
    func validationSuccess() {
        dismissPasscodeLock(completionHandler: { [weak self] in
            self?.successCallback?()
        })
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}



