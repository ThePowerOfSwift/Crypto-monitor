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
    var errorSubview:ErrorSubview?
    
    @IBOutlet weak var test: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)  // not required when using UITableViewController


    }
    
    override func viewWillAppear(_ animated: Bool) {
        if getTicker.isEmpty {
            load()
        }
        else{
            cryptocurrencyView()
        }
    }
    
    func cryptocurrencyView() {
        
        self.refreshControl.endRefreshing()
        for view in self.view.subviews {
            if (view is LoadSubview || view is ErrorSubview) {
                view.removeFromSuperview()
            }
        }
        cryptocurrency.removeAll()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if let idArray = keyStore.array(forKey: "id") as? [String] {
            if !idArray.isEmpty{
                for id in idArray {
                    if let tick = getTicker.first(where: {$0.id == id}) {
                        cryptocurrency.append(tick)
                    }
                }
            }
            tableView.reloadData()
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
        
         let keyStore = NSUbiquitousKeyValueStore ()
        
        
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            cell.priceCoinLabel.text = CryptocurrencyInfoViewController().formatCurrency(value: cryptocurrency[row].price_usd)
            
        case 1:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            
            cell.priceCoinLabel.text = "₿" + formatter.string(from: cryptocurrency[row].price_btc as NSNumber)!
        default:
            break
        }

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
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            headerView.priceLabel.text = "Price (USD)"
        case 1:
            headerView.priceLabel.text = "Price (BTC)"
        default:
            headerView.priceLabel.text = "-"
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
    

    
    func loadTicker() {
        AlamofireRequest().getTicker(completion: { (ticker : [Ticker]?, error : Error?) in
            if error == nil {
                if let ticker = ticker {
                    self.getTicker = ticker
                }
                //update your table data here
                DispatchQueue.main.async() {
                    self.cryptocurrencyView()
                }
            }
            else{
                self.showErrorSubview(error: error!)
            }
        })
    }
    
    func load() {
        showLoadSubview()
        loadTicker()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        loadTicker()
        
        
    }
    
    func reload(_ sender:UIButton) {
        loadTicker()
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
    
    //MARK: ErrorSubview
    func showErrorSubview(error: Error) {
        closeErrorSubview()
        
        self.errorSubview = ErrorSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.errorSubview?.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.errorSubview?.insertSubview(blurEffectView, at: 0) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.errorSubview?.backgroundColor = UIColor.black
        }
        
        
        
        self.errorSubview?.errorStringLabel.text = error.localizedDescription
        self.errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)

        self.view.addSubview(self.errorSubview!)
    }
    
    func closeErrorSubview() {
        for view in self.view.subviews {
            if view is ErrorSubview {
                view.removeFromSuperview()
            }
        }
    }

    @IBAction func setting(_ sender: Any) {
        
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



