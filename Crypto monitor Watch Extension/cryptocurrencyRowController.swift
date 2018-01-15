//
//  cryptocurrencyRowController.swift
//  Coin
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import CryptoCurrency


class cryptocurrencyRowController: NSObject {
    
    @IBOutlet var symbolLabel: WKInterfaceLabel!
    @IBOutlet var percentChangeLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var cellMainGroup: WKInterfaceGroup!
    
    var ticker:Ticker?{
        didSet {
            if let ticker = ticker {
                symbolLabel.setText(ticker.symbol)
                priceLabel.setText(ticker.priceCurrency())
                let percentChange = ticker.percentChangeCurrent()
                percentChangeLabel.setText(percentChange + " %")
                backgroundColorView(percentChange: percentChange)
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
            cellMainGroup.setBackgroundColor(UIColor.orange)
        }
    }
}

