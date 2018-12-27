//
//  MainContract.swift
//  DragonETH
//
//  Created by Alexander Batalov on 10/31/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import Disk

class MainContract {
    
    private static var sharedContract: MainContract = {
        let contract = MainContract()
        return contract
    }()
    private var abi: String?
    
    init() {
        do {
            if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                abi = try String(contentsOfFile: path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    class func shared() -> MainContract {
        return sharedContract
    }
    
    func getMyDragons(completion: @escaping (_ error: String?)->()) {
        guard let abi = abi else {
            completion("Error parsing main contract abi")
            return
        }
        var fmpabi: String?
        do {
            if let path = Bundle.main.path(forResource: "FixMarketPlaceABI", ofType: "txt") {
                fmpabi = try String(contentsOfFile: path)
            }
        } catch {
            print("Error parsing Fix Market Palce ABI", error)
        }
        guard let fixMarketPlaceAbi = fmpabi else {
            completion("Error parsing main fix market place contract abi")
            return
        }
        
        do {
            let owner = WalletManager.shared().currentWallet
            var params: [AnyObject] = [owner] as [AnyObject]
            let requestDragonIdsTX = try TransactionHelper.prepareReadTransactionToContract(parameters: params, contractAbi: abi, contractAddress: ContractAddress.dragonETH, method: "tokensOf")
            let dict = try TransactionHelper.callTxPlasma(transaction: requestDragonIdsTX)
            guard let ids = dict["0"] else {
                completion("Can not parse response \(dict)")
                return
            }
            params = [ids] as [AnyObject]
            let requestDransInfoTX = try TransactionHelper.prepareReadTransactionToContract(parameters: params, contractAbi: fixMarketPlaceAbi, contractAddress: ContractAddress.fixMarketPlace, method: "getFewDragons")
            let result = try TransactionHelper.callTxPlasma(transaction: requestDransInfoTX)
            guard let array = result["0"] as? [AnyObject] else {
                completion("Can not parse response \(result)")
                return
            }
            
            var drgs = [Dragon]()
            for chunk in array.chunked(into: 5) {
                guard let id = chunk[0].description, let stage = Int(chunk[1].description) else { return }
                drgs.append(Dragon(id: id, stage: stage))
            }
            
            // save dragons to local disk in JSON
            try Disk.save(drgs, to: .caches, as: "dragons.json")
            
            completion(nil)
        } catch {
            print("Ooops", error)
            completion(error.localizedDescription)
        }
    }
}
