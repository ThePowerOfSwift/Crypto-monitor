//
//  TodayViewController.swift
//  Cryptocurrency monitor widget
//
//  Created by Mialin Valentin on 01.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import NotificationCenter


import CryptocurrencyRequest
import AlamofireImage

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyButton: UIButton!
    
    
    fileprivate var cryptocurrency = [Ticker]()
    fileprivate var cryptocurrencyCompact = [Ticker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                TodayViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if let decoded = userDefaults?.data(forKey: "cryptocurrency")
        {
            if let cache = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Ticker] {
                cryptocurrencyView(ticker: cache)
                tableView.reloadData()
            }
        }
    }
    
    @objc func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        tableView.reloadData()
        print("iCloud key-value-store change detected")
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        var idArray:[String]?
        
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if  let idArrayUserDefaults = userDefaults?.array(forKey: "id") as? [String] {
            idArray = idArrayUserDefaults
        }
        else {
            let keyStore = NSUbiquitousKeyValueStore ()
            if let idArrayKeyValueStore = keyStore.array(forKey: "id") as? [String] {
                idArray = idArrayKeyValueStore
            }
        }
        
        if let idArray = idArray {
            AlamofireRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                if error == nil {
                    if let ticker = ticker {
                        SettingsUserDefaults().setUserDefaults(ticher: ticker, idArray: idArray, lastUpdate: Date())
                        DispatchQueue.main.async() {
                            self.cryptocurrencyView(ticker: ticker)
                        }
                    }
                    completionHandler(NCUpdateResult.newData)
                }
                else{
                    completionHandler(NCUpdateResult.failed)
                }
            })
        }
        else{
            self.emptyButton.isHidden = false
        }
    }
    
    
    func cryptocurrencyView(ticker: [Ticker]) {
        
        self.emptyButton.isHidden = !ticker.isEmpty
        self.cryptocurrency = ticker
        
        if ticker.count > 2 {
            self.cryptocurrencyCompact.removeAll()
            for i in 0..<2 {
                self.cryptocurrencyCompact.append(self.cryptocurrency[i])
            }
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        else{
            self.cryptocurrencyCompact = ticker
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        }
        self.tableView.reloadData()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = maxSize
                self.tableView.reloadData()
            }, completion: nil)
            
        }
        else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = CGSize(width: 0.0, height: 44.0 * CGFloat(self.cryptocurrency.count))
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if extensionContext != nil {
            switch extensionContext!.widgetActiveDisplayMode {
            case NCWidgetDisplayMode.compact:
                count = cryptocurrencyCompact.count
            case NCWidgetDisplayMode.expanded:
                count = cryptocurrency.count
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath) as! WidgetCellTableViewCell
        
        var cryptocurrencyShow = [Ticker]()
        
        if extensionContext?.widgetActiveDisplayMode == .compact {
            cryptocurrencyShow = cryptocurrencyCompact
        }
        else{
            cryptocurrencyShow = cryptocurrency
        }
        
        
        let row = indexPath.row
        
        if let id = cryptocurrencyShow[row].id {
            let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(id).png")!
            cell.coinImageView.af_setImage(withURL: url)
        }

        cell.coinNameLabel.text = cryptocurrencyShow[row].name != nil ? cryptocurrencyShow[row].name! : "null"
        
        let keyStore = NSUbiquitousKeyValueStore ()
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            cell.priceCoinLabel.text = cryptocurrencyShow[row].price_usd != nil ?  "$ " + cryptocurrencyShow[row].price_usd! : "$ null"
        case 1:
            cell.priceCoinLabel.text = cryptocurrencyShow[row].price_btc != nil ?  "₿ " + cryptocurrencyShow[row].price_usd! : "₿ null"
        default:
            break
        }
        
        var percentChange:String?
        switch keyStore.longLong(forKey: "percentChange") {
        case 0:
            percentChange = cryptocurrencyShow[row].percent_change_1h
        case 1:
            percentChange = cryptocurrencyShow[row].percent_change_24h
        case 2:
            percentChange = cryptocurrencyShow[row].percent_change_7d
        default:
            break
        }
        
        if let percentChange = percentChange {
            if Float(percentChange)! >= 0 {
                cell.percentChangeView.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            }
            else{
                cell.percentChangeView.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
            }
            cell.percentChangeLabel.text = percentChange + " %"
        }
        else{
            cell.percentChangeView.backgroundColor = UIColor(red:1.00, green:0.90, blue:0.13, alpha:1.0)
            cell.percentChangeLabel.text = "null"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if let id = cryptocurrency[indexPath.row].id {
            let myAppUrl = URL(string: "cryptomonitor://?id=\(id)")!
            extensionContext?.open(myAppUrl, completionHandler: { (success) in
                if (!success) {
                    print("error: failed to open app from Today Extension")
                }
            })
        }
    }
    
    @IBAction func emptyButton(_ sender: Any) {
        let myAppUrl = URL(string: "cryptomonitor://?add")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
    }
}
