//
//  SendToMarketplaceViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/18/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD
import Kingfisher

class SendToMarketplaceViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceTextField: UITextField!
    
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
    
    @IBAction func sellButoonTapped(_ sender: Any) {
        guard let wallet = WalletManager.shared().currentWallet, let text = priceTextField.text, let price = Double(text) else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else {
                return
            }
            let contractAddress = ContractAddress.dragonETH
            var abi: String!
            do { // load contract abi
                if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                    abi = try String(contentsOfFile: path)
                }
            } catch {
                fatalError("Error reading abi \(error)")
            }
            var gasPriceResult: BigUInt?
            do {
                gasPriceResult = try web3.eth.getGasPrice()
            } catch {
                print(error.localizedDescription)
            }
            var options = TransactionOptions.defaultOptions
            options.gasPrice = .automatic
            options.from = wallet
            let contract = web3.contract(abi, at: contractAddress, abiVersion: 2)!
            let block = (60 * 60 * 24) / 15 // ~1 day
            let params = [self.dragon.id as AnyObject, price.ethToBigUInt as AnyObject, block as AnyObject]
            
            let intermediateSend = contract.method("add2MarketPlace", parameters: params)!
            
            do {
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let _ = try intermediateSend.send(password: pin)
                let derivedSender = intermediateSend.transaction.sender
                if (derivedSender?.address != wallet.address) {
                    print(derivedSender?.address ?? "Can not parse derived address")
                    print(wallet.address)
                    print("Address mismatch")
                }
//                switch sendResult {
//                case .success(let res):
//                    print("Token transfer successful",res)
//                case .failure(let error):
//                    print(error)
//                }
                
                DispatchQueue.main.async { [weak self] in
                    hud.hide(animated: true)
                    self?.dismiss(animated: true, completion: nil)
                }
            } catch {
                fatalError("Can not read PIN")
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        unwind()
    }
    
    @IBAction func tapGesturedRecognized(_ sender: Any) {
        view.endEditing(true)
    }
    
    func unwind() {
        self.dismiss(animated: true, completion: nil)
    }
}
