//
//  UICollectionViewExtension.swift
//  DragonETH
//
//  Created by Alexander Batalov on 8/31/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//
import UIKit.UICollectionView


extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
