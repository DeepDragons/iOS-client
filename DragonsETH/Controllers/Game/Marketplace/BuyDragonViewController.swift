//
//  BuyDragonViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD
import Kingfisher

class BuyDragonViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    
    var web3: web3?
    var dragon: Dragon!
    var marketPlaceABI: String!
    var dragonPrice: BigUInt? {
        didSet {
            guard let dragonPrice = dragonPrice else { return }
            let amount = dragonPrice.toEth + (dragonPrice.toEth * 50) / 100
            buyButton.setTitle("Buy #\(dragon.id) for \(amount) ETH", for: .normal)
            imageView.kf.setImage(with: dragon.imageURL)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // load contract abi
        do {
            if let path = Bundle.main.path(forResource: "FixMarketPlaceABI", ofType: "txt") {
                marketPlaceABI = try String(contentsOfFile: path)
            }
        } catch {
            fatalError("Error reading abi \(error)")
        }
        
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
            getDragonPrice()
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
    
    func getDragonPrice() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else {
                return
            }
            let marketplaceAddress = ContractAddress.fixMarketPlace
            var options = TransactionOptions.defaultOptions
            options.gasPrice = .automatic
            options.from = WalletManager.shared().currentWallet
            let contract = web3.contract((self.marketPlaceABI)!, at: marketplaceAddress, abiVersion: 2)!
            do {
                let result = try contract.method("dragonPrices", parameters: [self.dragon.id] as [AnyObject])?.call(transactionOptions: nil)
                guard let price = result?["0"] as? BigUInt else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.dragonPrice = price
                }
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    @IBAction func buyDragonButtonTapped(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else {
                return
            }
            guard let price = self.dragonPrice else { return }
            guard let wallet = WalletManager.shared().currentWallet else { return }
            let marketplaceAddress = ContractAddress.fixMarketPlace
            var options = TransactionOptions.defaultOptions
            options.gasPrice = .automatic
            options.from = wallet
            options.value = BigUInt(Double(price) * 1.05)
            let contract = web3.contract((self.marketPlaceABI)!, at: marketplaceAddress, abiVersion: 2)!
            let params = [self.dragon.id] as [AnyObject]
            do {
                let estimatedG = try contract.method("buyDragon", parameters: params)?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedG else { preconditionFailure("estimatedGas is nil") }
                options.gasLimit = .manual(estimatedGas)
            } catch {
                print(error.localizedDescription)
            }
            let intermediateSend = contract.method("buyDragon", parameters: params)!
            do {
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let _ = try intermediateSend.send(password: pin)
                let derivedSender = intermediateSend.transaction.sender
                if (derivedSender?.address != wallet.address) {
                    print(derivedSender?.address ?? "derivedSender empty")
                    print(wallet.address)
                    print("Address mismatch")
                }
//                switch sendResult {
//                case .success(let res):
//                    print("Token transfer successful",res)
//                case .failure(let error):
//                    print(error)
//                }
                DispatchQueue.main.async { [ weak self] in
                    hud.hide(animated: true)
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                fatalError("Can not read PIN")
            }
        }
    }
}

