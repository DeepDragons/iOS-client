//
//  MainViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/15/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0 // Game
        tabBar.items![0].image = UIImage.fontAwesomeIcon(name: .gamepad, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
        tabBar.items![1].image = UIImage.fontAwesomeIcon(name: .userCircle, style: .regular, textColor: .black, size: CGSize(width: 30, height: 30))
        tabBar.items![3].image = UIImage.fontAwesomeIcon(name: .cog, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
    }
}
