//
//  ParameterEncoder.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation

public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
