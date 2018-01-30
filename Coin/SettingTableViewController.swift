//
//  SettingTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 30.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency
import StoreKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var percentChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var symbol: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        percentChangeSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "percentChange"))
        
        IAPHandler.shared.requestProducts { success, products in
            if success {
                
              //  products?.sorted(){Float(truncating: $0.price) < Float(truncating: $1.price)}
                
                let sortProducts = products?.sorted(){$0.price.floatValue < $1.price.floatValue}
                for product in sortProducts! {
                    print(product.localizedDescription)
                }
            }
        }
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let money = SettingsUserDefaults().getCurrentCurrency()
        symbol.text = money.flag + " " + money.rawValue
    }
    
    @IBAction func percentIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(percentChangeSegmentedControl.selectedSegmentIndex, forKey: "percentChange")
        keyStore.synchronize()
    }
    
    @IBAction func coinMarketCapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://coinmarketcap.com")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func developerSupportAction(_ sender: UIButton) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
}
