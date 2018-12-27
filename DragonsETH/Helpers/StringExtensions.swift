//
//  StringExtensions.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation

extension String {
    var hexaBytes: [UInt8] {
        var position = startIndex
        return (0..<count/2).compactMap { _ in
            defer { position = index(position, offsetBy: 2) }
            return UInt8(self[position...index(after: position)], radix: 16)
        }
    }
    var hexaData: Data { return hexaBytes.data }
}

