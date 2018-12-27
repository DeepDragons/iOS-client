//
//  GenerateNewWalletViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/8/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import BigInt
import Web3swift

class GenerateSeedPhraseViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    
    var mnemonicWords = [String]() {
        didSet {
            label1.text = mnemonicWords[0]
            label2.text = mnemonicWords[1]
            label3.text = mnemonicWords[2]
            label4.text = mnemonicWords[3]
            label5.text = mnemonicWords[4]
            label6.text = mnemonicWords[5]
            label7.text = mnemonicWords[6]
            label8.text = mnemonicWords[7]
            label9.text = mnemonicWords[8]
            label10.text = mnemonicWords[9]
            label11.text = mnemonicWords[10]
            label12.text = mnemonicWords[11]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mnemonicWords.isEmpty { generateMnemonic() }
    }
    
    fileprivate func generateMnemonic() {
        //create BIP32 keystore
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let bip32keystoreManager = KeystoreManager.managerForPath(userDir + "/bip32_keystore", scanForHDwallets: true)
        if (bip32keystoreManager?.addresses?.count == 0) {
            // generate new seedphrase
            do {
                let seed = try BIP39.generateMnemonics(bitsOfEntropy: 128)
                mnemonicWords = seed!.split(separator: " ").map { String($0) }
                // save seed to keychain!
                do {
                    let seedPhraaseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                    try seedPhraaseItem.savePassword(seed!)
                } catch {
                    fatalError("Error updating keychain - \(error)")
                }
            } catch {
                print("Something went wrong with entropy.", error)
                return
            }
        } else {
            print("You already have wallet on your device!")
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToGenerateMnemonicVC(segue: UIStoryboardSegue) {}
}
