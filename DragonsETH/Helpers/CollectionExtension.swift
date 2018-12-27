//
//  CollectionExtension.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation


extension Collection where Iterator.Element == UInt8 {
    var data: Data {
        return Data(self)
    }
    var hexa: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
