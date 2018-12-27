//
//  Addresses.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/11/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import EthereumAddress

struct ContractAddress {
    static private var net: ETHNet {
        if let str = UserDefaults.standard.string(forKey: Constants.web3Net) {
            return ETHNet(rawValue: str)!
        }
        return .kovan
    }
    //MARK: TODO - Insert main net address
    static var crowdSale: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0x45e73ad30e0662c7262f913dc5715d03872c3292")!
        case .main:
            return EthereumAddress("0xBf662FB1C4Ab0657bDA2Fbfec620F3a2E0589AbF")!
        }
    }
    static var dragonETH: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0x2050a13468359b78441f3dc3e0035e389ba4b08b")!
        case .main:
            return EthereumAddress("0x34887B4E8Fe85B20ae9012d071412afe702C9409")!
        }
    }
    static var dragonStats: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0x33db6b612c427a13b767273f5138222eca247c7e")!
        case .main:
            return EthereumAddress("0x81f62207eB1E4274feA855943e260091306bE457")!
        }
    }
    static var fixMarketPlace: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0x03d7877d7fd14fb006f3a4c7d319e23afa3437dc")!
        case .main:
            return EthereumAddress("")!
        }
    }
    static var dragonsFightPlace: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0x6b112f193eb54b70fd0b347c5704cfa82b3dae3e")!
        case .main:
            return EthereumAddress("")!
        }
    }
    static var mutagen: EthereumAddress {
        switch net.self {
        case .kovan:
            return EthereumAddress("0xf02fd49f71429e52f76b1bc6907670bd1fd78bcd")!
        case .main:
            return EthereumAddress("")!
        }
    }
}

