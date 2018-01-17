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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let money = SettingsUserDefaults().getCurrentCurrency()
        symbol.text = money.flag + " " + money.rawValue
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Loaded list of products...")
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
    }
    
    @IBAction func percentIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(percentChangeSegmentedControl.selectedSegmentIndex, forKey: "percentChange")
        keyStore.synchronize()
    }
    
    @IBAction func coinMarketCapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://coinmarketcap.com")!, options: [:], completionHandler: nil)
    }

}
