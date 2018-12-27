//
//  ViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/8/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    @IBAction func unwindToWelcomeVC(segue: UIStoryboardSegue) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let termsVC = segue.destination as? TermsViewController else { return }
        if let sender = sender as? UIButton, let text = sender.titleLabel?.text {
            termsVC.newWallet = (text == "Create new wallet")
        }
    }
    
}

