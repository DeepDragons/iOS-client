//
//  GameActionCollectionViewCell.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class GameActionCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var featureLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
    }
}
