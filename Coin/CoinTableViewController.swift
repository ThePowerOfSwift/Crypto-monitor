//
//  CoinTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 31.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptocurrencyRequest

var openID = ""
var getTickerID:[Ticker]?

class CoinTableViewController: UITableViewController {
    
    weak var selectTicker : Ticker?
    var currentIndexPath: NSIndexPath?
    
    var loadSubview:LoadSubview?
    var errorSubview:ErrorSubview?
    
    let userCalendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        
        loadCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if getTickerID == nil {
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func applicationDidBecomeActiveNotification(notification : NSNotification) {
        print("unlock")
        loadCache()
    }
    
    private func loadCache() {
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if let decodedTicker = userDefaults?.data(forKey: "cryptocurrency"){
            if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                getTickerID = cacheTicker
                cryptocurrencyView()
                
                if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? Date {
                    if lastUpdate <= (userCalendar.date(byAdding: .minute, value: -5, to: Date())! ){
                        loadTicker()
                    }
                }
            }
        }
    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        cryptocurrencyView()
        print("iCloud key-value-store change detected")
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getTickerID == nil {
            return 0
        }
        else{
            return getTickerID!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        
        let row = indexPath.row
        
        if let ticker = getTickerID {
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(String(describing: ticker[row].id)).png")!
        cell.coinImageView.af_setImage(withURL: url)
        cell.coinNameLabel.text = ticker[row].name
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 25
            formatter.locale = Locale(identifier: "en_US")
            cell.priceCoinLabel.text = formatter.string(from: ticker[row].price_usd as NSNumber)
        case 1:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            
            cell.priceCoinLabel.text = "₿" + formatter.string(from: ticker[row].price_btc as NSNumber)!
        default:
            break
        }
        
        var percentChange = Float()
        
        switch keyStore.longLong(forKey: "percentChange") {
        case 0:
            percentChange = ticker[row].percent_change_1h
        case 1:
            percentChange = ticker[row].percent_change_24h
        case 2:
            percentChange = ticker[row].percent_change_7d
        default:
            percentChange = ticker[row].percent_change_24h
        }
        
        CryptocurrencyInfoViewController().backgroundColorView(view: cell.percentChangeView, percentChange: percentChange)
        
        cell.percentChangeLabel.text = String(percentChange) + " %"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderTableViewCell
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        switch keyStore.longLong(forKey: "percentChange") {
        case 0:
            headerView.dataCurrencyLabel.text = "1h"
        case 1:
            headerView.dataCurrencyLabel.text = "24h"
        case 2:
            headerView.dataCurrencyLabel.text = "7d"
        default:
            headerView.dataCurrencyLabel.text = "-"
        }
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            headerView.priceLabel.text = "Price (USD)"
        case 1:
            headerView.priceLabel.text = "Price (BTC)"
        default:
            headerView.priceLabel.text = "-"
        }
        
        headerView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        headerView.insertSubview(blurEffectView, at: 0)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if getTickerID != nil {
            openID = getTickerID![indexPath.row].id
        }
    }
    
    func cryptocurrencyView() {
        
        self.refreshControl?.endRefreshing()
        
        if let subviews = self.view.superview?.subviews {
            for view in subviews{
                if (view is LoadSubview || view is ErrorSubview) {
                    view.removeFromSuperview()
                }
            }
        }
        
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        
        if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? NSDate {
            self.refreshControl?.attributedTitle = NSAttributedString(string: dateToString(date: lastUpdate))
        }
        

        tableView.reloadData()
    }
    
    func loadTicker() { 
        if getTickerID == nil {
            showLoadSubview()
        }
        else{
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height - self.topLayoutGuide.length), animated: true)
            self.refreshControl!.beginRefreshing()
            
        }
       
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if  let idArray = keyStore.array(forKey: "id") as? [String] {
            
            AlamofireRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                if error == nil {
                    if let ticker = ticker {
                        
                        getTickerID = ticker
                        //update your table data here
                        DispatchQueue.main.async() {
                            if !self.tableView.isEditing {
                                self.cryptocurrencyView()
                            }
                        }
                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: getTickerID! )
                        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
                        userDefaults?.set(encodedData, forKey: "cryptocurrency")
                        userDefaults?.set(Date(), forKey: "lastUpdate")
                        userDefaults?.synchronize()
                        
                    }
                    else{
                        print("idArray empty!")
                    }
                    
                }
                else{
                    self.showErrorSubview(error: error!)
                }
            })
        }
    }
    
    func refresh(sender:AnyObject) {
        loadTicker()
    }
    
    func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    //MARK:LoadSubview
    func showLoadSubview() {
        self.loadSubview = LoadSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height ))
        self.view.superview?.addSubview(self.loadSubview!)
    }
    
    //MARK: ErrorSubview
    func showErrorSubview(error: Error) {
        self.errorSubview = ErrorSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.errorSubview?.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = (self.view.superview?.frame)!
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.errorSubview?.insertSubview(blurEffectView, at: 0)
        } else {
            self.errorSubview?.backgroundColor = UIColor.white
        }
        
        self.errorSubview?.errorStringLabel.text = error.localizedDescription
        self.errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.superview?.addSubview(self.errorSubview!)
    }
    
    func dateToString(date : NSDate) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale.current
        return formatter.string(from: date as Date)
    }
    
    

}
