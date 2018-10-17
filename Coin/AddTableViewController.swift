//
//  AddTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency
import AlamofireImage

class AddTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var coins = Coins()
    var coinsSearchResult  = Coins()
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
       // self.refreshControl?.addTarget(self, action: #selector(loadCoinDetails), for: UIControl.Event.valueChanged)
        
        if let idArrayUserDefaults = SettingsUserDefaults.getIdArray(){
            self.idArray = idArrayUserDefaults
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if coins.isEmpty {
            loadTicker()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func cryptocurrencyView() {
        self.refreshControl?.endRefreshing() 
        if !coins.isEmpty {
            tableView.reloadData()
        }
    }
    
    @objc func loadTicker() {
        
        Coingecko.getCoinsMarkets { [weak self] (response) in
            switch response {
            case .success(let coins):
                self?.coins = coins
                DispatchQueue.main.async() {
                    self?.cryptocurrencyView()
                }
            case .failure(let error ):
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self?.refreshControl?.endRefreshing()
                    }
                }
                self?.errorAlert(error: error)
            }
        }
        
//        Coingecko.getCoinsList { [weak self] (response) in
//            switch response {
//            case .success(let coinsList):
//                self?.coinsList = coinsList
//                DispatchQueue.main.async() {
//                    self?.cryptocurrencyView()
//                }
//            case .failure(let error):
//                self?.errorAlert(error: error)
//            }
//        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return coinsSearchResult.count
        }
        return coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCryptocurrency", for: indexPath as IndexPath) as! AddTableViewCell
        
        let row = indexPath.row
        
        let coin: Coin
        if searchController.isActive && searchController.searchBar.text != "" {
            coin = self.coinsSearchResult[row]
        } else {
            coin = self.coins[row]
        }
        
        if let url = URL(string: coin.image) {
            cell.coinImageView.af_setImage(withURL: url)
        }
        
        cell.coinNameLabel?.text = coin.name + " (\(coin.symbol))"
        
        cell.checkImageView.isHidden = !idArray.contains(coin.id)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        var coin: Coin
        if searchController.isActive && searchController.searchBar.text != "" {
            coin = self.coinsSearchResult[row]
        }
        else{
            coin = self.coins[row]
        }
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            
            if !idArray.contains(coin.id){
                idArray.append(coin.id)
                
                SettingsUserDefaults.setIdArray(idArray: idArray)
                
//                if var loadcacheTicker = SettingsUserDefaults.loadcacheTicker() {
//                    loadcacheTicker.append(coinsListElement)
//                    SettingsUserDefaults.setUserDefaults(ticher: loadcacheTicker, lastUpdate: nil)
//                }

                _ = navigationController?.popViewController(animated: true)
            }
            else{ 
                let messageString = coin.name + NSLocalizedString(" has already been added to favorites.", comment: "Title message")
                
                let alert = UIAlertController(title: NSLocalizedString("Added", comment: "Title alert"), message: messageString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            let keyStore = NSUbiquitousKeyValueStore ()
            var idArray = [String]()
            idArray.append(coin.id)
            keyStore.set(idArray, forKey: "id")
            keyStore.synchronize()
             _ = navigationController?.popViewController(animated: true)
        }
    }
   
    
    //MARK: ErrorSubview
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    @objc func reload(_ sender:UIButton) {
        loadTicker()
    }
    
    func filter(searchText: String)  {
        coinsSearchResult = coins.filter{$0.name.lowercased().contains(searchText.lowercased()) || $0.symbol.lowercased().contains(searchText.lowercased()) }
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
