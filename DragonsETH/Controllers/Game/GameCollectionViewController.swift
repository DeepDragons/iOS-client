//
//  GameCollectionViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GameActionCell"

class GameCollectionViewController: UICollectionViewController {
    
    let features = ["Buy egg", "Marketplace","Battle"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dragon ETH"
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GameActionCollectionViewCell
        cell.featureLabel.text = features[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        switch indexPath.row {
        case 0:
            let vc = stb.instantiateViewController(withIdentifier: "BuyEgg") as! BuyEggViewController
            navigationController?.pushViewController(vc, animated: true)
            return
        case 1:
            let vc = stb.instantiateViewController(withIdentifier: "Marketplace") as! MarketPlaceCollectionViewController
            navigationController?.pushViewController(vc, animated: true)
            return
        case 2:
            let vc = stb.instantiateViewController(withIdentifier: "Fightplace") as! FightPlaceCollectionViewController
            navigationController?.pushViewController(vc, animated: true)
            return
        default:
            return
        }
        
    }

}

// MARK: UICollectionViewDelegateFlowLayout methods

extension GameCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.95, height: 300)
    }
}



