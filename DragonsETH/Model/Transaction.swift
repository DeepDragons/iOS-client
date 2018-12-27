//
//  Transaction.swift
//  DragonETH
//
//  Created by Alexander Batalov on 7/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BigInt

public enum DecodingError: String, Error {
    case encodingBigIntFailed = "Error encoding BigInt value"
}

struct TransactionsApiResponse {
    let status: String
    let message: String
    let transactions: [Transaction]
}

extension TransactionsApiResponse: Decodable {
    private enum TransactionsApiResponseCodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case transactions = "result"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionsApiResponseCodingKeys.self)
        
        status = try container.decode(String.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
    }
}

struct Transaction {
    let hash: String
    let timeStamp: String
    let isError: Bool
    let value: BigUInt
}


extension Transaction: Decodable {
    enum TransactionCodingKeys: String, CodingKey {
        case hash
        case timeStamp
        case isError
        case value
    }
    
    init(from decoder: Decoder) throws {
        let transactionContainer = try decoder.container(keyedBy: TransactionCodingKeys.self)
        
        hash = try transactionContainer.decode(String.self, forKey: .hash)
        timeStamp = try transactionContainer.decode(String.self, forKey: .timeStamp)
        let isErrorMessage = try transactionContainer.decode(String.self, forKey: .isError)
        isError = Int(isErrorMessage) != 0
        let strVal = try transactionContainer.decode(String.self, forKey: .value)
        guard let val = BigUInt(strVal) else {
            throw DecodingError.encodingBigIntFailed
        }
        value = val
    }
}





