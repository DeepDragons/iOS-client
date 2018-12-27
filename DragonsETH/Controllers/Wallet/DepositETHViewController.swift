//
//  DepositETHViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class DepositETHViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var walletLabel: UILabel!
    
    let walletManager = WalletManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = walletManager.currentWallet?.image
        walletLabel.text = walletManager.currentWallet?.address
        print(walletManager.currentWallet?.address)
    }
    
    // MARK: - Actions
    
    @IBAction func unwind(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
