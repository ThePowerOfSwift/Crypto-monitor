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
                
                symbolLabel.setText(ticker.symbol)
                percentChangeLabel.setText(String(ticker.percent_change_7d) + " %")
                priceLabel.setText("$ " + String(ticker.price_usd))
                
                if ticker.percent_change_7d >= 0 {
                    cellMainGroup.setBackgroundColor(UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0))
                }
                else{
                    cellMainGroup.setBackgroundColor( UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0))
                }
            }
        }
    }
    
}

