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
    
     var loadSubview:LoadSubview?
    
    @IBOutlet weak var test: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)  // not required when using UITableViewController


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
        
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        var percentChange = Float()
        
        switch keyStore.longLong(forKey: "percentChange") {
        case 0:
            percentChange = cryptocurrency[row].percent_change_1h
        case 1:
            percentChange = cryptocurrency[row].percent_change_24h
        case 2:
            percentChange = cryptocurrency[row].percent_change_7d
        default:
            percentChange = cryptocurrency[row].percent_change_24h
        }
        
        if percentChange >= 0 {
            cell.percentChangeView.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
        }
        else{
            cell.percentChangeView.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
        }
        cell.percentChangeLabel.text = String(percentChange) + " %"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
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
        headerView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        headerView.insertSubview(blurEffectView, at: 0)
        

        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 20
    }
    
    func update() {
        if !self.tableView.isEditing {
            
            showLoadSubview()
            

            AlamofireRequest().getTicker(id : "sd", completion: { (ticker : [Ticker]?) in

                if let ticker = ticker {
                    self.getTicker = ticker
                }
                
                //update your table data here
                DispatchQueue.main.async() {
                    self.cryptocurrencyView()
                    self.closeLoadSubview()
                }
            })
        }
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        update()
        refreshControl.endRefreshing()
    }
    
    //MARK:LoadSubview
    func showLoadSubview() {
        closeLoadSubview()
        self.loadSubview = LoadSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view.addSubview(self.loadSubview!)
    }
    
    func closeLoadSubview() {
        for view in self.view.subviews {
            if view is LoadSubview {
                view.removeFromSuperview()
            }
        }
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



