//
//  FixMarketPlaceContract.swift
//  DragonETH
//
//  Created by Alexander Batalov on 11/12/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BigInt
import Web3swift

class CrowdsaleContract {
    
    private static var sharedContract: CrowdsaleContract = {
        let contract = CrowdsaleContract()
        return contract
    }()
    lazy var web3 = Web3Manager.shared()?.web3
    private var abi: String?
    
    init() {
        do {
            if let path = Bundle.main.path(forResource: "CrowdsaleABI", ofType: "txt") {
                abi = try String(contentsOfFile: path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    class func shared() -> CrowdsaleContract {
        return sharedContract
    }
    
    func getCurrentEggPrice(completion: @escaping (_ error: String?, _ price: BigUInt?) -> () ) {
        guard let abi = abi else {
            completion("Error parsing fix market place contract abi", nil)
            return
        }
        guard let web3 = web3 else {
            completion("Error creting web3. Please check your internet connection", nil)
            return
        }
        do {
            let gasPrice = try web3.eth.getGasPrice()
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = WalletManager.shared().currentWallet
            let contract = web3.contract(abi, at: ContractAddress.crowdSale, abiVersion: 2)!
            let priceResult = try contract.method("crowdSaleDragonPrice", parameters: [])?.call()
            print(priceResult.debugDescription)
            guard let res = priceResult, let price = res["0"] as? BigUInt else { return }
            completion(nil, price)
        } catch {
            completion(error.localizedDescription, nil)
        }
    }
    
    func getPriceIncrementor(completion: @escaping (_ error: String?, _ incrementor: BigUInt?) -> () ) {
        guard let abi = abi else {
            completion("Error parsing fix market place contract abi", nil)
            return
        }
        guard let web3 = web3 else {
            completion("Error creting web3. Please check your internet connection", nil)
            return
        }
        do {
            let gasPrice = try web3.eth.getGasPrice()
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = WalletManager.shared().currentWallet
            let contract = web3.contract(abi, at: ContractAddress.crowdSale, abiVersion: 2)!
            let priceChangerResult = try contract.method("priceChanger", parameters: [])?.call(transactionOptions: nil)
            guard let result = priceChangerResult, let priceChanger = result["0"] as? BigUInt else { return }
            completion(nil, priceChanger)
        } catch {
            completion(error.localizedDescription, nil)
        }
    }
    
    func getAmountOfEggsSold(completion: @escaping (_ error: String?, _ amount: BigUInt?) -> () ) {
        guard let abi = abi else {
            completion("Error parsing fix market place contract abi", nil)
            return
        }
        guard let web3 = web3 else {
            completion("Error creting web3. Please check your internet connection", nil)
            return
        }
        do {
            let gasPrice = try web3.eth.getGasPrice()
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = WalletManager.shared().currentWallet
            let contract = web3.contract(abi, at: ContractAddress.crowdSale, abiVersion: 2)!
            let nunberOfEggsResult = try contract.method("soldDragons", parameters: [])?.call(transactionOptions: nil)
            guard let eggsResult = nunberOfEggsResult, let amount = eggsResult["0"] as? BigUInt else { return }
            completion(nil, amount)
        } catch {
            completion(error.localizedDescription, nil)
        }
    }
    
    func exchangeEtherForEggs(amount ether: BigUInt, completion: @escaping (_ error: String?) -> () ) {
        guard let abi = abi else {
            completion("Error parsing fix market place contract abi")
            return
        }
        guard let web3 = web3 else {
            completion("Error creting web3. Please check your internet connection")
            return
        }
        guard let wallet = WalletManager.shared().currentWallet else {
            completion("User has no wallet set up")
            return
        }
        do {
            let gasPrice = try web3.eth.getGasPrice()
            var options = Web3Options.defaultOptions()
            options.gasPrice = gasPrice
            options.from = wallet
            options.value = ether
            options.to = ContractAddress.crowdSale
            let estimatedGas = try web3.contract(abi, at: ContractAddress.crowdSale)!.method()!.estimateGas(transactionOptions: nil)
            options.gasLimit = estimatedGas
            let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let pin = try pinItem.readPassword()
            let intermediateSend = web3.contract(abi, at: ContractAddress.crowdSale, abiVersion: 2)!.method()!
            let sendResult = try intermediateSend.send(password: pin)
            let derivedSender = intermediateSend.transaction.sender
            if (derivedSender?.address != wallet.address) {
                print(derivedSender?.address ?? "Can not parse derived sender address")
                print(wallet.address)
                print("Address mismatch")
            }
            print(sendResult.transaction.description)
            completion(nil)
        } catch {
            completion(error.localizedDescription)
        }
    }
}
