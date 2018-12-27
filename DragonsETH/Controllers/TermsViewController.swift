//
//  TermsViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/8/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Down

class TermsViewController: UIViewController {

    var newWallet: Bool!
    
    @IBOutlet weak var downContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDownView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    fileprivate func setupDownView() {
        do {
            let markdownString = try String(contentsOfFile: Bundle.main.path(forResource: "tos", ofType: "md")!)
            guard let downView = try? DownView(frame: downContainerView.bounds, markdownString: markdownString, didLoadSuccessfully: {
                print("Markdown was rendered.")
            }) else { return }
            downContainerView.addSubview(downView)
        } catch {
            print(error)
        }
    }
    
    @IBAction func agreeButtonTapped(_ sender: Any) {
        if newWallet {
            performSegue(withIdentifier: "newWallet", sender: nil)
        } else {
            performSegue(withIdentifier: "restoreWallet", sender: nil)
        }
    }
}
