//
//  EtherscanEndPoint.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import Web3swift

public enum WalletApi {
    case transactions(address: String, page: Int, offset: Int)
}

extension WalletApi: EndPointType {
    var environmentBaseURL : String {
        switch  NetworkManager.environment {
            case .main: return "https://api.etherscan.io/"
            case .kovan: return "https://api-kovan.etherscan.io/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .transactions: return "api"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .transactions(let address, let page, let offset):
            return .requestParameters(bodyParameters: nil, urlParameters: ["module":"account",
                                                                           "action":"txlist",
                                                                           "address":address,
                                                                           "page":page,
                                                                           "offset":offset,
                                                                           "startblock":0,
                                                                           "endblock":99999999,
                                                                           "sort":"desc",
                                                                           "apikey":AppSecrets.etherscanAPIKey])
        }
    }

    var headers: HTTPHeaders? {
        return nil
    }
}
