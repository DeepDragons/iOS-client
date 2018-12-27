//
//  SendErrors.swift
//  DragonETH
//
//  Created by Alexander Batalov on 11/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation


enum SendErrors : Error {
    case invalidEtheriumAddress
    case invalidAmountFormat
    case noAvailableKeys
    case invalidContract
    case noInternetConnection
    case wrongPassword
}
