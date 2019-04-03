//
//  MyDragonViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/11/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Kingfisher
import Web3swift
import BigInt
import Charts
import MBProgressHUD
import Disk

class MyDragonViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dragonNameLabel: UILabel!
    @IBOutlet weak var chartView: RadarChartView!
    @IBOutlet weak var nextBlockToActionLabel: UILabel!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var fightWonLabel: UILabel!
    @IBOutlet weak var fightLoseLabel: UILabel!
    @IBOutlet weak var kidsLabel: UILabel!
    @IBOutlet weak var fightToDeathWonLabel: UILabel!
    @IBOutlet weak var mutagenAppearanceLabel: UILabel!
    @IBOutlet weak var mutagenStrengthLabel: UILabel!
    
    var web3: web3?
    var dragon: Dragon!
    var nextBlockToAction: BigUInt? {
        didSet {
            getCurrentBlockNumber()
        }
    }
    var blockNumber: BigUInt? {
        didSet {
            updateUI()
        }
    }
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    let userCalendar = Calendar.current
    let requestedComponent: Set<Calendar.Component> = [.day,.hour,.minute,.second]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.setImage(with: dragon.imageURL, placeholder: UIImage(named: "eggPlaceholder")!)
        dragonNameLabel.text = "\(dragon.name ?? "Dragon #" + dragon.id)"
        
        chartView.xAxis.drawLabelsEnabled = false
        chartView.yAxis.drawLabelsEnabled = false
        chartView.chartDescription?.text = ""
        getDragonInfo()
    }
    
    func updateUI() {
        dragonNameLabel.text = "\(dragon.name ?? "Dragon #" + dragon.id)"
        nextBlockToActionLabel.text = "Next Block to Action: \(dragon.nextBlockToAction ?? "" )"
        stageLabel.text = "Dragon stage: \(dragon.stage ?? 0)"
        fightWonLabel.text = "Battles won: \(dragon.fightsWon ?? 0)"
        mutagenStrengthLabel.text = "User \(dragon.mutagenPerfomance ?? 0) mutagen to change battle characteristics"
        mutagenAppearanceLabel.text = "Used \(dragon.muagenAppearance ?? 0) mutagen to change appearance"
        fightToDeathWonLabel.text = "Won \(dragon.fightsToDeathWon ?? 0) fights to death"
        kidsLabel.text = "Have \(dragon.numberOfKids ?? 0) kids"
        fightLoseLabel.text = "Battles lost: \(dragon.fightsLose ?? 0)"
        setChartData()
        
        guard let nextBlockToAction = nextBlockToAction, let blockNumber = blockNumber else { return }
        if Double(nextBlockToAction) - Double(blockNumber) > 0 {
            // show countdown
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(printTime), userInfo: nil, repeats: true)
            timer.fire()
        } else {
            // show ui
            print("Show available UI")
        }
    }
    
    func setChartData() {
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
        
        let exData = chartView.data
        chartView.data = data
        MBProgressHUD.hide(for: chartView, animated: true)
        if exData == nil {
            chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        }
    }
    
    @objc func printTime() {
        guard let nextBlockToAction = nextBlockToAction, let blockNumber = blockNumber else { return }
        let seconds = (Double(nextBlockToAction) - Double(blockNumber)) * 15 // avg block minig time
        dateFormatter.dateFormat = "dd/MM/yy hh:mm:ss"
        let startTime = Date()
        let endTime = Date(timeInterval: seconds, since: startTime)
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: startTime, to: endTime)
        nextBlockToActionLabel.text = "\(timeDifference.day!) Days \(timeDifference.hour!) Hours \(timeDifference.minute!) Minutes \(timeDifference.second!) Seconds"
    }
    
    func getDragonInfo() {
        let path = "Dragons/\(dragon.id)"
        if Disk.exists(path, in: .caches) {
            do {
                dragon = try Disk.retrieve(path, from: .caches, as: Dragon.self)
                updateUI()
            } catch {
                print(error)
            }
        }
        getDragonInfoWEB3()
    }
    
    func getDragonInfoWEB3() {
        if chartView.data == nil {
            MBProgressHUD.showAdded(to: chartView, animated: true)
        }
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
                let result = try contract.method("dragons", parameters: [self.dragon.id as AnyObject])?.call(transactionOptions: nil)
                guard let res = result, let appearance = res["0"] as? BigUInt, let stage = res["1"] as? BigUInt, let fight = res["3"] as? BigUInt, let nextBlockToAction = res["4"] as? BigUInt else { return }
                DispatchQueue.main.async { [ weak self] in
                    self?.dragon.fightingGenom = fight
                    self?.dragon.visualGenom = String(appearance)
                    self?.dragon.nextBlockToAction = String(nextBlockToAction)
                    self?.dragon.stage = Int(stage)
                }
                let nameResult = try contract.method("dragonName", parameters: [self.dragon.id as AnyObject])?.call(transactionOptions: nil)
                guard let nameRes = nameResult, let name = nameRes["0"] as? String else {return}
                if name != "" { self.dragon.name = name }
                // load data from Dragon Stats Contract
                // load contract abi
                var dragonStatsContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonStatsABI", ofType: "txt") {
                    dragonStatsContractABI = try String(contentsOfFile: path)
                }
                let statsContract = web3.contract(dragonStatsContractABI, at: ContractAddress.dragonStats, abiVersion: 2)!
                let statsResult = try statsContract.method("dragonStats", parameters: [self.dragon.id as AnyObject])?.call(transactionOptions: nil)
                guard let stats = statsResult, let fightWon = stats["0"] as? BigUInt,
                    let fightLose = stats["1"] as? BigUInt,
                    let kids = stats["2"] as? BigUInt,
                    let fightToDeathWon = stats["3"] as? BigUInt,
                    let mutagenFace = stats["4"] as? BigUInt,
                    let mutagenFight = stats["5"] as? BigUInt else { return }
                try Disk.save(self.dragon, to: .caches, as: "Dragons/\(self.dragon.id)")
                DispatchQueue.main.async {
                    self.dragon.fightsWon = Int(fightWon)
                    self.dragon.fightsLose = Int(fightLose)
                    self.dragon.numberOfKids = Int(kids)
                    self.dragon.fightsToDeathWon = Int(fightToDeathWon)
                    self.dragon.muagenAppearance = Int(mutagenFace)
                    self.dragon.mutagenPerfomance = Int(mutagenFight)
                    self.updateUI()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    fileprivate func getCurrentBlockNumber() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                let block = try web3.eth.getBlockByNumber("latest")
                DispatchQueue.main.async {
                    self.blockNumber = block.number
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    @IBAction func sendGiftButtonTapped(_ sender: Any) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = stb.instantiateViewController(withIdentifier: "SendDragon") as? SendDragonViewController {
            vc.dragon = dragon
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func sellButtonTapped(_ sender: Any) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = stb.instantiateViewController(withIdentifier: "SendToMarketplace") as? SendToMarketplaceViewController {
            vc.dragon = dragon
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func revealDragonButtonTapped(_ sender: Any) {
        MBProgressHUD.showAdded(to: view, animated: true)
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
                let params = [self.dragon.id as AnyObject]
                let estimatedGasResult = try contract.method("birthDragon", parameters: params)?.estimateGas(transactionOptions: nil)
                guard let estimatedGas = estimatedGasResult else { return }
                options.gasLimit = .manual(estimatedGas)
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let result = try contract.method("birthDragon", parameters: params)?.send(password: pin)
                print(result.debugDescription)
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func nameYourDragonButtonTapped(_ sender: Any) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = stb.instantiateViewController(withIdentifier: "AddDragonName") as? AddDragonNameViewController {
            vc.dragon = dragon
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendToFightPlacebuttonTapped(_ sender: Any) {
        guard let stage = dragon.stage, stage >= 2 else {
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async {  [weak self] in
            guard let self = self, let web3 = self.web3 else { return }
            do {
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = WalletManager.shared().currentWallet
                options.value = 0
                var fightPlaceContractABI: String!
                if let path = Bundle.main.path(forResource: "DragonsFightPlaceABI", ofType: "txt") {
                    fightPlaceContractABI = try String(contentsOfFile: path)
                }
                let contract = web3.contract(fightPlaceContractABI, at: ContractAddress.dragonsFightPlace, abiVersion: 2)!
                let params = [self.dragon.id as AnyObject]
                let estimatedGas = try contract.method("addToFightPlace", parameters: params)?.estimateGas(transactionOptions: nil)
                options.gasLimit = .manual(estimatedGas!)
                let pinItem = KeychainPasswordItem(service: KeychainConfiguration.pinService, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
                let pin = try pinItem.readPassword()
                let result = try contract.method("addToFightPlace", parameters: params)?.send(password:  pin)
                print(result.debugDescription)
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

