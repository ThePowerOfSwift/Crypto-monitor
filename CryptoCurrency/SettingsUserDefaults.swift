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
    
    public func setUserDefaults(ticher: [Ticker], idArray: [String], lastUpdate: Date?) {
        
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        userDefaults?.set(idArray, forKey: "id")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        
            let encodedStore = try encoder.encode(ticher)
            userDefaults?.set(encodedStore, forKey: "tickers")
            
            
            if lastUpdate != nil{
                userDefaults?.set(lastUpdate, forKey: "lastUpdate")
            }
            userDefaults?.synchronize()
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        
        
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
    
    #if os(iOS)
    public func setCurrentCurrency(money: CryptoCurrencyKit.Money) {
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(money.rawValue, forKey: "CurrentCurrency")
        keyStore.synchronize()
    }
    
    public func getCurrentCurrency() ->  CryptoCurrencyKit.Money {
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

        guard let currentCurrencyString = keyStore.string(forKey: "CurrentCurrency") else { return CryptoCurrencyKit.Money.usd }
        guard let currentCurrency = CryptoCurrencyKit.Money(rawValue: currentCurrencyString) else { return CryptoCurrencyKit.Money.usd }
        
        return currentCurrency
    }
    #endif
    
}
