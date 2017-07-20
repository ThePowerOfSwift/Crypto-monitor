//
//  ViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 11.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var getTicker = [Ticker]()
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
        /*
         let locale = Locale.current
         let currencySymbol = locale.currencySymbol!
         let currencyCode = locale.currencyCode!
         
         print(currencySymbol)
         print(currencyCode)
         */
        
    }   
    
    // MARK:  UITextFieldDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTicker.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath as IndexPath) as! CoinTableViewCell
        
        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(getTicker[row].id).png")!
        cell.coinImageView.af_setImage(withURL: url)
        cell.coinNameLabel.text = getTicker[row].name
        cell.priceCoinLabel.text = String(getTicker[row].price_usd)
        
        if getTicker[row].percent_change_24h >= 0 {
            cell.percentChange_24h_View.backgroundColor = UIColor.darkGray
            cell.percentChange_24h_View.alpha = 0.75
        }
        else{
            cell.percentChange_24h_View.backgroundColor = .red
            cell.percentChange_24h_View.alpha = 0.75
        }
        
        cell.percent_change_24h_Label.text = String(getTicker[row].percent_change_24h) + "%"
        
        
        
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
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        update()
        refreshControl.endRefreshing()
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentIndexPath = indexPath as NSIndexPath
        self.performSegue(withIdentifier: "cryptocurrencyInfoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "cryptocurrencyInfoSegue" {
            if let destinationVC = segue.destination as? CryptocurrencyInfoViewController {
                destinationVC.coinName = getTicker[currentIndexPath?.row]
            }
        }
    }
    */
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cryptocurrencyInfoSegue" {
            if let CryptocurrencyInfoVC = segue.destination as? CryptocurrencyInfoViewController {
                if let index = tableView.indexPathForSelectedRow?.row {
                    CryptocurrencyInfoVC.ticker = getTicker[index]
                }
            }
        }
        if segue.identifier == "cryptocurrencyEditSegue" {
            if let CryptocurrencyInfoVC = segue.destination as? EditViewController {
                    CryptocurrencyInfoVC.ticker = getTicker
            }
        }
    }
    
}



