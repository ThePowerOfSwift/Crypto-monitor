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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                TodayViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
            cryptocurrencyView(ticker: cacheTicker)
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
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        else{
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        }
        self.tableView.reloadData()
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
        cell.priceCoinLabel.text = cryptocurrencyShow[row].priceCurrency()
        
        
        let percentChange = cryptocurrencyShow[row].percentChangeCurrent()
        if let percent = Float(percentChange) {
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
