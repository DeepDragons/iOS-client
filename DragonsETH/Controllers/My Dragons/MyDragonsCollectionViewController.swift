//
//  MyDragonsCollectionViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import MBProgressHUD
import Disk

class MyDragonsCollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "DragonCell"
    var myDragons: [Dragon] {
        do {
            let dragons = try Disk.retrieve("dragons.json", from: .caches, as: [Dragon].self)
            return dragons
        } catch {
            print(error.localizedDescription)
            return [Dragon]()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Dragons"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyDragonsCollectionViewController.getDragons), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        getDragons()
    }
    
    @objc func getDragons() {
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            MainContract.shared().getMyDragons(completion: { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.collectionView?.refreshControl?.endRefreshing()
                        MBProgressHUD.hide(for: self.view, animated: true)

                    }
                } else {
                    // present alert
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if myDragons.isEmpty {
            collectionView.setEmptyMessage("You don't have any dragons yet :(")
        } else {
            collectionView.restore()
        }
        return myDragons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyDragonsCollectionViewCell
        cell.dragon = myDragons[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyDragon") as? MyDragonViewController {
            vc.dragon = myDragons[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

// MARK: UICollectionViewDelegateFlowLayout methods

extension MyDragonsCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.95, height: 300)
    }
}

 
