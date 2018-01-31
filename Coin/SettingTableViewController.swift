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

class RateChangePeriodCell: UITableViewCell {
    @IBOutlet weak var percentChangeSegmentedControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        let keyStore = NSUbiquitousKeyValueStore ()
        percentChangeSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "percentChange"))
    }
    
    @IBAction func percentIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(percentChangeSegmentedControl.selectedSegmentIndex, forKey: "percentChange")
        keyStore.synchronize()
    }
}

class CurrencySettingsCell: UITableViewCell {
    @IBOutlet weak var symbol: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let money = SettingsUserDefaults().getCurrentCurrency()
        symbol.text = money.flag + " " + money.rawValue
    }
}

class inAppCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var developerSupport: UIButton!
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            title.text = product.localizedDescription
            inAppCell.priceFormatter.locale = product.priceLocale
            developerSupport.setTitle(inAppCell.priceFormatter.string(from: product.price), for: .normal)
        }
    }
    
    @IBAction func developerSupportAction(_ sender: UIButton) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
}

class SettingTableViewController: UITableViewController {
    
    var products = [SKProduct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        IAPHandler.shared.requestProducts { success, products in
            if success {
                let sortProducts = products?.sorted(){$0.price.floatValue < $1.price.floatValue}
                self.products = sortProducts!
                self.tableView.reloadData()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return products.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "rateChangePeriodCell", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "currencySettingsCell", for: indexPath)
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inAppCell", for: indexPath) as! inAppCell
            
             let product = products[(indexPath as NSIndexPath).row]
             cell.product = product
            
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "rateChangePeriodCell", for: indexPath)
        }
    }
    
    
    
    
    

    
    @IBAction func coinMarketCapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://coinmarketcap.com")!, options: [:], completionHandler: nil)
    }
    

}
