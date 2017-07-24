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
        
        print(ticker.count)

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
            let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(self.tickerSearchResult[row].id).png")!
            cell.cryptocurrencyImageView.af_setImage(withURL: url)
            ticker = self.tickerSearchResult[row]
        } else {
            let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(self.ticker[row].id).png")!
            cell.cryptocurrencyImageView.af_setImage(withURL: url)
            ticker = self.ticker[row]
        }


        cell.cryptocurrencyNameLabel?.text = ticker.name

        return cell
    }
    
    /*
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filter(searchText: (searchController.searchBar.text!))
    }
    */



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
