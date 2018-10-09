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

class MainVC: UITableViewController  {
    weak var watchSession : WCSession?
    
    var coins: Coins? {
        didSet{
            DispatchQueue.main.async {
                self.cryptocurrencyView()
            }
        }
    }
    
    weak var coinDelegate: CoinDelegate?
    var selectDefaultItem = false

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        //Notification
        let keyStore = NSUbiquitousKeyValueStore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(
                                                MainVC.ubiquitousKeyValueStoreDidChange),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: keyStore)

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //Navigation Item
        let editBarButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editBarButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(settingsShow))
        
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
        CryptoCurrencyKit.cancelAllRequests()
        loadCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear")
        DispatchQueue.global(qos: .background).async {
            if let idKeyStore = SettingsUserDefaults.getIdArray() {
                self.updateApplicationContext(id: idKeyStore)
            }
        }
        loadTicker()
    }
    
    //MARK: - Notification
    // iCloud
    @objc func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        let keyStore = NSUbiquitousKeyValueStore ()
        let idKeyStore = keyStore.array(forKey: "id") as? [String]
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        let idUserDefaults = userDefaults?.array(forKey: "id") as? [String]
        if idKeyStore != nil && idUserDefaults != nil {
            if idKeyStore! != idUserDefaults! {
                self.loadTicker()
            }
        }
        
        if let idKeyStore = idKeyStore {
            self.updateApplicationContext(id: idKeyStore)
        }
    }
    
    @objc func didEnterBackground(_ notification: NSNotification!) {
        print("Background")
        CryptoCurrencyKit.cancelAllRequests()
    }
    
    @objc func willEnterForeground(_ notification: NSNotification!) {
        print("unlock")
        if (navigationController?.visibleViewController as? MainVC) != nil || UIDevice.current.userInterfaceIdiom == .pad {
            self.loadCache()
            self.loadTicker()
        }
    }

    func emptyTicker() {
        self.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: "add", sender: nil)
    }
    
    
    func loadCache() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
//                self.tickers = cacheTicker
//            }
//        }
    }
    
    private func loadTicker(completion: (()->())? = nil) {
        guard let idArray = SettingsUserDefaults.getIdArray(),
            !idArray.isEmpty else {
                self.coins = nil
               // SettingsUserDefaults.setUserDefaults(ticher: [Ticker](), lastUpdate: nil)
                return
        }
        
        Coingecko.getCoinsMarkets(ids: ["bitcoin","litecoin","ethereum"], vsCurrency: .usd) { [weak self] (response) in
            switch response {
            case .success(let coins):
                
                self?.coins = coins
                self?.updateApplicationContext(id: idArray)
//                SearchableIndex.indexItem(tickers: tickers)
//                if #available(iOS 12.0, *) {
//                    DispatchQueue.main.async {
//                        Interaction.donate(tickers: tickers)
//                    }
//                }
            case .failure(let error ):
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self?.refreshControl?.endRefreshing()
                    }
                }
                self?.errorAlert(error: error)
            }
        }
        
        
