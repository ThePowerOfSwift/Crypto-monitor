//
//  CoinTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 31.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import WatchConnectivity
import Alamofire
import CryptoCurrency

var getTickerID:[Ticker]?
var watchSession : WCSession?

protocol CoinDelegate: class {
    func coinSelected(_ ticker: Ticker)
}

class CoinTableViewController: UITableViewController, WCSessionDelegate {
    
    weak var coinDelegate: CoinDelegate?
    var selectDefaultItem = false

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self

        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                CoinTableViewController.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)
        
        //Navigation Item
        let editBarButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editBarButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(settingsShow))
        
        // Setting DZNEmptyData
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView()
        
        showReview()
        
        // Set up and activate your session early here!
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear")
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
    
    func loadCache() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
                getTickerID = cacheTicker
                self.cryptocurrencyView()
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTickerID?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        let row = indexPath.row
        
        if let ticker = getTickerID {
            
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        
        headerView.priceLabel.text = "Price (\(SettingsUserDefaults.getCurrentCurrency().rawValue))"
        
        
        let contentView = headerView.contentView
        
        contentView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        contentView.insertSubview(blurEffectView, at: 0)
        return contentView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if getTickerID != nil {
            let ticker = getTickerID![indexPath.row]
            coinDelegate?.coinSelected(ticker)
            
            let keyStore = NSUbiquitousKeyValueStore ()
            keyStore.set(ticker.id, forKey: "selectDefaultItemID")
            keyStore.synchronize()
            
            if let detailViewController = coinDelegate as? CryptocurrencyInfoViewController,
                let detailNavigationController = detailViewController.navigationController {
                splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
            }
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
                        SettingsUserDefaults.setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                        
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
                    
                    SettingsUserDefaults.setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                    
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

            if UIDevice.current.userInterfaceIdiom == .pad,
                !self.selectDefaultItem {
                let keyStore = NSUbiquitousKeyValueStore()
                if let tickerID = keyStore.object(forKey: "selectDefaultItemID") as? String,
                    let index = getTickerID?.index(where: {$0.id == tickerID})
                {
                    self.coinDelegate?.coinSelected(getTickerID![index])
                }
                else{
                    self.coinDelegate?.coinSelected(getTickerID![0])
                }
                self.selectDefaultItem = true
            }
        }
    }
    
    private func loadTicker() {
        DispatchQueue.global(qos: .utility).async {
            guard let idArray = SettingsUserDefaults.getIdArray() else {return}
            
            if idArray.isEmpty {
                getTickerID = [Ticker]()
                SettingsUserDefaults.setUserDefaults(ticher: [Ticker](), lastUpdate: nil)
            }
            else{
                
                CryptoCurrencyKit.fetchTickers(convert: SettingsUserDefaults.getCurrentCurrency(), idArray: idArray) { [weak self] (response) in
                    switch response {
                    case .success(let tickers):
                        
                        getTickerID = tickers
                        self?.cryptocurrencyView()
                        SettingsUserDefaults.setUserDefaults(ticher: tickers)
                        self?.updateApplicationContext(id: idArray)
                        self?.indexItem(ticker: tickers)
                    case .failure(let error ):
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.25) {
                                self?.refreshControl?.endRefreshing()
                            }
                        }
                        self?.errorAlert(error: error)
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
    
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
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
    
    //MARK: - iCloud sync
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

    //MARK: - WCSession
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Sender Watch
    private func updateApplicationContext(id: [String]) {
        DispatchQueue.global(qos: .background).async {
            do {
                let keyStore = NSUbiquitousKeyValueStore ()
                let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
                let currentCurrency = SettingsUserDefaults.getCurrentCurrency().rawValue
                
                let context = ["id" : id, "percentChange" : percentChange, "CurrentCurrency" : currentCurrency] as [String : Any]
                try watchSession?.updateApplicationContext(context)
                
            } catch let error as NSError {
                print("Error: \(error.description)")
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
}

extension CoinTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}


// MARK: - Extension Array
extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

