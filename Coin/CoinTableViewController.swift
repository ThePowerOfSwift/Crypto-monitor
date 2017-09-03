//
//  CoinTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 31.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptocurrencyRequest
import WatchConnectivity


var openID = ""
var getTickerID:[Ticker]?
var watchSession : WCSession?

class CoinTableViewController: UITableViewController, WCSessionDelegate {
    
    weak var selectTicker : Ticker?
    var currentIndexPath: NSIndexPath?
    let userCalendar = Calendar.current
    
    // Subview
    var loadSubview:LoadSubview?
    var emptySubview:EmptySubview?
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Sender
    private func updateApplicationContext(context: [String : Any]) {
        do {
            try watchSession?.updateApplicationContext(context)
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        
    }
    
    func updateIdArray(id: [String]) {
        let keyStore = NSUbiquitousKeyValueStore ()
        let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
        let priceCurrency = Int(keyStore.longLong(forKey: "priceCurrency"))
        
        let context = ["id" : id, "percentChange" : percentChange, "priceCurrency" : priceCurrency] as [String : Any]
        updateApplicationContext(context: context)
    }
    
    func updateSettings() {
        let keyStore = NSUbiquitousKeyValueStore ()
        let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
        let priceCurrency = Int(keyStore.longLong(forKey: "priceCurrency"))
        
        let context = ["percentChange" : percentChange, "priceCurrency" : priceCurrency] as [String : Any]
        updateApplicationContext(context: context)
    }
    
    // Receiver
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        // handle receiving application context
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if let percentChange = applicationContext["percentChange"] as? Int {
            keyStore.set(percentChange, forKey: "percentChange")
        }
        
        if let priceCurrency = applicationContext["priceCurrency"] as? Int {
            keyStore.set(priceCurrency, forKey: "priceCurrency")
        }
        keyStore.synchronize()
        
        DispatchQueue.main.async() {
            self.loadCache()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                CoinTableViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
        
        let editBarButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editBarButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(settingsShow))
        
        loadCache()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if getTickerID == nil {
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
        // Set up and activate your session early here!
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if getTickerID != nil {
            if getTickerID!.isEmpty {
                self.showEmptySubview()
            }
        }
    }

    func applicationDidBecomeActiveNotification(notification : NSNotification) {
        print("unlock")
        loadCache()
    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        
        let keyStore = NSUbiquitousKeyValueStore ()
        let idKeyStore = keyStore.array(forKey: "id") as? [String]
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        let idUserDefaults = userDefaults?.array(forKey: "id") as? [String]
        
        if idKeyStore != nil && idUserDefaults != nil {
            if idKeyStore! != idUserDefaults! {
                loadTicker()
                
            }
       }
                updateIdArray(id: idKeyStore!)
        print("iCloud key-value-store change detected")
    }
    
    func loadCache() {
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if let decodedTicker = userDefaults?.data(forKey: "cryptocurrency"){
            
            if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                getTickerID = cacheTicker
                let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
                if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? NSDate {
                    self.refreshControl?.attributedTitle = NSAttributedString(string: dateToString(date: lastUpdate))
                }
                tableView.reloadData()
                
                if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? Date {
                    if lastUpdate <= (userCalendar.date(byAdding: .minute, value: -5, to: Date())! ){
                        loadTicker()
                    }
                }
            }
        }
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
                
                cell.priceCoinLabel.text = "₿ " + formatter.string(from: ticker[row].price_btc as NSNumber)!
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
        
        let contentView = headerView.contentView
        
        contentView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        contentView.insertSubview(blurEffectView, at: 0)
        return contentView
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let keyStore = NSUbiquitousKeyValueStore ()
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                if let index = idArray.index(of: getTickerID![indexPath.row].id){
                    idArray.remove(at: index)
                    getTickerID!.remove(at: indexPath.row)
                    
                    // set iCloud key-value
                    keyStore.set(idArray, forKey: "id")
                    keyStore.synchronize()
                    
                    // set UserDefaults
                    SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                }
            }
            cryptocurrencyView()
        }
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
 
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            if let index = idArray.index(of: getTickerID![sourceIndexPath.row].id){
                idArray.remove(at: index)
                idArray.insert(getTickerID![sourceIndexPath.row].id, at: destinationIndexPath.row)
                getTickerID!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                
                // set iCloud key-value
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
                
                // set UserDefaults
                SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
            }
        }
    }
    
    private func cryptocurrencyView() {
        self.refreshControl?.endRefreshing()
        
        if getTickerID!.isEmpty {
            self.showEmptySubview()
        }
        else{
            if let subviews = self.view.superview?.subviews {
                for view in subviews{
                    if (view is LoadSubview || view is ErrorSubview || view is EmptySubview) {
                        view.removeFromSuperview()
                    }
                }
            }
        }

        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? NSDate {
            self.refreshControl?.attributedTitle = NSAttributedString(string: dateToString(date: lastUpdate))
        }
        tableView.reloadData()
    }
    
    private func loadTicker() {
        let keyStore = NSUbiquitousKeyValueStore ()
        if let idArray = keyStore.array(forKey: "id") as? [String] {
            if idArray.isEmpty {
                getTickerID = [Ticker]()
                SettingsUserDefaults().setUserDefaults(ticher: [Ticker](), idArray: idArray, lastUpdate: nil)
                showEmptySubview()
            }
            else{
                // Какой вид загрузки отображать
                if getTickerID == nil {
                    showLoadSubview()
                }

                
                AlamofireRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                    if error == nil {
                        if let ticker = ticker {
                            getTickerID = ticker
                            SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: Date())

                            self.updateIdArray(id: idArray)
                            
                            DispatchQueue.main.async() {
                                self.cryptocurrencyView()
                            }
                        }
                    }
                    else{
                        self.showErrorSubview(error: error!)
                    }
                })
            }
        }
    }
    
    func fetch(_ completion: () -> Void) {
        loadTicker()
        completion()
    }
    
    @objc private func edit(_ sender: Any) {
        self.tableView.setEditing(true, animated: true)

        let doneBarButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneBarButton
        
        let addBarButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addShow))
        self.navigationItem.leftBarButtonItem = addBarButton
    }
    
    @objc private func done(_ sender: Any) {
        self.tableView.setEditing(false, animated: true)
        
        let editBarButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editBarButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(settingsShow))
    }
    
    
    func refresh(sender:AnyObject) {
        loadTicker()
    }
    
    func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    
    //MARK:LoadSubview
    func showLoadSubview() {
        self.refreshControl?.endRefreshing()
        self.loadSubview = LoadSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height ))
        self.view.superview?.addSubview(self.loadSubview!)
    }
    
    //MARK: ErrorSubview
    func showErrorSubview(error: Error) {
        var errorSubview:ErrorSubview?
        self.refreshControl?.endRefreshing()
        
        errorSubview = ErrorSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            errorSubview?.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            errorSubview?.insertSubview(blurEffectView, at: 0)
        } else {
            errorSubview?.backgroundColor = UIColor.white
        }
        
        errorSubview?.errorStringLabel.text = error.localizedDescription
        errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.superview?.addSubview(errorSubview!)
    }
    
    func showEmptySubview() {
        self.refreshControl?.endRefreshing()
        
        self.emptySubview = EmptySubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height ))
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.emptySubview?.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.emptySubview?.insertSubview(blurEffectView, at: 0)
        } else {
            self.emptySubview?.backgroundColor = UIColor.white
        }
        
        self.emptySubview?.addCryptocurrency.addTarget(self, action: #selector(addShow(_:)), for: UIControlEvents.touchUpInside)
        self.view.superview?.addSubview(emptySubview!)

    }
    
    
    func settingsShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }
    
    func addShow(_ sender:UIButton) {
          self.performSegue(withIdentifier: "add", sender: nil)
    }
    
    private func dateToString(date : NSDate) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale.current
        return formatter.string(from: date as Date)
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
