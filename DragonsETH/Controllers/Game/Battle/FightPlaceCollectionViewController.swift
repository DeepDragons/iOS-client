//
//  FightPlaceCollectionViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/19/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import MBProgressHUD
import BigInt

class FightPlaceCollectionViewController: UICollectionViewController {

    var dragons = [Dragon]()
    var web3: web3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Battle"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FightPlaceCollectionViewController.getDragons), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupWeb3()
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
            getDragons()
        } else {
            let alert = UIAlertController(title: "Error", message: "Ooops! Something went wrong. Please check your internet connection and try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {_ in
                self.setupWeb3()
            }
            alert.addAction(tryAgainAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (dragons.count == 0) {
            collectionView.setEmptyMessage("There is no dragons to fight with :(")
        } else {
            collectionView.restore()
        }
        return dragons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DragonCell", for: indexPath) as! MyDragonsCollectionViewCell
    
        // Configure the cell
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 5).cgPath
    
        cell.dragon = dragons[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = stb.instantiateViewController(withIdentifier: "DragonToFightWith") as? DragonToFightWithViewController {
            vc.opponent = dragons[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func getDragons() {
       let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            
            do {
                let marketplaceAddress = ContractAddress.dragonsFightPlace
                let gasPrice = try web3.eth.getGasPrice()
                var options = Web3Options.defaultOptions()
                options.gasPrice = gasPrice
                options.from = WalletManager.shared().currentWallet
                var abi : String!
                var fixMarketPlaceContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonsFightPlaceABI", ofType: "txt") {
                    abi = try String(contentsOfFile: path)
                }
                if let path = Bundle.main.path(forResource: "FixMarketPlaceABI", ofType: "txt") {
                    fixMarketPlaceContractABI = try String(contentsOfFile: path)
                }
                let contract = web3.contract(abi, at: marketplaceAddress, abiVersion: 2)!
                let dragonResult = try contract.method("getAllDragonsFight", parameters: [])?.call(transactionOptions: nil)
                guard let dragonIds = dragonResult, let ids = dragonIds["0"] as? [BigUInt] else { return }
                
                let marketPlaceContract = web3.contract(fixMarketPlaceContractABI, at: ContractAddress.fixMarketPlace, abiVersion: 2)!
                let arrayResult = try marketPlaceContract.method("getFewDragons", parameters: [ids] as [AnyObject])?.call(transactionOptions: nil)
                guard let array = arrayResult, let arr = array["0"] as? [AnyObject] else { return }
                
                var drgs = [Dragon]()
                for chunk in arr.chunked(into: 5) {
                    guard let id = chunk[0].description, let stage = Int(chunk[1].description) else {
                        return
                    }
                    drgs.append(Dragon(id: id, stage: stage))
                }
                
                DispatchQueue.main.async { [weak self] in
                    hud.hide(animated: true)
                    self?.dragons = drgs
                    self?.collectionView?.reloadData()
                    self?.collectionView?.refreshControl?.endRefreshing()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout methods

extension FightPlaceCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.95, height: 300)
    }
}
