//
//  VerifyMnemonicsViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/11/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class VerifyMnemonicsViewController: UIViewController {

    @IBOutlet weak var wordNumberLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var mnemonicWords: [String]?
    var stack = [String]() {
        didSet {
            if stack.count == mnemonicWords?.count {
                textField.text = nil
                nextButton.setTitle("Proceed", for: .normal)
                nextButton.removeTarget(self, action: #selector(self.nextButtonTapped), for: .touchUpInside)
                nextButton.addTarget(self, action: #selector(self.segueToNewWalletVC), for: .touchUpInside)
            } else {
                wordNumberLabel.text = "Enter word  #\(stack.count + 1)"
                textField.text = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readMnemonisFromKeyStore()
        let skipButton = UIBarButtonItem(title: "SKIP", style: .plain, target: self, action: #selector(VerifyMnemonicsViewController.skipButtonPressed
            ))
        navigationItem.rightBarButtonItem = skipButton
        nextButton.addTarget(self, action: #selector(self.nextButtonTapped), for: .touchUpInside)
    }
    
    @objc fileprivate func nextButtonTapped() {
        guard let mnemonicWords = mnemonicWords, stack.count < mnemonicWords.count else { return }
        print("nextButtonTapped() ")
        if let text =  textField.text, text == mnemonicWords[stack.count] {
            print("nextButtonTapped() APPEND")
            stack.append(text)
            print(mnemonicWords)
            print(stack)
        } else {
            print("nextButtonTapped() ELSE ")
            // show error message
            let alert = UIAlertController(title: "Error", message: "The word you entered is incorrect. Please make sure you did not made a typo or go back to see your recovery phrase.", preferredStyle: .alert)
            let okAction  = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let backAction = UIAlertAction(title: "Back to recovery phrase", style: .destructive) { (_) in
                self.performSegue(withIdentifier: "unwinToGenerateMnemonics", sender: nil)
            }
            alert.addAction(okAction)
            alert.addAction(backAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func readMnemonisFromKeyStore() {
        do {
            let seedPhraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let phrase = try seedPhraseItem.readPassword()
            mnemonicWords = phrase.split(separator: " ").map { String($0) }
            print(mnemonicWords)
        } catch {
            fatalError("Error reading seed phrase from keychain - \(error)")
        }
    }
    
    // MARK: - Navigation
    
    @objc fileprivate func segueToNewWalletVC() {
        print("Segue to add security vc", stack)
        performSegue(withIdentifier: "addSecurity", sender: nil)
    }
    
    @IBAction func unwindToVerifyMnemonicsVC(segue: UIStoryboardSegue) {}
    
    @objc func skipButtonPressed() {
        segueToNewWalletVC()
    }
    
}
