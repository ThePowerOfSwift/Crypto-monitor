//
//  AddTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class AddTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var ticker = [Ticker]()
    var tickerSearchResult  = [Ticker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "editCryptocurrency")
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return tickerSearchResult.count
        }
        return ticker.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCryptocurrency", for: indexPath) as! EditTableViewCell
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
        let keyStore = NSUbiquitousKeyValueStore ()
        let row = indexPath.row
        
        let ticker: Ticker
        if searchController.isActive && searchController.searchBar.text != "" {
            ticker = self.tickerSearchResult[row]
        }
        else{
            ticker = self.ticker[row]
        }
        
        if var idArray = keyStore.array(forKey: "id") as? [String] {
        
            if !idArray.contains(ticker.id){
                idArray.append(ticker.id)
                
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
                
                searchController.isActive = false
                self.dismiss(animated: true, completion: nil)
                
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "\(ticker.id) уже добавлен", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
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
