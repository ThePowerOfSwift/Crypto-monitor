//
//  AddTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency

var getTickerAll = [Ticker]()

class AddTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var ticker = [Ticker]()
    var tickerSearchResult  = [Ticker]()

    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.keyboardType = .asciiCapable
        
        // Setting refresh control
        self.refreshControl?.addTarget(self, action: #selector(loadTicker), for: UIControlEvents.valueChanged)
        
        ticker = getTickerAll
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if ticker.isEmpty {
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func cryptocurrencyView() {
        self.refreshControl?.endRefreshing() 
        if !ticker.isEmpty {
            tableView.reloadData()
        }
    }
    
    @objc func loadTicker() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height - self.topLayoutGuide.length), animated: true)
        self.refreshControl!.beginRefreshing()
        
        let currentCurrency = SettingsUserDefaults.getCurrentCurrency()
        CryptoCurrencyKit.fetchTickers(convert: currentCurrency, idArray: nil, limit: 0) { (response) in
            switch response {
            case .success(let tickers):
                getTickerAll = tickers
                self.ticker = tickers
                
                DispatchQueue.main.async() {
                    self.cryptocurrencyView()
                }
                print("success")
            case .failure(let error):
                print("failure")
                self.errorAlert(error: error)
            }
        }
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
   
        cell.cryptocurrencyNameLabel?.text = ticker.name + " (\(ticker.symbol))"
        
        if (getTickerID?.filter({ $0.id == ticker.id}).first) != nil{
           cell.checkImageView.isHidden = false
        }
        else{
            cell.checkImageView.isHidden = true
        }
        
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
                
                SettingsUserDefaults.setUserDefaults(ticher: getTickerID!, lastUpdate: nil)

             _ = navigationController?.popViewController(animated: true)
            }
            else{ 
                let messageString = ticker.name + NSLocalizedString(" has already been added to favorites.", comment: "Title message")
                
                let alert = UIAlertController(title: NSLocalizedString("Added", comment: "Title alert"), message: messageString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            let keyStore = NSUbiquitousKeyValueStore ()
            var idArray = [String]()
            idArray.append(ticker.id)
            keyStore.set(idArray, forKey: "id")
            keyStore.synchronize()
             _ = navigationController?.popViewController(animated: true)
        }
    }
   
    
    //MARK: ErrorSubview
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    @objc func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    func filter(searchText: String)  {
        tickerSearchResult = ticker.filter{$0.name.lowercased().contains(searchText.lowercased()) || $0.symbol.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filter(searchText: searchController.searchBar.text!)
    }
}
