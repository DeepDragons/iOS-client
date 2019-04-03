//
//  DragonToFightWithViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/19/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD
import ScalingCarousel
import Charts
import Disk

class DragonToFightWithViewController: UIViewController {
    
    @IBOutlet weak var fightButton: UIButton!
    @IBOutlet weak var opponentImageView: UIImageView!
    @IBOutlet weak var opponentChartView: RadarChartView!
    @IBOutlet weak var myDragonImageView: UIImageView!
    @IBOutlet weak var myDragonChartView: RadarChartView!
    @IBOutlet weak var carouselView: ScalingCarouselView!
    
    var web3: web3?
    var opponent: Dragon!
    var myDragons: [Dragon] {
        do {
            let dragons = try Disk.retrieve("dragons.json", from: .caches, as: [Dragon].self)
            return dragons.filter {
                guard let s = $0.stage else {return false}
                return s >= 2 && $0.id != opponent.id 
            }
        } catch {
            return [Dragon]()
        }
    }
    var myDragonsIndex: Int = 0 {
        didSet {
            if myDragons.isEmpty { return }
            myDragon = myDragons[myDragonsIndex]
            getDragonInfo(myDragon!.id)
        }
    }
    var myDragon: Dragon? {
        didSet {
            guard let myDragon = myDragon else { return }
            myDragonImageView.kf.setImage(with: myDragon.imageURL)
        }
    }
    var priceToFight: BigUInt? {
        didSet {
            guard let price = priceToFight else {
                return
            }
            let txt = "Fight for \(price.toEth) ETH"
            fightButton.setTitle(txt, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opponentImageView.kf.setImage(with: opponent.imageURL)
        myDragonsIndex = 0 
        
        opponentChartView.xAxis.drawLabelsEnabled = false
        opponentChartView.yAxis.drawLabelsEnabled = false
        opponentChartView.chartDescription?.text = ""
        
        myDragonChartView.xAxis.drawLabelsEnabled = false
        myDragonChartView.yAxis.drawLabelsEnabled = false
        myDragonChartView.chartDescription?.text = ""
        opponentImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        if myDragons.isEmpty {
            let alert = UIAlertController(title: "No fighters!", message: "You dont have any dragons who can fight just yet. Please reveal one of your eggs or buy.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel) {_ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        setupWeb3()
        myDragonsIndex = 0
    }
    
    private func setupWeb3() {
        if let manager =  Web3Manager.shared() {
            web3 = manager.web3
            getPriceToFight()
            getDragonInfo(opponent.id)
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
    
    func getDragonInfo(_ id: String) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                var dragonETHContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                    dragonETHContractABI = try String(contentsOfFile: path)
                }
                let contract = web3.contract(dragonETHContractABI, at: ContractAddress.dragonETH, abiVersion: 2)!
                let result = try contract.method("dragons", parameters: [id as AnyObject])?.call(transactionOptions: nil)
                guard let res = result, let fight = res["3"] as? BigUInt else { return }
                DispatchQueue.main.async {
                    if id == self.opponent.id {
                        self.opponent.fightingGenom = fight
                        self.setChartForDragon(self.opponent)
                    } else {
                        self.myDragon?.fightingGenom = fight
                        self.setChartForDragon(self.myDragon)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getPriceToFight() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                let marketplaceAddress = ContractAddress.dragonsFightPlace
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                var abi : String!
                if let path = Bundle.main.path(forResource: "DragonsFightPlaceABI", ofType: "txt") {
                    abi = try String(contentsOfFile: path)
                }
                let contract = web3.contract(abi, at: marketplaceAddress, abiVersion: 2)!
                let result = try contract.method("priceToFight", parameters: [])?.call(transactionOptions: nil)
                guard let p = result, let price = p["0"] as? BigUInt else { return }
                DispatchQueue.main.async {
                    self.priceToFight = price
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getMyDragons() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                var dragonETHContractABI: String!
                var fixMarketPlaceContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonETHContractABI", ofType: "txt") {
                    dragonETHContractABI = try String(contentsOfFile: path)
                }
                if let path = Bundle.main.path(forResource: "FixMarketPlaceABI", ofType: "txt") {
                    fixMarketPlaceContractABI = try String(contentsOfFile: path)
                }
                let contract = web3.contract(dragonETHContractABI, at: ContractAddress.dragonETH, abiVersion: 2)!
                let dragonResult = try contract.method("tokensOf", parameters: [WalletManager.shared().currentWallet] as [AnyObject])?.call(transactionOptions: nil)
                guard let dragonIds = dragonResult, let ids = dragonIds["0"] as? [AnyObject] else { return }
                
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
                try Disk.save(drgs, to: .caches, as: "dragons.json")
                DispatchQueue.main.async {
                    self.carouselView.reloadData()
                    self.myDragonsIndex = 0
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setChartForDragon(_ dragon: Dragon?) {
        guard let dragon = dragon else { return }
        guard let fightingGenom = dragon.fightingGenom else {return}
        let str = String(fightingGenom, radix: 16, uppercase: false)
        let bytes = str.hexaBytes
        let atackGens = bytes[0..<bytes.count/2].map { RadarChartDataEntry(value: Double($0)) }
        let defenceGens = bytes[bytes.count/2..<bytes.count].map { RadarChartDataEntry(value: Double($0)) }
        
        let set1 = RadarChartDataSet(values: atackGens, label: "Atack")
        set1.setColor(UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1))
        set1.fillColor = UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let set2 = RadarChartDataSet(values: defenceGens, label: "Defence")
        set2.setColor(UIColor.orange)
        set2.fillColor = UIColor.orange
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 2
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(false)
        
        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 8, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        
        if dragon.id == opponent.id {
            opponentChartView.data = data
            opponentChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        } else {
            myDragonChartView.data = data
            myDragonChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        }
    }
    
    @IBAction func fightButtonTapped(_ sender: Any) {
        guard let price = priceToFight, let yourDragon = myDragon?.id else { return }
        DispatchQueue.global().async {  [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                let marketplaceAddress = ContractAddress.dragonsFightPlace
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                options.value = price
                var abi : String!
                if let path = Bundle.main.path(forResource: "DragonsFightPlaceABI", ofType: "txt") {
                    abi = try String(contentsOfFile: path)
                }
                let contract = web3.contract(abi, at: marketplaceAddress, abiVersion: 2)!
                let params = [yourDragon as AnyObject, self.opponent.id as AnyObject]
                let estimatedGasResult = try contract.method("fightWithDragon", parameters: params)?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedGasResult else { return }
                options.gasLimit = .manual(estimatedGas)
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let result = try contract.method("fightWithDragon", parameters: params)?.send(password: pin)
                print(result.debugDescription)
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

// MARK: UICollectionViewDataSource methods

extension DragonToFightWithViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myDragons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DragonForBattle", for: indexPath) as! DragonForBattleCollectionViewCell
        
        cell.imageView.kf.setImage(with: myDragons[indexPath.row].imageURL)
        
        return cell
    }
}


extension DragonToFightWithViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carouselView.didScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let index = carouselView.currentCenterCellIndex?.row, myDragonsIndex != index {
            myDragonsIndex = index
        }
    }
}



