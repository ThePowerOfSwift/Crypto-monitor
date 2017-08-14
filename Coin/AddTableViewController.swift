//
//  AddTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptocurrencyRequest
import AlamofireImage

var getTickerAll = [Ticker]()

class AddTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var ticker = [Ticker]()
    var tickerSearchResult  = [Ticker]()
    
    var imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache(memoryCapacity: 2 * 1024 * 1024, preferredMemoryUsageAfterPurge: UInt64(0.5 * 1024 * 1024))
    )
    
    var loadSubview:LoadSubview?
    var errorSubview:ErrorSubview?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

    }
    
    override func viewWillAppear(_ animated: Bool) {
            ticker = getTickerAll
        if ticker.isEmpty {
            showLoadSubview()
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        getTickerAll.removeAll()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    
    func cryptocurrencyView() {
        
        if let subviews = self.view?.subviews {
            for view in subviews{
                if (view is LoadSubview || view is ErrorSubview || view is EmptySubview) {
                    view.removeFromSuperview()
                }
            }
        }
        
        if let subviews = self.view.superview?.subviews {
            for view in subviews{
                if (view is LoadSubview || view is ErrorSubview) {
                    view.removeFromSuperview()
                }
            }
        }
        tableView.reloadData()
    }
    
    func loadTicker() {
        AlamofireRequest().getTicker(completion: { (ticker : [Ticker]?, error : Error?) in
                if error == nil {
                    if let ticker = ticker {
                        
                        getTickerAll = ticker
                        self.ticker = ticker
                        //update your table data here
                        DispatchQueue.main.async() {
                            if !self.tableView.isEditing {
                                self.cryptocurrencyView()
                            }
                        }
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
 
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return tickerSearchResult.count
        }
        return ticker.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCryptocurrency", for: indexPath as IndexPath) as! AddTableViewCell
        
        let row = indexPath.row
        
        let ticker: Ticker
        if searchController.isActive && searchController.searchBar.text != "" {
            ticker = self.tickerSearchResult[row]
        } else {
            ticker = self.ticker[row]
        }
        
        cell.cryptocurrencyImageView.image = nil
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(ticker.id).png")!
        cell.cryptocurrencyImageView.af_setImage(withURL: url)
        cell.cryptocurrencyNameLabel?.text = ticker.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        var ticker: Ticker
        if searchController.isActive && searchController.searchBar.text != "" {
            ticker = self.tickerSearchResult[row]
        }
        else{
            ticker = self.ticker[row]
        }
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            
            if !idArray.contains(ticker.id){
                idArray.append(ticker.id)
                
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
                
                if getTickerID == nil {
                    getTickerID = [ticker]
                }
                else{
                    getTickerID!.append(ticker)
                }

                SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                
                _ = navigationController?.popViewController(animated: true)
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "\(ticker.id) уже добавлен", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    //MARK:LoadSubview
    func showLoadSubview() {
        self.loadSubview = LoadSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height ))
        self.view.addSubview(self.loadSubview!)
       // self.view.superview?.addSubview(self.loadSubview!)
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
            
            self.errorSubview?.insertSubview(blurEffectView, at: 0) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.errorSubview?.backgroundColor = UIColor.white
        }
        
        self.errorSubview?.errorStringLabel.text = error.localizedDescription
        self.errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.superview?.addSubview(self.errorSubview!)
    }
    
    
    func filter(searchText: String)  {
        tickerSearchResult = ticker.filter{$0.name.lowercased().contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    @IBAction func cance(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filter(searchText: searchController.searchBar.text!)
    }
}
