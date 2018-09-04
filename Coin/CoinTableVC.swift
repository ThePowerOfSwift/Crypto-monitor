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

class MainVC: UITableViewController {
    weak var watchSession : WCSession?
    
    var tickers:[Ticker]?
    weak var coinDelegate: CoinDelegate?
    var selectDefaultItem = false

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name:NSNotification.Name.NSExtensionHostWillEnterForeground, object: nil)
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                MainVC.ubiquitousKeyValueStoreDidChange),
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
        
        #if RELEASE
          Review.showReview()
        #endif
      
        
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
    


    @objc private func applicationWillEnterForeground(notification : NSNotification) {
        if self.viewIfLoaded?.window != nil {
            DispatchQueue.global(qos: .utility).async {
                print("unlock")
                self.loadCache()
                self.loadTicker()
            }
        }
    }
    
    @IBAction private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.loadTicker()
        }
    }
    
    func showTickerID(tickerID : String) {
        guard let tickers = tickers else { return }
        guard let ticker = tickers.first(where: {$0.id == tickerID}) else { return }
        
        coinDelegate?.coinSelected(ticker)
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            guard let splitViewController = window.rootViewController as? UISplitViewController,
                let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
                ((leftNavController.topViewController as? MainVC) != nil) else { return }
        }
        if let detailViewController = coinDelegate as? CryptocurrencyInfoViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
    }
    
    func emptyTicker() {
        self.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: "add", sender: nil)
    }
    
    
    func loadCache() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
                self.tickers = cacheTicker
                self.cryptocurrencyView()
            }
        }
    }
    
    private func loadTicker() {
        DispatchQueue.global(qos: .utility).async {
            guard let idArray = SettingsUserDefaults.getIdArray() else {
                self.tickers = [Ticker]()
                SettingsUserDefaults.setUserDefaults(ticher: [Ticker](), lastUpdate: nil)
                return
            }
            
            if idArray.isEmpty {
                self.tickers = [Ticker]()
                SettingsUserDefaults.setUserDefaults(ticher: [Ticker](), lastUpdate: nil)
            }
            else{
                
                CryptoCurrencyKit.fetchTickers(idArray: idArray) { [weak self] (response) in
                    switch response {
                    case .success(let tickers):
                        
                        self?.tickers = tickers
                        self?.cryptocurrencyView()
                        SettingsUserDefaults.setUserDefaults(ticher: tickers, idArray: idArray)
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
    
    private func cryptocurrencyView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.refreshControl?.endRefreshing()
            }
        }
        
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
                guard self.tickers != nil && self.tickers?.isEmpty != true else { return }
                
                let keyStore = NSUbiquitousKeyValueStore()
                if let tickerID = keyStore.object(forKey: "selectDefaultItemID") as? String,
                    let index = self.tickers?.index(where: {$0.id == tickerID})
                {
                    self.coinDelegate?.coinSelected(self.tickers![index])
                }
                else{
                    self.coinDelegate?.coinSelected(self.tickers![0])
                }
                self.selectDefaultItem = true
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        let row = indexPath.row
        
        if let ticker = tickers {
            
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
        guard let tickers = tickers else { return }
        let ticker = tickers[indexPath.row]
        coinDelegate?.coinSelected(ticker)
        
        if let detailViewController = coinDelegate as? CryptocurrencyInfoViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
        
        DispatchQueue.global(qos: .utility).async {
            let keyStore = NSUbiquitousKeyValueStore ()
            keyStore.set(ticker.id, forKey: "selectDefaultItemID")
            keyStore.synchronize()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .utility).async {
            if editingStyle == .delete{
                let keyStore = NSUbiquitousKeyValueStore ()
                
                if var idArray = keyStore.array(forKey: "id") as? [String] {
                    if let index = idArray.index(of: self.tickers![indexPath.row].id){
                        idArray.remove(at: index)
                        self.deindexItem(identifier: self.tickers![indexPath.row].id)
                        self.tickers!.remove(at: indexPath.row)
                        
                        // set UserDefaults
                        SettingsUserDefaults.setUserDefaults(ticher: self.tickers!, idArray: idArray, lastUpdate: nil)
                        
                        // set iCloud key-value
                        if self.tickers?.count == 0 {
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
            guard self.tickers != nil else { return }
            
            let keyStore = NSUbiquitousKeyValueStore()
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                if let index = idArray.index(of: self.tickers![sourceIndexPath.row].id){
                    idArray.remove(at: index)
                    idArray.insert(self.tickers![sourceIndexPath.row].id, at: destinationIndexPath.row)
                    self.tickers!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                    
                    SettingsUserDefaults.setUserDefaults(ticher: self.tickers!, idArray: idArray, lastUpdate: nil)
                    
                    // set iCloud key-value
                    keyStore.set(idArray, forKey: "id")
                    keyStore.synchronize()
                    
                    self.updateApplicationContext(id: idArray)
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

    @objc private func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    @objc private func settingsShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }
    
    @objc private func addShow(_ sender:UIButton) {
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
              //  self.loadCache()
                print("************ loadCache ************ ")
            }
        }
        
        if let idKeyStore = idKeyStore {
            self.updateApplicationContext(id: idKeyStore)
        }
        print("iCloud key-value-store change detected")
    }
}

extension MainVC: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
