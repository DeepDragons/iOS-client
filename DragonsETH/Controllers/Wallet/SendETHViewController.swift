//
//  SendETHViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/16/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import QRCodeReader
import AVFoundation
import FontAwesome_swift

class SendETHViewController: UIViewController {

    @IBOutlet weak var createPaymentContainer: UIView!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var confirmPaymentContainer: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var scanQRButton: UIButton!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    let walletManager = WalletManager.shared()
    var web3: web3?
    var options = Web3Options.defaultOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletLabel.text = walletManager.currentWallet?.address
        options.from = walletManager.currentWallet
        
        scanQRButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        scanQRButton.setTitle(String.fontAwesomeIcon(name: .qrcode), for: .normal)
        
        // temporary solution
        options.to = EthereumAddress(toTextField.text!)
        options.value = Double(amountTextField.text!)!.ethToBigUInt
        
        setupWeb3()
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
            estimateGas()
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
    
    fileprivate func estimateGas() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
                let gasPrice = try web3.eth.getGasPrice()
                var options = Web3Options.defaultOptions()
                options.gasPrice = gasPrice
                self.options.gasPrice = gasPrice
                let estimatedGasResult = try web3.contract(coldWalletABI, at: self.options.to)!.method()?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedGasResult else {return}
                DispatchQueue.main.async {
                    self.options.gasLimit = estimatedGas
                    self.gasPriceTextField.text = "\(gasPrice.toGwei)"
                    self.gasLimitTextField.text = "\(estimatedGas)"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func showConfirmPaymentView() {
        fromLabel.text = options.from?.address
        toLabel.text = options.to?.address
        valueLabel.text = "\(options.value?.toEth ?? 0)"
        
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmPaymentContainer.isHidden = false
            self.confirmPaymentContainer.alpha = 1
        }) {_ in
            self.createPaymentContainer.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "Proceed" {
            // Ask user to confirm info
            guard let str = amountTextField.text, let val = Double(str) else{ return }
            guard let toAddress = toTextField.text, isValidETHAddress(toAddress) else {
                let alert = UIAlertController(title: "Error", message: "Invalid ETH Address. Please try again", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
            
            options.to = EthereumAddress(toAddress)
            options.value = val.ethToBigUInt
            showConfirmPaymentView()
            sender.setTitle("Confirm", for: .normal)
        } else if sender.titleLabel?.text == "Confirm" {
            // Pay
            DispatchQueue.global().async { [weak self] in
                guard let self = self, let web3 = self.web3 else {
                    return
                }
                let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
                let intermediateSend = web3.contract(coldWalletABI, at: self.options.to, abiVersion: 2)!.method()!
                do {
                    let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                    let pin = try pinItem.readPassword()
                    let sendResultBip32 = try intermediateSend.send(password: pin)
                    print(sendResultBip32.transaction.description)
                    DispatchQueue.main.async {
                        self.unwind(self)
                    }
                } catch {
                    fatalError("Can not read PIN")
                }
            }
        }
    }
    
    @IBAction func scanQRButtonTapped(_ sender: Any) {
        readerVC.delegate = self
        readerVC.completionBlock = { [weak self] (result: QRCodeReaderResult?) in
            print(result?.value ?? "can not read qr code reader result")
            self?.toTextField.text = result?.value
        }
        
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    
    @IBAction func tap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func unwind(_ sender: Any) {
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


extension SendETHViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        reader.dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        reader.dismiss(animated: true, completion: nil)
    }
}
