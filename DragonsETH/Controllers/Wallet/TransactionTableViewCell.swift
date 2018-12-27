//
//  TransactionTableViewCell.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    
    
    var transaction: Transaction! {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.timeStamp)!)
        dateLabel.text = date.getElapsedInterval() + " ago." 
        hashLabel.text = transaction.hash
        valueLabel.text = "\(transaction.value.toEth) ETH"
        if transaction.isError {
            successLabel.text = "Failed"
            successLabel.textColor = .red
        } else {
            successLabel.text = "Completed"
            successLabel.textColor = .green
        }
    }
}
