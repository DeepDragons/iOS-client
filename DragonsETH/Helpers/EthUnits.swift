//
//  EthUnits.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    var toGwei: Double {
        return Double(self) * (pow(Double(10), Double(-9)))
    }
    
    var toEth: Double {
        return Double(self) * (pow(Double(10), Double(-18)))
    }
}

extension Double {
    var gweiToBigUInt: BigUInt {
        return BigUInt(self * (pow(Double(10), Double(9))))
    }
    
    var ethToBigUInt: BigUInt {
        return BigUInt(self * (pow(Double(10), Double(18))))
    }
}

