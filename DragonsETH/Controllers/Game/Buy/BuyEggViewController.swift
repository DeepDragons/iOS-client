//
//  BuyEggViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 6/10/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD

class BuyEggViewController: UIViewController {

    @IBOutlet weak var eggsSoldLabel: UILabel!
    @IBOutlet weak var currentEggLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var guaranteeSwitch: UISwitch!
    
    var isGuarantee = true
    var numberOfEggsToBuy: Int = 0
    var ETHToPay: BigUInt {
        get {
            var val: BigUInt = eggPrice ?? 0
            val *= BigUInt(numberOfEggsToBuy)
            val += isGuarantee ? 2 * (priceChanger ?? 0) : 0 // add double price changer in order to insure transaction to get through. All the reamining ETH will be back as change.
            return val
        }
    }
    var eggPrice: BigUInt? {
        didSet {
            guard let eggPrice = eggPrice else { return }
            currentEggLabel.text = "Current egg price: \(Web3.Utils.formatToEthereumUnits(eggPrice) ?? "") ETH"
        }
    }
    var priceChanger: BigUInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy eggs"
        
        numberOfEggsToBuy = Int(slider.value)
        buyButton.setTitle("Buy \(numberOfEggsToBuy) for \(1.0) ETH", for: .normal)
        
        getEggPrice()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else { return }
        numberOfEggsToBuy = Int(slider.value)
        buyButton.setTitle("Buy \(numberOfEggsToBuy) \(numberOfEggsToBuy == 1 ? "egg" : "eggs") for \(ETHToPay.toEth) ETH", for: .normal)
    }
    
    @IBAction func guaranteeSwitchValueDidChange(_ sender: Any) {
        if let sw = sender as? UISwitch {
            isGuarantee = sw.isOn
            buyButton.setTitle("Buy \(numberOfEggsToBuy) \(Int(slider.value) == 1 ? "egg" : "eggs") for \(ETHToPay.toEth) ETH", for: .normal)
        }
    }
    
    @IBAction func buyButtonTapped(_ sender: Any) {
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            CrowdsaleContract.shared().exchangeEtherForEggs(amount: self.ETHToPay, completion: { (error) in
                if let error = error {
                    print(error)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
        }
    }
    
    func getEggPrice() {
        let queue = DispatchQueue(label: "loadPrices", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
        queue.async { [weak self] in
            guard let self = self else { return }
            CrowdsaleContract.shared().getCurrentEggPrice(completion: { (error, price) in
                if let error = error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        self.eggPrice = price
                    }
                }
            })
        }
        queue.async { [weak self] in
            guard let self = self else { return }
            CrowdsaleContract.shared().getAmountOfEggsSold(completion: { (error, amount) in
                if let amount = amount {
                    DispatchQueue.main.async {
                        self.eggsSoldLabel.text = "\(amount) Eggs sold."
                    }
                } else {
                    print(error)
                }
            })
        }
    }
}

