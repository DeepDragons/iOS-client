//
//  EnterRecoveryPhraseViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/7/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift

class EnterRecoveryPhraseViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var stack = [String]() {
        didSet {
            label.text = stack.count == 12 ? "All Set" : "Enter word #\(stack.count + 1)"
            textField.text = nil
            print(stack)
            if stack.count == 12 {
                view.endEditing(true)
            }
        }
    }
    private var bip32ks: BIP32Keystore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Please enter your recovery phrase"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "Next ->" {
            guard let word = textField.text, word != "" else {return}
            let lowercased = word.lowercased()
            let filtered = lowercased.replacingOccurrences(of: " ", with: "")
            stack.append(filtered)
            if stack.count == 12 {
                nextButton.setTitle("Recover", for: .normal)
                textField.isHidden = true
            }
        } else {
            // save seed to keystore
            let mnemonics = stack.joined(separator: " ")
            do {
                let seedPhraaseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                try seedPhraaseItem.savePassword(mnemonics)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            performSegue(withIdentifier: "proceedToSecurity", sender: nil)
        }
    }
}
