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
    fileprivate var cryptocurrencyCompact = [Ticker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let decoded = UserDefaults.standard.data(forKey: "cryptocurrency") {
            if let cache = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Ticker] {
                cryptocurrency = cache
                
                cryptocurrencyCompact.removeAll()
                for i in 0..<2 {
                    cryptocurrencyCompact.append(cryptocurrency[i])
                }
                tableView.reloadData()
            }
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        let keyStore = NSUbiquitousKeyValueStore ()
        if  let idArray = keyStore.array(forKey: "id") as? [String] {
            
            print(idArray)

        AlamofireRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
            if error == nil {
                if let ticker = ticker {
                    print(ticker.count)

                            self.cryptocurrency = ticker
                            self.cryptocurrencyCompact.removeAll()
                            for i in 0..<2 {
                                  self.cryptocurrencyCompact.append(self.cryptocurrency[i])
                            }
         
                            
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.cryptocurrency )
                            UserDefaults.standard.set(encodedData, forKey: "cryptocurrency")
                            
                            //update your table data here
                            DispatchQueue.main.async() {
                                if !self.tableView.isEditing {
                                self.tableView.reloadData()
                                }
                            }
                        }
                        else{
                            print("idArray empty!")
                        }
                    
                    completionHandler(NCUpdateResult.newData)
                }
              else{
                completionHandler(NCUpdateResult.failed)
            }
        })
        }
    }

    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == .compact
        {
            print("compact")
            preferredContentSize = maxSize
            tableView.reloadData()
        }
        else{
            if activeDisplayMode == .expanded
            {
                print("expanded")
                preferredContentSize = CGSize(width: 0.0, height: 44.0 * CGFloat(self.cryptocurrency.count))
                tableView.reloadData()
            }
        }
        }
        
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if extensionContext?.widgetActiveDisplayMode == .compact {
            return cryptocurrencyCompact.count
        }
        return cryptocurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath) as! WidgetCellTableViewCell
        
        var cryptocurrencyShow = [Ticker]()
        
        if extensionContext?.widgetActiveDisplayMode == .compact {
            cryptocurrencyShow = cryptocurrencyCompact
        }
        else{
            cryptocurrencyShow = cryptocurrency
        }
        
        
        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(cryptocurrencyShow[row].id).png")!
        cell.coinImageView.af_setImage(withURL: url)
        cell.coinNameLabel.text = cryptocurrencyShow[row].name
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        switch keyStore.longLong(forKey: "priceCurrency") {
        case 0:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 25
            formatter.locale = Locale(identifier: "en_US")
            
            cell.priceCoinLabel.text = formatter.string(from: cryptocurrencyShow[row].price_usd as NSNumber)
          
        case 1:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            
            cell.priceCoinLabel.text = "₿" + formatter.string(from: cryptocurrencyShow[row].price_btc as NSNumber)!
        default:
            break
        }
        
        var percentChange = Float()
        
        switch keyStore.longLong(forKey: "percentChange") {
        case 0:
            percentChange = cryptocurrencyShow[row].percent_change_1h
        case 1:
            percentChange = cryptocurrencyShow[row].percent_change_24h
        case 2:
            percentChange = cryptocurrencyShow[row].percent_change_7d
        default:
            percentChange = cryptocurrencyShow[row].percent_change_24h
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        
      //  print(cryptocurrency[indexPath.row].name)
        
        let myAppUrl = URL(string: "cryptomonitor://?id=\(cryptocurrency[indexPath.row].id)")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
      
        //self.extensionContext?.open(URL(string: "NearbyRestaurantsTodayExtension://\((self.nearbyRestaurantsArray.count == 0) ? "" : self.nearbyRestaurantsArray[indexPath.row].placeID)")!, completionHandler: nil)
    }
}
