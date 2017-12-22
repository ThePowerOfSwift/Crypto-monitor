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
    
    
    open var cryptocurrency = [Ticker]()
    //fileprivate var cryptocurrencyCompact = [Ticker]()
    
    let formatterCurrencyUSD: NumberFormatter = {
        let formatterCurrencyUSD = NumberFormatter()
        formatterCurrencyUSD.numberStyle = .currency
        formatterCurrencyUSD.currencyCode = "USD"
        formatterCurrencyUSD.maximumFractionDigits = 4
        formatterCurrencyUSD.locale = Locale(identifier: "en_US")
        return formatterCurrencyUSD
    }()
    
    let formatterCurrencyEUR: NumberFormatter = {
        let formatterCurrencyEUR = NumberFormatter()
        formatterCurrencyEUR.numberStyle = .currency
        formatterCurrencyEUR.currencyCode = "EUR"
        formatterCurrencyEUR.maximumFractionDigits = 4
        formatterCurrencyEUR.locale = Locale(identifier: "en_US")
        return formatterCurrencyEUR
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                TodayViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
        
    //    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
     cryptocurrencyView(ticker: cacheTicker)
     }
        
    }
/*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
            cryptocurrencyView(ticker: cacheTicker)
        }
        
    }
*/
    
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
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        else{
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        }
     //   DispatchQueue.main.async {
            self.tableView.reloadData()
      //  }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
            self.cryptocurrency = cacheTicker
        }
        
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = maxSize
                self.tableView.reloadData()
            }, completion: nil)
        }
        else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = CGSize(width: maxSize.width, height: 44.0 * CGFloat(self.cryptocurrency.count))
                self.tableView.reloadData()
            }, completion: nil)
        }
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if extensionContext != nil {
            switch extensionContext!.widgetActiveDisplayMode {
            case NCWidgetDisplayMode.compact:
                count = Array(cryptocurrency.prefix(2)).count
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
            cryptocurrencyShow = Array(cryptocurrency.prefix(2))
        }
        else{
            cryptocurrencyShow = cryptocurrency
        }

        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(cryptocurrencyShow[row].id).png")!
        cell.coinImageView.af_setImage(withURL: url)

        cell.coinNameLabel.text = cryptocurrencyShow[row].name
        
        let keyStore = NSUbiquitousKeyValueStore ()
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            if let price_usd = cryptocurrencyShow[row].price_usd {
                cell.priceCoinLabel.text = formatterCurrencyUSD.string(from: NSNumber(value: Double(price_usd)!))
            }
            else{
                cell.priceCoinLabel.text = "null"
            }
        case 1:
            if let price_btc = cryptocurrencyShow[row].price_btc {
                cell.priceCoinLabel.text = "₿" + price_btc
            }
            else{
                cell.priceCoinLabel.text = "null"
            }
            
        case 2:
            if let price_eur = cryptocurrencyShow[row].price_eur {
                cell.priceCoinLabel.text = formatterCurrencyEUR.string(from: NSNumber(value: Double(price_eur)!))
            }
            else{
                cell.priceCoinLabel.text = "null"
            }
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
        
        if let percentChange = percentChange, let percent =  Float(percentChange) {
            if percent >= 0 {
                cell.percentChangeView.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            }
            else{
                cell.percentChangeView.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
            }
            cell.percentChangeLabel.text = percentChange + " %"
        }
        else{
            cell.percentChangeView.backgroundColor = UIColor.orange
            cell.percentChangeLabel.text = "null"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        
        let myAppUrl = URL(string: "cryptomonitor://?id=\(cryptocurrency[indexPath.row].id)")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
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
