//
//  TransactionHelper.swift
//  DragonETH
//
//  Created by Alexander Batalov on 11/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BigInt
import Web3swift
import EthereumAddress

final public class TransactionHelper {
    
    static func prepareTransactionForSendingEther(destinationAddressString: String, amountString: String, gasLimit: BigUInt) throws -> WriteTransaction {
        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {throw SendErrors.invalidEtheriumAddress}
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
        guard let web3 = Web3Manager.shared()?.web3 else { throw SendErrors.noInternetConnection }
        guard let ethAddressFrom = WalletManager.shared().currentWallet else {throw SendErrors.noAvailableKeys}
        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress, abiVersion: 2) else {throw SendErrors.invalidEtheriumAddress}
        guard let writeTX = contract.write("fallback") else {throw SendErrors.invalidContract}
        writeTX.transactionOptions.from = ethAddressFrom
        writeTX.transactionOptions.value = amount
        return writeTX
    }
    
    static func prepareTransactionForSendingERC(contractAddressString: String, amountString: String, gasLimit: BigUInt, tokenAddress token: String) throws -> WriteTransaction {
        guard let contractAddress = EthereumAddress(contractAddressString) else {throw SendErrors.invalidEtheriumAddress}
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
        guard let web3 = Web3Manager.shared()?.web3 else { throw SendErrors.noInternetConnection }
        guard let ethAddressFrom = WalletManager.shared().currentWallet else {throw SendErrors.noAvailableKeys}
        guard let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2) else {throw SendErrors.invalidEtheriumAddress}
        guard let writeTX = contract.write("transfer") else {throw SendErrors.invalidContract}
        writeTX.transactionOptions.from = ethAddressFrom
        writeTX.transactionOptions.value = amount
        return writeTX
    }
    
    static func prepareWriteTransactionToContract(parameters: [AnyObject],
                                      data: Data = Data(),
                                      amountString: String,
                                      contractAbi: String,
                                      contractAddress: EthereumAddress,
                                      method: String,
                                      predefinedOptions: TransactionOptions? = nil) throws -> WriteTransaction {
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
        guard let web3 = Web3Manager.shared()?.web3 else { throw SendErrors.noInternetConnection }
        guard let ethAddressFrom = WalletManager.shared().currentWallet else {throw SendErrors.noAvailableKeys}
        guard let contract = web3.contract(contractAbi, at: contractAddress, abiVersion: 2) else {throw SendErrors.invalidEtheriumAddress}
        guard let writeTX = contract.write(method,
                                           parameters: parameters,
                                           extraData: data,
                                           transactionOptions: predefinedOptions) else {throw SendErrors.invalidContract}
        writeTX.transactionOptions.from = ethAddressFrom
        writeTX.transactionOptions.value = amount
        return writeTX
    }
    
    static func prepareReadTransactionToContract(parameters: [AnyObject],
                                                  data: Data = Data(),
                                                  contractAbi: String,
                                                  contractAddress: EthereumAddress,
                                                  method: String,
                                                  predefinedOptions: TransactionOptions? = nil) throws -> ReadTransaction {
        guard let web3 = Web3Manager.shared()?.web3 else { throw SendErrors.noInternetConnection }
        guard let contract = web3.contract(contractAbi, at: contractAddress, abiVersion: 2) else {throw SendErrors.invalidEtheriumAddress}
        contract.transactionOptions = predefinedOptions
        guard let readTX = contract.read(method,
                                           parameters: parameters,
                                           extraData: data,
                                           transactionOptions: predefinedOptions) else {throw SendErrors.invalidContract}
        return readTX
    }
    
    static func writeTx(transaction: WriteTransaction, options: TransactionOptions? = nil, password: String? = nil) throws -> TransactionSendingResult {
        let options = options ?? transaction.transactionOptions
        guard let result = password == nil ?
            try? transaction.send() :
            try? transaction.send(password: password!, transactionOptions: options) else {throw SendErrors.wrongPassword}
        return result
    }
    
    static func callTxPlasma(transaction: ReadTransaction, options: TransactionOptions? = nil) throws -> [String: Any] {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.call(transactionOptions: options) else {throw SendErrors.wrongPassword}
        return result
    }
}
