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

    var money : [CryptoCurrencyKit.Money] = CryptoCurrencyKit.Money.allValues

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return money.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentSymbol", for: indexPath) as! CurrentCurrencyTableViewCell
        let row = indexPath.row
        
        cell.symbol.text = money[row].flag + " " + money[row].rawValue
        
        let currentCurrency = SettingsUserDefaults.getCurrentCurrency()
        
        if money[row].rawValue == currentCurrency.rawValue {
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        SettingsUserDefaults.setCurrentCurrency(money: CryptoCurrencyKit.Money(rawValue: money[row].rawValue)!)
        NotificationCenter.default.post(name: .newCurrentCurrency, object: nil, userInfo: nil)
        _ = navigationController?.popViewController(animated: true)
    }
}
