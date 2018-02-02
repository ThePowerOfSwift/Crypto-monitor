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
    var money: CryptoCurrencyKit.Money?{
        didSet {
            guard let money = money else { return }
            symbol.text = money.flag + " " + money.rawValue
        }
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
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            title.text = product.localizedDescription
            inAppCell.priceFormatter.locale = product.priceLocale
            developerSupport.setTitle(inAppCell.priceFormatter.string(from: product.price), for: .normal)
        }
    }
    
    @IBAction func developerSupportAction(_ sender: UIButton) {
        IAPHandler.shared.purchaseMyProduct(product!)
    }
}

class writeReviewCell: UITableViewCell {
    @IBAction func writeReviewAction(_ sender: Any) {
        let appReviewURL = "itms-apps://itunes.apple.com/app/id1261522092?action=write-review&mt=8"
        UIApplication.shared.open(URL(string:appReviewURL)!,options: [:])
    }
}

class CoinMarketCapCell: UITableViewCell {
    @IBAction func coinMarketCapAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://coinmarketcap.com")!, options: [:], completionHandler: nil)
    }
}

class SettingTableViewController: UITableViewController {
    
    var products = [SKProduct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        products = IAPHandler.shared.iapProducts.sorted(){$0.price.floatValue < $1.price.floatValue}
        
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .disabled {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)        
        self.tableView.reloadData()
    }
 
    let section = [NSLocalizedString("Rate change period", comment: "Rate change period"),
                   NSLocalizedString("Currency settings", comment: "Currency settings"),
                   NSLocalizedString("tip jar", comment: "tip jar"),
                   NSLocalizedString("Review", comment: "Review"),
                   NSLocalizedString("Data source", comment: "Data source")]
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 && products.isEmpty {
            return ""
        }
        return self.section[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 && products.isEmpty  {
            return ""
        }
        return super.tableView(tableView, titleForFooterInSection: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            
            return products.count
        default:
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && products.isEmpty  {
            //header height for selected section
            return 0.1
        }
        
        //keeps all other Headers unaltered
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 && products.isEmpty  {
            //header height for selected section
            return 0.1
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            IAPHandler.shared.purchaseMyProduct(products[(indexPath as NSIndexPath).row])
        }
    }
  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "rateChangePeriodCell", for: indexPath)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencySettingsCell", for: indexPath) as! CurrencySettingsCell
            let money = SettingsUserDefaults.getCurrentCurrency()
            cell.money = money
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inAppCell", for: indexPath) as! inAppCell
            let product = products[(indexPath as NSIndexPath).row]
            cell.product = product
            return cell
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "writeReviewCell", for: indexPath)
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "coinMarketCapCell", for: indexPath)
        default:
            return tableView.dequeueReusableCell(withIdentifier: "rateChangePeriodCell", for: indexPath)
        }
    }
}
