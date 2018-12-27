//
//  NewWalletViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift

class NewWalletViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var walletLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let wallet = WalletManager.shared().currentWallet {
            walletLabel.text = wallet.address
            imageView.image = wallet.image
        }
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        AppDelegate.shared.rootViewController.showMainScreen()
    }
    
}
