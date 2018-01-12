//
//  CacheTicker.swift
//  Crypto monitor Watch Extension
//
//  Created by Mialin Valentin on 12.10.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit

class CacheTicker {
    public func loadcacheTicker() -> ([Ticker]?){
        var cacheTicker:[Ticker]?

        if let decodedTicker = UserDefaults().object(forKey: "tickers") as? [Data] {
            cacheTicker = decodedTicker.map { Ticker(data: $0) } as? [Ticker]
        }
        return cacheTicker
    }
    
    public func setUserDefaults(ticher: [Ticker]?) {
        
        let userDefaults = UserDefaults()
        if let ticher = ticher {
            let tickersData = ticher.map { $0.encode() }
            userDefaults.set(tickersData, forKey: "tickers")
        }
        else{
            userDefaults.removeObject(forKey: "tickers")
        }
        
        userDefaults.synchronize()
    }
}

