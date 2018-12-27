//
//  SeedPhraseViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class SeedPhraseViewController: UIViewController {

    @IBOutlet weak var seedLabel: UILabel!
    var mnemonic = "" {
        didSet {
            seedLabel.text = mnemonic
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your seed phrase"
        readMnemonisFromKeyStore()
    }

    fileprivate func readMnemonisFromKeyStore() {
        do {
            let seedPhraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            mnemonic = try seedPhraseItem.readPassword()
        } catch {
            fatalError("Error reading seed phrase from keychain - \(error)")
        }
    }
}
