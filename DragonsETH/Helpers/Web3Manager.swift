//
//  Web3Manager.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

public enum ETHNet: String {
    case kovan = "kovan"
    case main = "mainnet"
}

final public class Web3Manager {
    
    private static var sharedWeb3Manager: Web3Manager? = {
        if let net = UserDefaults.standard.string(forKey: Constants.web3Net) {
            let network = ETHNet(rawValue: net)!
            return Web3Manager(network)
        } else {
            let web3Manager = Web3Manager(.kovan)
            return web3Manager
        }
    }()
    private var bip32ks: BIP32Keystore!
    public var web3net: web3!
    var web3: web3 {
        return web3net
    }
    
    var gasPrice: BigUInt? {
        get {
            do {
                return try web3net.eth.getGasPrice()
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
    
    init?(_ network: ETHNet) {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let bip32keystoreManager = KeystoreManager.managerForPath(userDir + "/bip32_keystore", scanForHDwallets: true)
        let url = URL(string: "https://\(network.rawValue).infura.io/\(AppSecrets.infuraAPIKey)")!
        
        guard let w3 = Web3.new(url) else { return }
        self.web3net = w3
        self.web3net.addKeystoreManager(bip32keystoreManager)
    }
    
    class func shared() -> Web3Manager? {
        return sharedWeb3Manager
    }
}
