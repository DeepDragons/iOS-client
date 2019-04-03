//
//  AddDragonNameViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/20/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Kingfisher
import Web3swift
import MBProgressHUD

class AddDragonNameViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var dragon: Dragon!
    var web3: web3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.setImage(with: dragon.imageURL)
        setupWeb3()
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
        } else {
            let alert = UIAlertController(title: "Error", message: "Ooops! Something went wrong. Please check your internet connection and try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {_ in
                self.setupWeb3()
            }
            alert.addAction(tryAgainAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                var dragonETHContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                    dragonETHContractABI = try String(contentsOfFile: path)
                }
                let contract = web3.contract(dragonETHContractABI, at: ContractAddress.dragonETH, abiVersion: 2)!
                let params = [self.dragon.id as AnyObject, name as AnyObject]
                let estimatedGasResult = try contract.method("addDragonName", parameters: params)?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedGasResult else { return }
                options.gasLimit = .manual(estimatedGas)
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let result = try contract.method("addDragonName", parameters: params)?.send(password: pin)
                print(result.debugDescription)
                DispatchQueue.main.async { [weak self] in
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    self?.dismiss(animated: true, completion: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func tapGestureDidRecognized(_ sender: Any) {
        view.endEditing(true)
    }
}
