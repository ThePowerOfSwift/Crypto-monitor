//
//  CoinTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 31.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreSpotlight
import MobileCoreServices
import Alamofire
import AlamofireImage
import CryptoCurrency

var openID = ""
var getTickerID:[Ticker]?
var watchSession : WCSession?

class CoinTableViewController: UITableViewController, WCSessionDelegate {
    
    var selectTicker : Ticker?
    var currentIndexPath: NSIndexPath?
    let userCalendar = Calendar.current
    
    // Subview
    //   var loadSubview:LoadSubview?
    //  var emptySubview:EmptySubview?
    
    
    //MARK:WCSession
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
    
    // Sender Watch
    private func updateApplicationContext(id: [String]) {
        DispatchQueue.global(qos: .background).async {
            do {
                let keyStore = NSUbiquitousKeyValueStore ()
                let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
                let currentCurrency = SettingsUserDefaults().getCurrentCurrency().rawValue
                
                let context = ["id" : id, "percentChange" : percentChange, "CurrentCurrency" : currentCurrency] as [String : Any]
                try watchSession?.updateApplicationContext(context)
                
            } catch let error as NSError {
                //   print("Error: \(error.description)")
            }
        }
    }
    
    // Receiver
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        // handle receiving application context
        DispatchQueue.global(qos: .background).async {
            let keyStore = NSUbiquitousKeyValueStore ()
            
            if let percentChange = applicationContext["percentChange"] as? Int {
                keyStore.set(percentChange, forKey: "percentChange")
            }
            
            if let priceCurrency = applicationContext["priceCurrency"] as? Int {
                keyStore.set(priceCurrency, forKey: "priceCurrency")
            }
            keyStore.synchronize()
            
            self.loadCache()
        }
    }
    
    
    //MARK:LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                CoinTableViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
        
        let editBarButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editBarButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(settingsShow))
        
        tableView.tableFooterView = UIView()
        
        // Set up and activate your session early here!
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if getTickerID != nil {
            if getTickerID!.isEmpty {
                //    self.showEmptySubview()
            }
        }
        loadCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear")
        
        
        DispatchQueue.global(qos: .background).async {
            let keyStore = NSUbiquitousKeyValueStore()
            let idKeyStore = keyStore.array(forKey: "id") as? [String]
            if let idKeyStore = idKeyStore {
                self.updateApplicationContext(id: idKeyStore)
            }
        }
        loadTicker()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        DispatchQueue.main.async {
            if let subviews = self.view.superview?.subviews {
                for view in subviews{
                    if (view is LoadSubview || view is ErrorSubview || view is EmptySubview) {
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    @objc func applicationWillEnterForeground(notification : NSNotification) {
        if self.viewIfLoaded?.window != nil {
            DispatchQueue.global(qos: .utility).async {
                print("unlock")
                self.loadCache()
                self.loadTicker()
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.loadTicker()
        }
    }
    
    @objc func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        DispatchQueue.global(qos: .background).async {
            let keyStore = NSUbiquitousKeyValueStore ()
            let idKeyStore = keyStore.array(forKey: "id") as? [String]
            let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
            let idUserDefaults = userDefaults?.array(forKey: "id") as? [String]
            if idKeyStore != nil && idUserDefaults != nil {
                if idKeyStore! != idUserDefaults! {
                    self.loadTicker()
                    print("************loadTicker ************")
                }
                else{
                    self.loadCache()
                    print("************ loadCache************ ")
                }
            }
            
            if let idKeyStore = idKeyStore {
                self.updateApplicationContext(id: idKeyStore)
            }
            
            
            print("iCloud key-value-store change detected")
        }
    }
    
    func loadCache() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
                getTickerID = cacheTicker
                self.cryptocurrencyView()
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
            
            let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/64x64/\(ticker[row].id).png")!
            cell.coinImageView.af_setImage(withURL: url)
            cell.coinNameLabel.text = ticker[row].name
            
            cell.priceCoinLabel.text = ticker[row].priceCurrency()
            
            let percentChange = ticker[row].percentChangeCurrent()
            cell.percentChangeLabel.text = percentChange + " %"
            if let percent = Float(percentChange) {
                if percent >= 0 {
                    cell.percentChangeView.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
                }
                else{
                    cell.percentChangeView.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
                }
            }
            else{
                cell.percentChangeView.backgroundColor = UIColor.orange
            }
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
        
        headerView.priceLabel.text = "Price (\(SettingsUserDefaults().getCurrentCurrency().rawValue))"
        
        
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
        DispatchQueue.global(qos: .utility).async {
            if editingStyle == .delete{
                let keyStore = NSUbiquitousKeyValueStore ()
                
                if var idArray = keyStore.array(forKey: "id") as? [String] {
                    if let index = idArray.index(of: getTickerID![indexPath.row].id){
                        idArray.remove(at: index)
                        self.deindexItem(identifier: getTickerID![indexPath.row].id)
                        getTickerID!.remove(at: indexPath.row)
                        
                        // set UserDefaults
                        SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                        
                        // set iCloud key-value
                        if getTickerID?.count == 0 {
                            keyStore.removeObject(forKey: "id")
                        }
                        else{
                            keyStore.set(idArray, forKey: "id")
                        }
                        keyStore.synchronize()
                        
                        self.updateApplicationContext(id: idArray)
                    }
                }
                self.cryptocurrencyView()
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        DispatchQueue.global(qos: .utility).async {
            let keyStore = NSUbiquitousKeyValueStore()
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                if let index = idArray.index(of: getTickerID![sourceIndexPath.row].id){
                    idArray.remove(at: index)
                    idArray.insert(getTickerID![sourceIndexPath.row].id, at: destinationIndexPath.row)
                    getTickerID!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                    
                    SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                    
                    // set iCloud key-value
                    keyStore.set(idArray, forKey: "id")
                    keyStore.synchronize()
                    
                    self.updateApplicationContext(id: idArray)
                    
                }
            }
        }
    }
    
    private func cryptocurrencyView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.refreshControl?.endRefreshing()
            }
        }
        
        guard getTickerID != nil else { return }
        
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        if let lastUpdate = userDefaults?.object(forKey: "lastUpdate") as? NSDate {
            DispatchQueue.main.async {
                self.refreshControl?.attributedTitle = NSAttributedString(string: self.dateToString(date: lastUpdate))
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadTicker() {
        DispatchQueue.global(qos: .utility).async {
            guard let idArray = SettingsUserDefaults().getIdArray() else {return}
            
            if idArray.isEmpty {
                getTickerID = [Ticker]()
                SettingsUserDefaults().setUserDefaults(ticher: [Ticker](), lastUpdate: nil)
                //  self.showEmptySubview()
            }
            else{
                
                CryptoCurrencyKit.fetchTickers(convert: SettingsUserDefaults().getCurrentCurrency(), idArray: idArray) { (response) in
                    switch response {
                    case .success(let tickers):
                        
                        getTickerID = tickers
                        self.cryptocurrencyView()
                        SettingsUserDefaults().setUserDefaults(ticher: tickers)
                        self.updateApplicationContext(id: idArray)
                        self.indexItem(ticker: tickers)
                        
                        print("success")
                    case .failure(let error):
                        //    self.showErrorSubview(error: error)
                        print("failure")
                    }
                }
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
    
    
    
    
    @objc func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    
    /*
     //MARK: ErrorSubview
     func showErrorSubview(error: Error) {
     if (error as NSError).code != -999 {
     DispatchQueue.main.async() {
     
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
     errorSubview?.reloadPressed.addTarget(self, action: #selector(self.reload(_:)), for: UIControlEvents.touchUpInside)
     
     self.view.superview?.addSubview(errorSubview!)
     }
     }
     }
     */
    /*
     func showEmptySubview() {
     DispatchQueue.main.async() {
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
     
     self.emptySubview?.addCryptocurrency.addTarget(self, action: #selector(self.addShow(_:)), for: UIControlEvents.touchUpInside)
     //   self.view.superview?.addSubview(self.emptySubview!)
     
     self.tableView.addSubview(EmptySubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )))
     }
     }
     */
    
    @objc func settingsShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }
    
    @objc func addShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "add", sender: nil)
    }

    
    private func dateToString(date : NSDate) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale.current
        return formatter.string(from: date as Date)
    }
    
    //MARK: Spotlight
    override func updateUserActivityState(_ activity: NSUserActivity) {
        DispatchQueue.global(qos: .background).async {
            if let cacheTicker = SettingsUserDefaults().loadcacheTicker() {
                CSSearchableIndex.default().deleteAllSearchableItems()
                self.indexItem(ticker: cacheTicker)
            }
        }
    }
    
    func indexItem(ticker: [Ticker]) {
        DispatchQueue.global(qos: .background).async {
            var searchableItems = [CSSearchableItem]()
            
            for ticker in ticker{
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                
                // Set the title.
                searchableItemAttributeSet.title = ticker.name
                // Set the description.
                searchableItemAttributeSet.contentDescription = ticker.symbol
                // Set the image.
                let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/64x64/\(ticker.id).png")!
                if let cashedImage = UIImageView.af_sharedImageDownloader.imageCache?.image(for: URLRequest(url: url), withIdentifier: nil) {
                    if let data = UIImagePNGRepresentation(cashedImage) {
                        searchableItemAttributeSet.thumbnailData = data
                    }
                }
                
                searchableItemAttributeSet.keywords = ["coin", "монета", "Pièce de monnaie", "Münze",
                                                       "cryptocurrency", "Криптовалюта", "Cryptomonnaie", "Kryptowährung",
                                                       "rates", "обменный курс", "taux de change", "Tauschrate" ]
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: ticker.id, domainIdentifier: "mialin.Coin", attributeSet: searchableItemAttributeSet)
                searchableItems.append(searchableItem)
            }
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully indexed!")
                }
            }
        }
    }
    
    func deindexItem(identifier: String) {
        DispatchQueue.global(qos: .background).async {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(identifier)"]) { error in
                if let error = error {
                    print("Deindexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully removed!")
                }
            }
        }
    }
}


extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

