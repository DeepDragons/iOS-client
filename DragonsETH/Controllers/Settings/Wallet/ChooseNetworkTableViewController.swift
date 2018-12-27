//
//  ChooseNetworkTableViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 10/1/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class ChooseNetworkTableViewController: UITableViewController {

    let networks = [ ETHNet.kovan, ETHNet.main]
    var currentNet: ETHNet {
        if let net = UserDefaults.standard.string(forKey: Constants.web3Net) {
            return ETHNet(rawValue: net)!
        }
        return.kovan
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCell") as! UITableViewCell
        if networks[indexPath.row] == .main {
            cell.textLabel?.text = networks[indexPath.row].rawValue + "  [INCOMPLETE]"
        } else {
            cell.textLabel?.text = networks[indexPath.row].rawValue
        }
        
        if networks[indexPath.row] == currentNet {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let net = networks[indexPath.row]
        UserDefaults.standard.set(net.rawValue, forKey: Constants.web3Net)
        UserDefaults.standard.synchronize()
        navigationController?.popViewController(animated: true)
    }
}
