//
//  WalletManager.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress

extension EthereumAddress {
    var image: UIImage {
        let scale = 10.0
        guard let data = self.address.data(using: .utf8, allowLossyConversion: false) else {return UIImage(ciImage: CIImage())}
        let filter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage" : data, "inputCorrectionLevel":"L"])
        guard var image = filter?.outputImage else {return UIImage(ciImage: CIImage())}
        let transformation = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        image = image.transformed(by: transformation)
        return UIImage(ciImage: image)
    }
}

public final class WalletManager {
    
    private static var sharedWalletManager: WalletManager = {
        let walletManager = WalletManager()
        return walletManager
    }()
    
    private var bip32ks: BIP32Keystore!
    public var walletIndex: Int
    public var currentWallet: EthereumAddress? {
        guard let bip32sender = bip32ks?.addresses?[walletIndex] else { return nil }
        return bip32sender
    }
    
    public var wallets: [EthereumAddress]? {
        guard let bip32sender = bip32ks?.addresses else { return nil }
        return bip32sender
        
    }
    
    private init() {
        do {
            // read seed phrase from key store
            let seedPhraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let mnemonicsPhrase = try seedPhraseItem.readPassword()
            
            //create BIP32 keystore
            self.walletIndex = 0
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let bip32keystoreManager = KeystoreManager.managerForPath(userDir + "/bip32_keystore", scanForHDwallets: true)
            if (bip32keystoreManager?.addresses?.count == 0) {
                do {
                    let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                    let pin = try pinItem.readPassword()
                    bip32ks = try! BIP32Keystore.init(mnemonics: mnemonicsPhrase, password: pin, mnemonicsPassword: "", language: .english)
                    let keydata = try! JSONEncoder().encode(bip32ks!.keystoreParams)
                    FileManager.default.createFile(atPath: userDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
                } catch {
                    fatalError("Error reading seed phrase from keychain - \(error)")
                }
            } else {
                bip32ks = (bip32keystoreManager?.walletForAddress((bip32keystoreManager?.addresses![0])!) as! BIP32Keystore)
            }
        } catch {
            fatalError("Error reading seed phrase from keychain - \(error)")
        }
    }
    
    class func shared() -> WalletManager {
        return sharedWalletManager
    }
    
    func generateNewAddress() throws {
        do {
            let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let pin = try pinItem.readPassword()
            try bip32ks.createNewChildAccount(password: pin)
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let keydata = try! JSONEncoder().encode(bip32ks!.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/bip32_keystore"+"/key.json", contents: keydata, attributes: nil)
            
            walletIndex += 1
        } catch {
            throw error
        }
    }
}
