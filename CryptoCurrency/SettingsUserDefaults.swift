//
//  SettingsUserDefaults.swift
//  Coin
//
//  Created by Mialin Valentin on 12.01.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation


public class SettingsUserDefaults{
    
    public init() {}
    
    public func setUserDefaults(ticher: [Ticker]?, idArray: [String], lastUpdate: Date?) {
        var userDefaults: UserDefaults?
        #if os(iOS)
            userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        #endif
        
        #if os(watchOS)
            userDefaults = UserDefaults()
        #endif
        
        userDefaults?.set(idArray, forKey: "id")
        
        if let ticher = ticher {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do{
                
                let encodedStore = try encoder.encode(ticher)
                userDefaults?.set(encodedStore, forKey: "tickers")
                
                
                if lastUpdate != nil{
                    userDefaults?.set(lastUpdate, forKey: "lastUpdate")
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        userDefaults?.synchronize()
    }
    
    public func loadcacheTicker() -> ([Ticker]?){
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        var cacheTicker:[Ticker]?
        
        if let jsonTicker = userDefaults?.data(forKey: "tickers") {
            let decoder = JSONDecoder()
            do{
                cacheTicker = try decoder.decode([Ticker].self, from: jsonTicker)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        return cacheTicker
    }
    
    
    public func setCurrentCurrency(money: CryptoCurrencyKit.Money) {
        #if os(iOS)
            let keyStore = NSUbiquitousKeyValueStore()
        #endif
        
        #if os(watchOS)
            let keyStore = UserDefaults()
        #endif
        
        keyStore.set(money.rawValue, forKey: "CurrentCurrency")
        keyStore.synchronize()
    }
    
    
    public func getCurrentCurrency() ->  CryptoCurrencyKit.Money {
        #if os(iOS)
            let keyStore = NSUbiquitousKeyValueStore()
            if !keyStore.bool(forKey: "converPriceCurrencyToCurrentCurrency"){
                
                switch Int(keyStore.longLong(forKey: "priceCurrency")) {
                case 0:
                    SettingsUserDefaults().setCurrentCurrency(money: .usd)
                case 1:
                    SettingsUserDefaults().setCurrentCurrency(money: .btc)
                case 2:
                    SettingsUserDefaults().setCurrentCurrency(money: .eur)
                default:
                    break
                }
                keyStore.removeObject(forKey: "priceCurrency")
                keyStore.set(true, forKey: "converPriceCurrencyToCurrentCurrency")
                keyStore.synchronize()
                
            }
        #endif
        
        
        #if os(iOS)
            guard let currentCurrencyString = NSUbiquitousKeyValueStore().string(forKey: "CurrentCurrency") else { return CryptoCurrencyKit.Money.usd }
        #endif
        
        #if os(watchOS)
            guard let currentCurrencyString = UserDefaults().string(forKey: "CurrentCurrency") else { return CryptoCurrencyKit.Money.usd }
        #endif
        
        guard let currentCurrency = CryptoCurrencyKit.Money(rawValue: currentCurrencyString) else { return CryptoCurrencyKit.Money.usd }
        return currentCurrency
    }
    
    
}

