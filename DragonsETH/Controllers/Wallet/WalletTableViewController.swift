//
//  WalletTableViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/15/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import MBProgressHUD

class WalletTableViewController: UITableViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var mutagenLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    
    var networkManager: NetworkManager!
    let walletManager = WalletManager.shared()
    var web3Manager: Web3Manager?
    var currentPage = 1
    var isLoadingList : Bool = false
    var balance: BigUInt = 0 {
        didSet {
            balanceLabel.text = "\(balance.toEth) ETH"
        }
    }
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        self.networkManager = NetworkManager()
        walletLabel.text = walletManager.currentWallet?.address
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WalletTableViewController.updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.rowHeight = 150
        
        updateData()
    }
    
    @objc func updateData() {
        walletLabel.text = walletManager.currentWallet?.address
        if let wm = Web3Manager.shared() {
            web3Manager = wm
            getBalance()
            getTransactions()
        } else {
            let alert = UIAlertController(title: "Error", message: "Ooops! Something went wrong. Please check your internet connection and try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {_ in
                self.updateData()
            }
            alert.addAction(tryAgainAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func getMoreTransactions() {
        currentPage += 1
        getTransactions()
    }
    
    fileprivate func getBalance() {
        var hud: MBProgressHUD?
        if balance == 0 {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let web3 = self.web3Manager?.web3, let localWallet = self.walletManager.currentWallet else { return }
            do {
                let bal = try web3.eth.getBalance(address: localWallet)
                DispatchQueue.main.async {
                    hud?.hide(animated: true)
                    self.tableView.refreshControl?.endRefreshing()
                    self.balance = bal
                }
                // get Mutagen balance
                let contract = web3.contract(Web3.Utils.erc20ABI, at: ContractAddress.mutagen, abiVersion: 2)!
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.from = localWallet
                
                let muataenBalanceResult = try contract.method("balanceOf", parameters: [localWallet] as [AnyObject])?.call(transactionOptions: nil)
                guard let muatgenBalance = muataenBalanceResult, let muatagenBal = muatgenBalance["0"] as? BigUInt else {return}
                DispatchQueue.main.async { [weak self] in
                    self?.mutagenLabel.text = "\(muatagenBal) Mutagen"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    fileprivate func getTransactions() {
        isLoadingList = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.networkManager.getTransactions(page: self.currentPage, offset: 15, walletAddress: (self.walletManager.currentWallet!.address)) { (transactions, error) in
                if let error = error {
                    print(error)
                }
                if let transactions = transactions {
                    DispatchQueue.main.async {
                        self.transactions += transactions
                        self.tableView.reloadData()
                        self.isLoadingList = false
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        cell.transaction = transactions[indexPath.row]
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let transactionDetailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TransactionDetailVC") as? TransactionDetailsViewController {
            let tx = transactions[indexPath.row].hash
            transactionDetailVC.tx = tx
            navigationController?.pushViewController(transactionDetailVC, animated: true)
        }
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList) {
            getMoreTransactions()
        }
    }

}
