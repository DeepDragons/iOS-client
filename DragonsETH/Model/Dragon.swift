//
//  Dragon.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BigInt

struct Dragon: Codable, Hashable {
    var hashValue: Int {
        return Int(id)!
    }
    
    let id: String
    var visualGenom: String?
    var fightingGenom: BigUInt?
    var stage: Int?
    var nextBlockToAction: String?
    var imageURL: URL {
        if let s = self.stage, s == 2 {
            return URL(string: "https://res.cloudinary.com/dragonseth/image/upload/dragon_\(self.id).png")!
        } else {
            return URL(string: "https://res.cloudinary.com/dragonseth/image/upload/egg_\(self.id).png")!
        }
    }
    var fightsWon: Int?
    var fightsLose: Int?
    var numberOfKids: Int?
    var fightsToDeathWon: Int?
    var muagenAppearance: Int?
    var mutagenPerfomance: Int?
    var name: String?
    
    init(id: String) {
        self.id  = id
    }
    
    init(id: String, stage: Int) {
        self.id = id
        self.stage = stage
    }
    
    static func == (lhs: Dragon, rhs: Dragon) -> Bool {
        return lhs.id == rhs.id
    }
}

