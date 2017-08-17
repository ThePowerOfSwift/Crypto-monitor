//
//  SettingTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 30.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
     @IBOutlet weak var percentChangeSegmentedControl: UISegmentedControl!
     @IBOutlet weak var priceCurrencySegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        percentChangeSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "percentChange"))
        priceCurrencySegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "priceCurrency"))
    }
    
    @IBAction func percentIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(percentChangeSegmentedControl.selectedSegmentIndex, forKey: "percentChange")
        keyStore.synchronize()
    }
    
    @IBAction func priceIindexCurrency(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(priceCurrencySegmentedControl.selectedSegmentIndex, forKey: "priceCurrency")
        keyStore.synchronize()
    }
    
    @IBAction func coinMarketCapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://coinmarketcap.com")!, options: [:], completionHandler: nil)
    }

}
