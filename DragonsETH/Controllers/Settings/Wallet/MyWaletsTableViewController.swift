//
//  MyWaletsTableViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/24/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress

class MyWaletsTableViewController: UITableViewController {

    let walletManager = WalletManager.shared()
    var wallets: [EthereumAddress]! {
        return walletManager.wallets
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Wallets"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }

    // MARK: - Actions
    @objc func addButtonTapped() {
        do {
            try walletManager.generateNewAddress()
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell") as! UITableViewCell
        cell.textLabel?.text = wallets[indexPath.row].address
        if indexPath.row == walletManager.walletIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none 
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        walletManager.walletIndex = indexPath.row
        tableView.reloadData()
    }
}
