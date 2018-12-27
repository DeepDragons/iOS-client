//
//  MarketPlaceCollectionViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD

private let reuseIdentifier = "DragonCell"

class MarketPlaceCollectionViewController: UICollectionViewController {
    
    var dragons = [(dragon: Dragon, price: Double)]()
    var web3: web3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Marketplace"
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MarketPlaceCollectionViewController.getDragonsForSale), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        // Do any additional setup after loading the view.
        
        setupWeb3()
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
            getDragonsForSale()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getDragonsForSale() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                var marketPlaceABI: String!
                if let path = Bundle.main.path(forResource: "FixMarketPlaceABI", ofType: "txt") {
                    marketPlaceABI = try String(contentsOfFile: path)
                }
                let marketplaceAddress = ContractAddress.fixMarketPlace
                let gasPrice = try web3.eth.getGasPrice()
                var options = Web3Options.defaultOptions()
                options.gasPrice = gasPrice
                options.from = WalletManager.shared().currentWallet
                let contract = web3.contract(marketPlaceABI, at: marketplaceAddress, abiVersion: 2)!
                let dragonIds = try contract.method("getDragonsToSale", parameters: [])?.call(transactionOptions: nil)
                guard let ids = dragonIds?["0"] as? [BigUInt] else { return }
                guard let array = try contract.method("getFewDragons", parameters: [ids] as [AnyObject])?.call(transactionOptions: nil) else { return }
                guard let arr = array["0"] as? [AnyObject] else { return }
                var drgs = [(dragon: Dragon, price: Double)]()
                
                for chunk in arr.chunked(into: 5) {
                    guard let id = chunk[0].description, let stage = Int(chunk[1].description), let price = BigUInt(chunk[3].description) else { return }
                    if id != "0" {
                        let dragon = Dragon(id: id, stage: stage)
                        let p = price.toEth + (price.toEth * 50) / 100
                        drgs.append((dragon: dragon, price: p))
                    }
                }
                
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.dragons = drgs
                    self.collectionView?.reloadData()
                    self.collectionView?.refreshControl?.endRefreshing()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (dragons.count == 0) {
            collectionView.setEmptyMessage("There's no dragons on the market :(")
        } else {
            collectionView.restore()
        }
        return dragons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyDragonsCollectionViewCell
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
        
        cell.dragon = dragons[indexPath.row].dragon
        cell.priceLabel.text = "\(dragons[indexPath.row].price) ETH"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = stb.instantiateViewController(withIdentifier: "BuyFromMarketplace") as? BuyDragonViewController {
            vc.dragon = dragons[indexPath.row].dragon
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}


extension MarketPlaceCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.95, height: 300)
    }
}
