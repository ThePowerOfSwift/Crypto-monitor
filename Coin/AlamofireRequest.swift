//
//  Coinmarketcap.swift
//  Karbowanec
//
//  Created by Mialin Valentin on 07.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class CurrencyCharts: Codable {
    public var market_cap_by_available_supply:[Chart]
    public var price_btc:[Chart]
    public var price_usd:[Chart]
    public var volume_usd:[Chart]
    
    public init(market_cap_by_available_supply:[Chart], price_btc:[Chart], price_usd:[Chart], volume_usd:[Chart]) {
        self.market_cap_by_available_supply = market_cap_by_available_supply
        self.price_btc = price_btc
        self.price_usd = price_usd
        self.volume_usd = volume_usd
    }
}


public class Chart: Codable {
    public var timestamp:Double
    public var item:Double
    
    public init(timestamp:Double, value:Double) {
        self.timestamp = timestamp
        self.item = value
    }
}

public struct Ticker: Decodable {
    public let id:String
    public let name:String
    public let symbol:String
    public let rank:String
    public let price_usd:String?
    public let price_btc:String?
    public let volume_usd_24h:String?
    public let market_cap_usd:String?
    public let percent_change_1h:String?
    public let percent_change_24h:String?
    public let percent_change_7d:String?
    public let price_eur:String?
    public let volume_eur_24h:String?
    public let market_cap_eur:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case rank
        case price_usd
        case price_btc
        case volume_usd_24h = "24h_volume_usd"
        case market_cap_usd
        case percent_change_1h
        case percent_change_24h
        case percent_change_7d
        case price_eur
        case volume_eur_24h = "24h_volume_eur"
        case market_cap_eur = "market_cap_eur"
    }

    public enum currency:String {
        case USD = "USD"
        case BTC = "BTC"
        case EUR = "EUR"
    }
    
    func formatterCurrency(currency: currency, maximumFractionDigits: Int) -> NumberFormatter {
        let formatterCurrency = NumberFormatter()
        formatterCurrency.numberStyle = .currency
        formatterCurrency.currencyCode = currency.rawValue
        formatterCurrency.locale = Locale(identifier: "en_US")
        formatterCurrency.maximumFractionDigits = maximumFractionDigits
        return formatterCurrency
    }

    public func priceUsdToString(maximumFractionDigits: Int) -> String {
        if let priceUsd = price_usd, let priceUsdDouble = Double(priceUsd) {
            let formatterCurrencyUSD = formatterCurrency(currency: .USD, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrencyUSD.string(from: NSNumber(value: priceUsdDouble))!
        }
        else{
            return "null"
        }
    }
    
    public func priceEurToString(maximumFractionDigits: Int) -> String {
        if let priceEur = price_eur, let priceEurDouble = Double(priceEur) {
            let formatterCurrencyEUR = formatterCurrency(currency: .EUR, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrencyEUR.string(from: NSNumber(value: priceEurDouble))!
        }
        else{
            return "null"
        }
    }
    
    public func priceBtcToString() -> String {
        return price_btc != nil ? "₿" + price_btc! : "null"
    }

    public func marketCapToString(currency: currency, maximumFractionDigits: Int) -> String {
        var marketCap: String?
        switch currency {
        case .USD:
            marketCap = market_cap_usd
        case .EUR:
            marketCap = market_cap_eur
        default:
            break
        }
        if let marketCap = marketCap, let marketCapDouble = Double(marketCap) {
            let formatterCurrency = self.formatterCurrency(currency: currency, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrency.string(from: NSNumber(value: marketCapDouble))!
        }
        else{
            return "null"
        }
    }
    
    public func volumeToString(currency: currency, maximumFractionDigits: Int) -> String {
        var volume: String?
        switch currency {
        case .USD:
            volume = volume_usd_24h
        case .EUR:
            volume = volume_eur_24h
        default:
            break
        }
        if let volume = volume, let volumeDouble = Double(volume) {
            let formatterCurrency = self.formatterCurrency(currency: currency, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrency.string(from: NSNumber(value: volumeDouble))!
        }
        else{
            return "null"
        }
    }
    
    public func priceCurrency() -> String {
        switch NSUbiquitousKeyValueStore().longLong(forKey: "priceCurrency") {
        case 0:
            guard let priceUsd = price_usd, let priceUsdInt = Double(priceUsd) else { return "null" }
            if priceUsdInt > 0.0001 {
                return priceUsdToString(maximumFractionDigits: 4)
            }
            else{
                return priceUsdToString(maximumFractionDigits: 8)
            }
        case 1:
            return priceBtcToString()
        case 2:
            guard let priceEur = price_eur, let priceEurDouble = Double(priceEur) else { return "null" }
            if priceEurDouble > 0.0001 {
                return priceEurToString(maximumFractionDigits: 4)
            }
            else{
                return priceEurToString(maximumFractionDigits: 8)
            }
        default:
            break
        }
        return "null"
    }
    
    public func percentChangeCurrent() -> String {
        var percentChange:String?
        switch NSUbiquitousKeyValueStore().longLong(forKey: "percentChange") {
        case 0:
            percentChange = percent_change_1h
        case 1:
            percentChange = percent_change_24h
        case 2:
            percentChange = percent_change_7d
        default:
            break
        }
        
        if let percentChange = percentChange {
            return percentChange
        }
        else{
            return "null"
        }
    }
}

extension Ticker {
    public func encode() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(id, forKey: "id")
        archiver.encode(name, forKey: "name")
        archiver.encode(symbol, forKey: "symbol")
        archiver.encode(rank, forKey: "rank")
        archiver.encode(price_usd, forKey: "price_usd")
        archiver.encode(price_btc, forKey: "price_btc")
        archiver.encode(volume_usd_24h, forKey: "volume_usd_24h")
        archiver.encode(market_cap_usd, forKey: "market_cap_usd")
        archiver.encode(percent_change_1h, forKey: "percent_change_1h")
        archiver.encode(percent_change_24h, forKey: "percent_change_24h")
        archiver.encode(percent_change_7d, forKey: "percent_change_7d")
        archiver.encode(price_eur, forKey: "price_eur")
        archiver.encode(volume_eur_24h, forKey: "volume_eur_24h")
        archiver.encode(market_cap_eur, forKey: "market_cap_eur")
        archiver.finishEncoding()
        return data as Data
    }
    
    public init?(data: Data) {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        defer {
          unarchiver.finishDecoding()
        }
        let id = unarchiver.decodeObject(forKey: "id") as! String
        let name = unarchiver.decodeObject(forKey: "name") as! String
        let symbol = unarchiver.decodeObject(forKey: "symbol") as! String
        let rank = unarchiver.decodeObject(forKey: "rank") as! String
        let price_usd = unarchiver.decodeObject(forKey: "price_usd") as? String
        let price_btc = unarchiver.decodeObject(forKey: "price_btc") as? String
        let volume_usd_24h = unarchiver.decodeObject(forKey: "volume_usd_24h") as? String
        let market_cap_usd = unarchiver.decodeObject(forKey: "market_cap_usd") as? String
        let percent_change_1h = unarchiver.decodeObject(forKey: "percent_change_1h") as? String
        let percent_change_24h = unarchiver.decodeObject(forKey: "percent_change_24h") as? String
        let percent_change_7d = unarchiver.decodeObject(forKey: "percent_change_7d") as? String
        let price_eur = unarchiver.decodeObject(forKey: "price_eur") as? String
        let volume_eur_24h = unarchiver.decodeObject(forKey: "volume_eur_24h") as? String
        let market_cap_eur = unarchiver.decodeObject(forKey: "market_cap_eur") as? String
        
        self.id = id
        self.name = name
        self.symbol = symbol
        self.rank = rank
        self.price_usd = price_usd
        self.price_btc = price_btc
        self.volume_usd_24h = volume_usd_24h
        self.market_cap_usd = market_cap_usd
        self.percent_change_1h = percent_change_1h
        self.percent_change_24h = percent_change_24h
        self.percent_change_7d = percent_change_7d
        self.price_eur = price_eur
        self.volume_eur_24h = volume_eur_24h
        self.market_cap_eur = market_cap_eur

    }
}

public class AlamofireRequest {
    public init() {}

    public func getTicker(completion: @escaping  ([Ticker]?, Error?) -> ()) {
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?convert=EUR&limit=0").validate().responseData { response in
            switch response.result {
            case .success(let responseData):
                print("Validation Successful getTicker2")
                
                let decoder = JSONDecoder()
                do {
                    let tickerDecodeArray = try decoder.decode([Ticker].self, from: responseData)
                    completion(tickerDecodeArray, nil)
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func getTickerID(idArray: [String], completion: @escaping  ([Ticker]?, Error?) -> ()) {
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?convert=EUR&limit=0").validate().responseData { response in
            switch response.result {
            case .success(let responseData):
                print("Validation Successful getTickerID")
                
                let decoder = JSONDecoder()
                do {
                    var tickerFilterArray = [Ticker]()
                    let tickerDecodeArray = try decoder.decode([Ticker].self, from: responseData)
                    for id in idArray{
                        if let json = tickerDecodeArray.filter({ $0.id == id}).first{
                            tickerFilterArray.append(json)
                        }
                    }
                    completion(tickerFilterArray, nil)
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    public func getCurrencyCharts(id: String, of: NSDate?, completion: @escaping  (CurrencyCharts?, Error?) -> ()) {
        
        var currencyCharts:CurrencyCharts?
        var error:Error?
        var url = "https://graphs.coinmarketcap.com/currencies/" + id + "/"
        
        if let of = of {
            url += String(Int(of.timeIntervalSince1970)) + "000/" + String(Int(NSDate().timeIntervalSince1970)) + "000/"
        }
        let configuration = URLSessionConfiguration.default
        //  configuration.timeoutIntervalForRequest = 60
        configuration.urlCache = nil
        let  sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        sessionManager.request(url).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                
                let json = JSON(value)
                
                var market_cap_by_available_supply = [Chart]()
                var price_btc = [Chart]()
                var price_usd = [Chart]()
                var volume_usd = [Chart]()
                
                for item in json["market_cap_by_available_supply"].arrayValue {
                    market_cap_by_available_supply.append(Chart(timestamp: item[0].doubleValue, value: item[1].doubleValue))
                }
                for item in json["price_btc"].arrayValue {
                    price_btc.append(Chart(timestamp: item[0].doubleValue, value: item[1].doubleValue))
                }
                for item in json["price_usd"].arrayValue {
                    price_usd.append(Chart(timestamp: item[0].doubleValue, value: item[1].doubleValue))
                }
                for item in json["volume_usd"].arrayValue {
                    volume_usd.append(Chart(timestamp: item[0].doubleValue, value: item[1].doubleValue))
                }
                
                currencyCharts = CurrencyCharts(market_cap_by_available_supply: market_cap_by_available_supply,
                                                price_btc: price_btc,
                                                price_usd: price_usd,
                                                volume_usd: volume_usd)
                
            case .failure(let errorFailure):
                error = errorFailure
            }
            completion(currencyCharts, error)
            
            sessionManager.session.invalidateAndCancel()
        }
        
    }

    
    public func getMinDateCharts(id: String, completion: @escaping  (Date?, Error?) -> ()) {
        
        var minDate:Date?
        var error:Error?
        
        let url = "https://graphs.coinmarketcap.com/currencies/" + id
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        let  sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        
        sessionManager.request(url).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                
                let json = JSON(value)
                
                let timestamp = json["price_usd"].arrayValue
                
                if !timestamp.isEmpty {
                    minDate = NSDate(timeIntervalSince1970: TimeInterval(timestamp[0][0].doubleValue / 1000)) as Date?
                }
    
            case .failure(let errorFailure):
                error = errorFailure
            }
            completion(minDate , error)
            
            sessionManager.session.invalidateAndCancel()
        }
    }
}

public class SettingsUserDefaults{
    
    public init() {}
    
    public func setUserDefaults(ticher: [Ticker], idArray: [String], lastUpdate: Date?) {

        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        userDefaults?.set(idArray, forKey: "id")
        
        let tickersData = ticher.map { $0.encode() }
        userDefaults?.set(tickersData, forKey: "tickers")
        if lastUpdate != nil{
            userDefaults?.set(lastUpdate, forKey: "lastUpdate")
        }
        userDefaults?.synchronize()
    }
    
    public func loadcacheTicker() -> ([Ticker]?){
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        var cacheTicker:[Ticker]?
        if let decodedTicker = userDefaults?.object(forKey: "tickers") as? [Data] {
            cacheTicker = decodedTicker.map { Ticker(data: $0) } as? [Ticker]
        }
        return cacheTicker
    }
    

}



