//
//  SettingsTableViewController.swift
//  DragonsETH
//
//  Created by Alexander Batalov on 5/15/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Crashlytics
import Disk
import Kingfisher

class SettingsTableViewController: UITableViewController {

    var currentnetwork: ETHNet {
        if let str = UserDefaults.standard.string(forKey: Constants.web3Net) {
            return ETHNet(rawValue: str)!
        }
        return .kovan
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 4
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // wallet managment
            switch indexPath.row {
                case 0: cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .key, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 1:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .wallet, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 2:
                cell.textLabel?.text = currentnetwork.rawValue
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .connectdevelop, style: .brands, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            default:
                break
            }
        case 1: // social networks
            switch indexPath.row {
            case 0: // facebook
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .facebook, style: .brands, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 1:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .telegram, style: .brands, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 2:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .discord, style: .brands, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 3:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .twitter, style: .brands, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0: // ToS
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .clipboard, style: .regular, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 1:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .clipboard, style: .regular, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            case 2:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .handsHelping, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.imageView?.image  = UIImage.fontAwesomeIcon(name: .sync, style: .solid, textColor: .black, size: CGSize(width: 30, height: 30))
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Wallet managment
            switch indexPath.row {
            case 0: // Reveal seed
                if let seedPhraseVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SeedPhraseVC") as? SeedPhraseViewController {
                    navigationController?.pushViewController(seedPhraseVC, animated: true)
                }
                break
            case 1: // Choose wallet
                if let walletVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyWalletsVC") as? MyWaletsTableViewController {
                    navigationController?.pushViewController(walletVC, animated: true)
                }
                break
            case 2: // Select Etherium Network
                if let netVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NetworksVC") as? ChooseNetworkTableViewController {
                    navigationController?.pushViewController(netVC, animated: true)
                }
                break
            default:
                break
            }
        case 1: // social networks
            var appUrl: URL!
            var webUrl: URL!
            switch indexPath.row {
            case 0: // facebook
                appUrl = URL(string: "fb://page?id=201269357305506")!
                webUrl = URL(string: "https://www.facebook.com/ethdragons/")!
            case 1: // Telegram
                appUrl = URL(string: "tg://join?invite=DEnpkgr31xVjG4io-wmwLQ")!
                webUrl = URL(string: "https://t.me/joinchat/DEnpkgr31xVjG4io-wmwLQ")!
            case 2: // Discord
                // MARK: TODO - Figure out discord deep link
                appUrl = URL(string: "https://discord.gg/kHMxad4")!
                webUrl = URL(string: "https://discord.gg/kHMxad4")!
            case 3: // Twitter
                appUrl = URL(string: "twitter://user?screen_name=dragons_eth")!
                webUrl = URL(string: "https://twitter.com/dragons_eth")!
            default:
                break
            }
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(appUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.open(webUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            break
        case 2:
            if indexPath.row == 0 { // Terms of service
                if let termsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsOfServiceVC") as? TermsOfServiceViewController {
                    navigationController?.pushViewController(termsVC, animated: true)
                }
                break
            }
            if indexPath.row == 1 { // Privacy policy
                if let ppVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PrivacyPolicyVC") as? PrivacyPolicyViewController {
                    navigationController?.pushViewController(ppVC, animated: true)
                }
                break
            }
            if indexPath.row == 2 { // Credits
                if let creditsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreditsVC") as? CreditsViewController {
                    navigationController?.pushViewController(creditsVC, animated: true)
                }
                break
            }
            break
        case 3: // Settings
            if indexPath.row == 0 { // clear chache
                do {
                    try Disk.clear(.caches)
                    ImageCache.default.clearMemoryCache()
                    let alert = UIAlertController(title: "Success", message: "Cache successfully cleared", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }
        default:
            return
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
