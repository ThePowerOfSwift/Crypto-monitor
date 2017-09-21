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
                
                switch userDefaults.integer(forKey: "percentChange") {
                case 0:
                    if let percent_change_1h = ticker.percent_change_1h {
                        percentChangeLabel.setText(percent_change_1h + " %")
                    }
                    else{
                        percentChangeLabel.setText("null")
                    }
                    backgroundColorView(percentChange: ticker.percent_change_1h)
                case 1:
                    if let percent_change_24h = ticker.percent_change_24h {
                        percentChangeLabel.setText(percent_change_24h + " %")
                    }
                    else{
                        percentChangeLabel.setText("null")
                    }
                    backgroundColorView(percentChange: ticker.percent_change_24h)
                case 2:
                    if let percent_change_7d = ticker.percent_change_7d {
                        percentChangeLabel.setText(percent_change_7d + " %")
                    }
                    else{
                        percentChangeLabel.setText("null")
                    }
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
                    //priceLabel.setText(formatter.string(from: ticker.price_usd as NSNumber))
                    priceLabel.setText("$" + ticker.price_usd)
                case 1:
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 25
                    priceLabel.setText("₿" + ticker.price_btc)
                default:
                    break
                }
            }
        }
    }
    
    private func backgroundColorView(percentChange: String?) {
        if let percentChange = percentChange{
            if Float(percentChange)! >= 0 {
                cellMainGroup.setBackgroundColor(UIColor(red:0.02, green:0.87, blue:0.44, alpha:0.86))
            }
            else{
                cellMainGroup.setBackgroundColor(UIColor(red:0.98, green:0.07, blue:0.31, alpha:0.83))
            }
        }
        else{
            cellMainGroup.setBackgroundColor(UIColor(red:1.00, green:0.90, blue:0.13, alpha:0.86))
        }
    }
    
}

