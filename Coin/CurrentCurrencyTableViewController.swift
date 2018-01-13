//
//  CurrentCurrencyTableViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 13.01.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency

class CurrentCurrencyTableViewController: UITableViewController {

    var money = [String]()
    var currentCurrency = CryptoCurrencyKit.Money.usd
    
    override func viewDidLoad() {
        super.viewDidLoad()
        money = CryptoCurrencyKit.Money.allRawValues
        currentCurrency = SettingsUserDefaults().getCurrentCurrency()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return money.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentSymbol", for: indexPath) as! CurrentCurrencyTableViewCell
        let row = indexPath.row
        
        cell.symbol.text = money[row]
        
        if money[row] == currentCurrency.rawValue {
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print(row)
    
        SettingsUserDefaults().setCurrentCurrency(money: CryptoCurrencyKit.Money(rawValue: money[row])!)
        _ = navigationController?.popViewController(animated: true)
    }
}
