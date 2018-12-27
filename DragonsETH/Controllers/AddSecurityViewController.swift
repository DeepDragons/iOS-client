//
//  AddSecurityViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/12/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import BiometricAuthentication

class AddSecurityViewController: UIViewController {

    @IBOutlet weak var authMetodLabel: UILabel!
    @IBOutlet weak var setupAuthMetodButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPin()
    }
    
    func createPin() {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = stb.instantiateViewController(withIdentifier: "AppLocker") as! AppLockerViewController
        vc.purpose = PassCodePresentingPurpose.createPin
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    
    func setupBiometrics() {
        let idType = BioMetricAuthenticator.shared.defaultAuthenticationMethod
        authMetodLabel.text = "Using \(idType) allows DragonETH app to store your data securely using the Secure Enclave chip"
        setupAuthMetodButton.setTitle("Set Up \(idType)", for: .normal)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        proceed()
    }
    
    @IBAction func showBiometricAuthentication() {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "", fallbackTitle: "Enter PIN", cancelTitle: "Cancel", success: { [weak self] in
            self?.proceed()
        }) { [weak self] (error) in
            switch error {
            case .canceledByUser, .canceledBySystem:
                // do nothing on canceled
                return
            case .fallback:
                // show alternatives on fallback button clicked
                return
            case .biometryNotAvailable:
                // device does not support biometric (face id or touch id) authentication
                return
            case .biometryNotEnrolled:
                // No biometry enrolled in this device, ask user to register fingerprint or face
                self?.showGotoSettingsAlert(message: error.message())
            case .biometryLockedout:
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                self?.createPin()
            default:
                self?.showErrorAlert(message: error.message())
            }
        }
    }
    
    func proceed() {
        UserDefaults.standard.set(true, forKey: Constants.userHasWallet)
        let newWalletVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewWallet") as! NewWalletViewController
        navigationController?.pushViewController(newWalletVC, animated: true)
    }
}

// MARK: - Alerts

extension AddSecurityViewController {
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == "Cancel" { return }
            
            // open settings
            let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        
        let okAction = AlertAction(title: "Ok")
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
}


extension AddSecurityViewController: AppLockerVCDelegate {
    func pinSet() {
        let  method = BioMetricAuthenticator.shared.defaultAuthenticationMethod
        if method == "Touch ID" || method == "Face ID" {
            setupBiometrics()
        } else {
            setupAuthMetodButton.isHidden = true
            setupAuthMetodButton.isEnabled = false
            proceed()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
