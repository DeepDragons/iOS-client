//
//  PrivacyPolicyViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/24/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import Down

class PrivacyPolicyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDownView()
    }
    
    fileprivate func setupDownView() {
        do {
            let markdownString = try String(contentsOfFile: Bundle.main.path(forResource: "pp", ofType: "md")!)
            guard let downView = try? DownView(frame: self.view.bounds, markdownString: markdownString, didLoadSuccessfully: {
                print("Markdown was rendered.")
            }) else { return }
            view.addSubview(downView)
        } catch {
            print(error)
        }
    }
    
}