//        CryptoCurrencyKit.fetchTickers(idArray: idArray) { [weak self] (response) in
//            switch response {
//            case .success(let tickers):
//
//                self?.tickers = tickers
//                self?.updateApplicationContext(id: idArray)
//                SearchableIndex.indexItem(tickers: tickers)
//                if #available(iOS 12.0, *) {
//                    DispatchQueue.main.async {
//                        Interaction.donate(tickers: tickers)
//                    }
//                }
//            case .failure(let error ):
//                DispatchQueue.main.async {
//                    UIView.animate(withDuration: 0.25) {
//                        self?.refreshControl?.endRefreshing()
//                    }
//                }
//                self?.errorAlert(error: error)
//            }
//        }
    }
    
    fileprivate func lastUpdate() {
        if let lastUpdate = SettingsUserDefaults.getLastUpdate() {
            self.refreshControl?.attributedTitle = NSAttributedString(string: self.dateToString(date: lastUpdate))
        }
    }
    
    private func cryptocurrencyView() {
        if self.refreshControl?.isRefreshing ?? false  {
            UIView.animate(withDuration: 0.25) {
                self.refreshControl?.endRefreshing()
            }
        }
        lastUpdate()
        
        self.tableView.reloadData()
        
//        if UIDevice.current.userInterfaceIdiom == .pad,
//            !self.selectDefaultItem {
//            guard self.tickers != nil && self.tickers?.isEmpty != true else { return }
//
//            let keyStore = NSUbiquitousKeyValueStore()
//            if let tickerID = keyStore.object(forKey: "selectDefaultItemID") as? String,
//                let index = self.tickers?.index(where: {$0.id == tickerID})
//            {
//                self.coinDelegate?.coinSelected(self.tickers![index])
//            }
//            else{
//                self.coinDelegate?.coinSelected(self.tickers![0])
//            }
//            self.selectDefaultItem = true
//        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        guard let coin = coins?[indexPath.row] else { return cell }
        
        cell.settingCell(coin: coin)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderTableViewCell
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
    
    fileprivate func selectDefaultItemID(_ id: String) {
        DispatchQueue.global(qos: .utility).async {
            let keyStore = NSUbiquitousKeyValueStore ()
            keyStore.set(id, forKey: "selectDefaultItemID")
            keyStore.synchronize()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let coins = coins else { return }
        let coin = coins[indexPath.row]
       // coinDelegate?.coinSelected(coin)
        
        if let detailViewController = coinDelegate as? CryptocurrencyInfoViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
        selectDefaultItemID(coin.id)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        DispatchQueue.global(qos: .utility).async {
//            if editingStyle == .delete{
//                let keyStore = NSUbiquitousKeyValueStore ()
//
//                if var idArray = keyStore.array(forKey: "id") as? [String] {
//                    let row = indexPath.row
//                    let ticker = self.tickers![row]
//                    if let index = idArray.index(of: ticker.id){
//                        idArray.remove(at: index)
//                        SearchableIndex.deindexItem(identifier: ticker.id)
//                        self.tickers!.remove(at: row)
//
//                        // set UserDefaults
//                        SettingsUserDefaults.setUserDefaults(ticher: self.tickers!, idArray: idArray, lastUpdate: nil)
//
//                        // set iCloud key-value
//                        if self.tickers?.count == 0 {
//                            keyStore.removeObject(forKey: "id")
//                        }
//                        else{
//                            keyStore.set(idArray, forKey: "id")
//                        }
//                        keyStore.synchronize()
//
//                        // set Interaction
//                        if #available(iOS 12.0, *) {
//                            Interaction.delete(ticker: ticker)
//                        }
//
//                        self.updateApplicationContext(id: idArray)
//                    }
//                }
//            }
//        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        DispatchQueue.global(qos: .utility).async {
//            guard self.tickers != nil else { return }
//
//            let keyStore = NSUbiquitousKeyValueStore()
//            if var idArray = keyStore.array(forKey: "id") as? [String] {
//                if let index = idArray.index(of: self.tickers![sourceIndexPath.row].id){
//                    idArray.remove(at: index)
//                    idArray.insert(self.tickers![sourceIndexPath.row].id, at: destinationIndexPath.row)
//                    self.tickers!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
//
//                    SettingsUserDefaults.setUserDefaults(ticher: self.tickers!, idArray: idArray, lastUpdate: nil)
//
//                    // set iCloud key-value
//                    keyStore.set(idArray, forKey: "id")
//                    keyStore.synchronize()
//
//                    self.updateApplicationContext(id: idArray)
//                }
//            }
//        }
    }
    
    //MARK: - Actions
    @IBAction private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.loadTicker()
        }
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(settingsShow))
    }
    
    @objc private func settingsShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }
    
    @objc private func addShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "add", sender: nil)
    }
    
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func dateToString(date : NSDate) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale.current
        return formatter.string(from: date as Date)
    }
    
    //MARK: - Continue userActivity
//    func showTickerID(tickerID : String) {
//        guard let tickers = tickers else { return }
//        guard let ticker = tickers.first(where: {$0.id == tickerID}) else { return }
//        selectDefaultItemID(ticker.id)
//
//        coinDelegate?.coinSelected(ticker)
//
//        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
//            guard let splitViewController = window.rootViewController as? UISplitViewController,
//                let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
//                ((leftNavController.topViewController as? MainVC) != nil) else { return }
//        }
//        if let detailViewController = coinDelegate as? CryptocurrencyInfoViewController,
//            let detailNavigationController = detailViewController.navigationController {
//            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
//        }
//    }

}

//extension MainVC: CoinsDelegate {
//    func coins(_ tickers: [Ticker]) {
//        self.tickers = tickers
//    }
//}

extension MainVC: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
