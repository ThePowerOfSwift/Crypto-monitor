//
//  TodayViewController.swift
//  Cryptocurrency monitor widget
//
//  Created by Mialin Valentin on 01.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import NotificationCenter
import CryptocurrencyRequest
import AlamofireImage

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
    
    @IBOutlet weak var tableView: UITableView!

   fileprivate var cryptocurrency = [Ticker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.


	extensionContext?.widgetLargestAvailableDisplayMode = .expanded

   
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let decoded = UserDefaults.standard.data(forKey: "cryptocurrency") {
            if let decodedTicker = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Ticker] {
                
                print("Cache")

                cryptocurrency = decodedTicker
                tableView.reloadData()
            }
            
        }
    }
    

    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        AlamofireRequest().getTicker(completion: { (ticker : [Ticker]?, error : Error?) in
            if error == nil {
                if let ticker = ticker {
                    
                    let keyStore = NSUbiquitousKeyValueStore ()
                    var cryptocurrencyTemp = [Ticker]()
                    
                    if let idArray = keyStore.array(forKey: "id") as? [String] {
                        if !idArray.isEmpty{
                            for id in idArray {
                                if let tick = ticker.first(where: {$0.id == id}) {
                                    cryptocurrencyTemp.append(tick)
                                }
                            }
                            self.cryptocurrency = cryptocurrencyTemp
                            
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.cryptocurrency )
                            UserDefaults.standard.set(encodedData, forKey: "cryptocurrency")
                            
                            //update your table data here
                            DispatchQueue.main.async() {
                                self.tableView.reloadData()
                            }
                        }
                        else{
                            print("idArray empty!")
                        }
                    }
                    completionHandler(NCUpdateResult.newData)
                }
            }
            else{
                completionHandler(NCUpdateResult.failed)
            }
        })
    }

    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            let height = 44.0 * Float(cryptocurrency.count)
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
        }
        else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath) as! WidgetCellTableViewCell
        
        
        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(cryptocurrency[row].id).png")!
        cell.coinImageView.af_setImage(withURL: url)
        cell.coinNameLabel.text = cryptocurrency[row].name
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 25
            formatter.locale = Locale(identifier: "en_US")
            
            UIView.animate(withDuration: 0.5, animations: {
            cell.priceCoinLabel.text = formatter.string(from: self.cryptocurrency[row].price_usd as NSNumber)
            })
            
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
    
    //Mark:Load
    /*
    func loadTicker() {
        AlamofireRequest().getTicker(completion: { (ticker : [Ticker]?, error : Error?) in
            if error == nil {
                if let ticker = ticker {
                    
                    let keyStore = NSUbiquitousKeyValueStore ()
                    var cryptocurrencyTemp = [Ticker]()
                    
                    if let idArray = keyStore.array(forKey: "id") as? [String] {
                        if !idArray.isEmpty{
                            for id in idArray {
                                if let tick = ticker.first(where: {$0.id == id}) {
                                    cryptocurrencyTemp.append(tick)
                                }
                            }
                            self.cryptocurrency = cryptocurrencyTemp
                        }
                        else{
                            print("idArray empty!")
                        }
                        
                    }
                    //update your table data here
                    DispatchQueue.main.async() {
                        self.tableView.reloadData()
                    }
                    
                }
            }
            else{
                //  self.showErrorSubview(error: error!)
            }
        })
    }
    */
    /*
    func cryptocurrencyView(ticker : [Ticker]) {
        
        cryptocurrency.removeAll()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if let idArray = keyStore.array(forKey: "id") as? [String] {
            if !idArray.isEmpty{
                for id in idArray {
                    if let tick = ticker.first(where: {$0.id == id}) {
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
            
            cryptocurrencyView(ticker: ticker)
 */
      //  }
  //  }
}
