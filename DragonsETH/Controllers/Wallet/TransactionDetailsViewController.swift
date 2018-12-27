//
//  TransactionDetailsViewController.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/17/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class TransactionDetailsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var tx: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://kovan.etherscan.io/tx/\(tx!)")!
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 10.0)
        webView.load(request)
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    func showActivityIndicator(_ show: Bool) {
        if show {
            MBProgressHUD.showAdded(to: webView, animated: true)
        } else {
            MBProgressHUD.hide(for: webView, animated: true)
        }
    }
}


extension TransactionDetailsViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(false)
    }
}
