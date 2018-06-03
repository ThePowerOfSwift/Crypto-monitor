//
//  AddTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency

class AddTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var tickers = [Ticker]()
    var tickerSearchResult  = [Ticker]()
    var idArray = [String]()

    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.keyboardType = .asciiCapable
        
        // Setting refresh control
        self.refreshControl?.addTarget(self, action: #selector(loadTicker), for: UIControlEvents.valueChanged)
        
        if let idArrayUserDefaults = SettingsUserDefaults.getIdArray(){
            self.idArray = idArrayUserDefaults
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if tickers.isEmpty {
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func cryptocurrencyView() {
        self.refreshControl?.endRefreshing() 
        if !tickers.isEmpty {
            tableView.reloadData()
        }
    }
    
    @objc func loadTicker() {
        CryptoCurrencyKit.fetchTickers() { [weak self] (response) in
            switch response {
            case .success(let tickers):
                self?.tickers = tickers
                
                DispatchQueue.main.async() {
                    self?.cryptocurrencyView()
                }
            case .failure(let error):
                self?.errorAlert(error: error)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return tickerSearchResult.count
        }
        return tickers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCryptocurrency", for: indexPath as IndexPath) as! AddTableViewCell
        
        let row = indexPath.row
        
        let ticker: Ticker
        if searchController.isActive && searchController.searchBar.text != "" {
            ticker = self.tickerSearchResult[row]
        } else {
            ticker = self.tickers[row]
        }
   
        cell.cryptocurrencyNameLabel?.text = ticker.name + " (\(ticker.symbol))"
        
        cell.checkImageView.isHidden = !idArray.contains(ticker.id)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        var ticker: Ticker
        if searchController.isActive && searchController.searchBar.text != "" {
            ticker = self.tickerSearchResult[row]
        }
        else{
            ticker = self.tickers[row]
        }
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            
            if !idArray.contains(ticker.id){
                idArray.append(ticker.id)
                
                SettingsUserDefaults.setIdArray(idArray: idArray)
                
                if var loadcacheTicker = SettingsUserDefaults.loadcacheTicker() {
                    loadcacheTicker.append(ticker)
                    SettingsUserDefaults.setUserDefaults(ticher: loadcacheTicker, lastUpdate: nil)
                }

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
        tickerSearchResult = tickers.filter{$0.name.lowercased().contains(searchText.lowercased()) || $0.symbol.lowercased().contains(searchText.lowercased()) }
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
