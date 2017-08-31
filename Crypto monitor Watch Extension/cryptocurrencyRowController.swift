//
//  cryptocurrencyRowController.swift
//  Coin
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit

class cryptocurrencyRowController: NSObject {
    
    @IBOutlet var symbolLabel: WKInterfaceLabel!
    @IBOutlet var percentChangeLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var cellMainGroup: WKInterfaceGroup!
    
    var ticker:Ticker?{
        didSet {
            if let ticker = ticker {
                
                let userDefaults = UserDefaults()
                
                symbolLabel.setText(ticker.symbol)
                percentChangeLabel.setText(String(ticker.percent_change_7d) + " %")
                
                switch userDefaults.integer(forKey: "percentChange") {
                case 0:
                    percentChangeLabel.setText(String(ticker.percent_change_1h) + " %")
                    backgroundColorView(percentChange: ticker.percent_change_1h)
                case 1:
                    percentChangeLabel.setText(String(ticker.percent_change_24h) + " %")
                    backgroundColorView(percentChange: ticker.percent_change_24h)
                case 2:
                    percentChangeLabel.setText(String(ticker.percent_change_7d) + " %")
                    backgroundColorView(percentChange: ticker.percent_change_7d)
                default:
                    break
                }
                
                switch userDefaults.integer(forKey: "priceCurrency") {
                case 0:
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.maximumFractionDigits = 25
                    formatter.locale = Locale(identifier: "en_US")
                    priceLabel.setText(formatter.string(from: ticker.price_usd as NSNumber))
                case 1:
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 25
                    priceLabel.setText("₿ " + formatter.string(from: ticker.price_btc as NSNumber)!)
                default:
                    break
                }
            }
        }
    }
    
    private func backgroundColorView(percentChange: Float) {
        if percentChange >= 0 {
            cellMainGroup.setBackgroundColor(UIColor(red:0.02, green:0.87, blue:0.44, alpha:0.86))
        }
        else{
            cellMainGroup.setBackgroundColor(UIColor(red:0.98, green:0.07, blue:0.31, alpha:0.83))
        }
    }
    
}

