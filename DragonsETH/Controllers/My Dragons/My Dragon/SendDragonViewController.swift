//
//  SendDragonViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import BigInt
import QRCodeReader
import FontAwesome_swift
import MBProgressHUD

class SendDragonViewController: UIViewController {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var scanQRButton: UIButton!
    
    var dragon: Dragon!
    var to: EthereumAddress?
    var web3: web3?
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.setImage(with: dragon.imageURL)
        scanQRButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        scanQRButton.setTitle(String.fontAwesomeIcon(name: .qrcode), for: .normal)
        fromLabel.text = WalletManager.shared().currentWallet?.address
        
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
    
    @IBAction func tapGestureDidRecognized(_ sender: Any) {
        unwind()
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        unwind()
    }
    
    @IBAction func scanQRButtonTapped(_ sender: Any) {
        readerVC.delegate = self
        readerVC.completionBlock = { [weak self] (result: QRCodeReaderResult?) in
            self?.toTextField.text = result?.value
        }
        
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let text = toTextField?.text, isValidETHAddress(text), let toAddress = EthereumAddress(text) else {
            let alert = UIAlertController(title: "Error", message: "Invalid ETH Address. Please try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                let contractAddress = ContractAddress.dragonETH
                let fromAddress = WalletManager.shared().currentWallet
                var abi: String!
                if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                    abi = try String(contentsOfFile: path)
                }
                let gasPrice = try web3.eth.getGasPrice()
                var options = Web3Options.defaultOptions()
                options.gasPrice = gasPrice
                options.from = fromAddress
                let contract = web3.contract(abi, at: contractAddress, abiVersion: 2)!
                let params = [fromAddress!.address as AnyObject, toAddress.address as AnyObject, self.dragon.id] as [AnyObject]
                let estimatedGasResult = try contract.method("transferFrom", parameters: params)?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedGasResult else {return}
                options.gasLimit = estimatedGas
                let intermediateSend = contract.method("transferFrom", parameters: params)!
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let sendResult = try intermediateSend.send(password: pin)
                let derivedSender = intermediateSend.transaction.sender
                if (derivedSender?.address != fromAddress?.address) {
                    print(derivedSender?.address ?? "Can not parse derivaedAddress")
                    print(fromAddress?.address ?? "Can not parse fromAddress")
                    print("Address mismatch")
                }
                print(sendResult.transaction.description)
                
                DispatchQueue.main.async { [weak self] in
                    hud.hide(animated: true)
                    self?.dismiss(animated: true, completion: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func unwind() {
        dismiss(animated: true, completion: nil)
    }
    
    func isValidETHAddress(_ s: String) -> Bool {
        do {
            let regEx = try NSRegularExpression(pattern: "^0x[a-fA-F0-9]{40}$", options: .caseInsensitive)
            let range = NSMakeRange(0, s.count)
            return regEx.matches(in: s, options: [], range: range).count > 0
        } catch {
            print("Error checking RegEx on ETH Address", error)
            return false
        }
    }
}


extension SendDragonViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}


