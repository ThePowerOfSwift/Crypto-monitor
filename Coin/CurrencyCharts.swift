//
//  CurrencyCharts.swift
//  Coin
//
//  Created by Mialin Valentin on 17.05.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation

class Chart: Codable {
    var timestamp:Double
    var item:Double
    
    init(timestamp:Double, value:Double) {
        self.timestamp = timestamp
        self.item = value
    }
}

class CurrencyCharts: Codable {
    var market_cap_by_available_supply:[Chart]
    var price_btc:[Chart]
    var price_usd:[Chart]
    var volume_usd:[Chart]
    
    init(market_cap_by_available_supply:[Chart], price_btc:[Chart], price_usd:[Chart], volume_usd:[Chart]) {
        self.market_cap_by_available_supply = market_cap_by_available_supply
        self.price_btc = price_btc
        self.price_usd = price_usd
        self.volume_usd = volume_usd
    }
}



