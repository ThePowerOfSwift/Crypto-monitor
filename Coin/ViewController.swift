//
//  ViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 11.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var getTicker = [Ticker]()
    var cryptocurrency = [Ticker]()
    var refreshControl: UIRefreshControl!
    weak var selectTicker : Ticker?
    var currentIndexPath: NSIndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)  // not required when using UITableViewController
        
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if getTicker.isEmpty {
            update()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func cryptocurrencyView() {
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if let idArray = keyStore.array(forKey: "id") as? [String] {
            
            if !idArray.isEmpty{
                cryptocurrency.removeAll()
                for id in idArray {
                    if let tick = getTicker.first(where: {$0.id == id}) {
                        cryptocurrency.append(tick)
                    }
                }
                tableView.reloadData()
            }
        }
        else{
            var idArray = [String]()
            
            for i in getTicker.prefix(10){
                idArray.append(i.id)
            }
            keyStore.set(idArray, forKey: "id")
            keyStore.synchronize()
            
            cryptocurrencyView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        
        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(cryptocurrency[row].id).png")!
        cell.coinImageView.af_setImage(withURL: url)
        cell.coinNameLabel.text = cryptocurrency[row].name
        cell.priceCoinLabel.text = String(cryptocurrency[row].price_usd)
        
        if cryptocurrency[row].percent_change_24h >= 0 {
            cell.percentChange_24h_View.backgroundColor = UIColor.green
            cell.percentChange_24h_View.alpha = 0.75
        }
        else{
            cell.percentChange_24h_View.backgroundColor = .red
            cell.percentChange_24h_View.alpha = 0.75
        }
        
        cell.percent_change_24h_Label.text = String(cryptocurrency[row].percent_change_24h) + "%"
       
        return cell
}
    
    func update() {
        if !self.tableView.isEditing {

            AlamofireRequest().getTicker(id : "sd", completion: { (ticker : [Ticker]?) in

                if let ticker = ticker {
                    self.getTicker = ticker
                }
                
                //update your table data here
                DispatchQueue.main.async() {
                    self.cryptocurrencyView()
                }
            })
        }
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        update()
        refreshControl.endRefreshing()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cryptocurrencyInfoSegue" {
            if let CryptocurrencyInfoVC = segue.destination as? CryptocurrencyInfoViewController {
                if let index = tableView.indexPathForSelectedRow?.row {
                    CryptocurrencyInfoVC.ticker = cryptocurrency[index]
                }
            }
        }
        
        if segue.identifier == "editSegue" {
            
            let navVC = segue.destination as? UINavigationController
       
                if let vc = navVC?.viewControllers.first as? EditViewController {
                    vc.ticker = getTicker
            }
        }
    }
}



