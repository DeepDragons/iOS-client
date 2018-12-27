//
//  MyDragonsCollectionViewCell.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Kingfisher

class MyDragonsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var dragon: Dragon! {
        didSet {
            imageView.kf.setImage(with: dragon.imageURL)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.backgroundColor = .white
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
