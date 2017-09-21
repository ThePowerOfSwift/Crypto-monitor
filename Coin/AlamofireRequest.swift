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

public class Ticker: NSObject, NSCoding, Codable{
    
    public var id:String?
    public var name:String?
    public var symbol:String?
    public var rank:String?
    public var price_usd:String?
    public var price_btc:String?
    public var volume_usd_24h:String?
    public var market_cap_usd:String?
    public var available_supply:String?
    public var total_supply:String?
    public var percent_change_1h:String?
    public var percent_change_24h:String?
    public var percent_change_7d:String?
 

    public init(id:String?,
                name:String?,
                symbol:String?,
                rank:String?,
                price_usd:String?,
                price_btc:String?,
                volume_usd_24h:String?,
                market_cap_usd:String?,
                percent_change_1h:String?,
                percent_change_24h:String?,
                percent_change_7d:String?){
        
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
    }
    
    required public init(coder decoder: NSCoder) {
        self.id =  decoder.decodeObject(forKey: "id") as? String
        self.name =  decoder.decodeObject(forKey: "name") as? String
        self.symbol = decoder.decodeObject(forKey: "symbol") as? String
        self.rank = decoder.decodeObject(forKey: "rank") as? String
        self.price_usd = decoder.decodeObject(forKey: "price_usd") as? String
        self.price_btc = decoder.decodeObject(forKey: "price_btc") as? String
        self.volume_usd_24h = decoder.decodeObject(forKey: "volume_usd_24h") as? String
        self.market_cap_usd = decoder.decodeObject(forKey: "market_cap_usd") as? String
        self.percent_change_1h = decoder.decodeObject(forKey: "percent_change_1h") as? String
        self.percent_change_24h = decoder.decodeObject(forKey: "percent_change_24h") as? String
        self.percent_change_7d = decoder.decodeObject(forKey: "percent_change_7d") as? String
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(symbol, forKey: "symbol")
        coder.encode(rank, forKey: "rank")
        coder.encode(price_usd, forKey: "price_usd")
        coder.encode(price_btc, forKey: "price_btc")
        coder.encode(volume_usd_24h, forKey: "volume_usd_24h")
        coder.encode(market_cap_usd, forKey: "market_cap_usd")
        coder.encode(percent_change_1h, forKey: "percent_change_1h")
        coder.encode(percent_change_24h, forKey: "percent_change_24h")
        coder.encode(percent_change_7d, forKey: "percent_change_7d")
    }
    
}

public class AlamofireRequest {
    public init() {}

    public func getTicker(completion: @escaping  ([Ticker]?, Error?) -> ()) {
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/").validate().responseData { response in
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
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/").validate().responseData { response in
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
    /*
    public func getCurrencyCharts(id: String, of: NSDate?, completion: @escaping  (CurrencyCharts?, Error?) -> ()) {

        var url = "https://graphs.coinmarketcap.com/currencies/" + id + "/"
        if let of = of {
            url += String(Int(of.timeIntervalSince1970)) + "000/" + String(Int(NSDate().timeIntervalSince1970)) + "000/"
        }
        let configuration = URLSessionConfiguration.default
        //  configuration.timeoutIntervalForRequest = 60
        configuration.urlCache = nil
        let  sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        sessionManager.request(url).validate().responseData { response in
            
            switch response.result {
            case .success(let responseData):
                print("Validation Successful getCurrencyCharts")
                
                let decoder = JSONDecoder()
                do {
                    let tickerDecodeArray = try decoder.decode(CurrencyCharts2.self, from: responseData)
                   // completion(tickerDecodeArray, nil)
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
            sessionManager.session.invalidateAndCancel()
        }
    }
    */
    /*
    public func getTickerID(idArray: [String], completion: @escaping  ([Ticker]?, Error?) -> ()) {
        
        var tickerArray = [Ticker]()
        var error:Error?
        
        
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/").validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                
                let json = JSON(value).arrayValue
                var jsonIdArray = [JSON]()
                
                for id in idArray{
                    if let json = json.filter({ $0["id"].stringValue == id}).first{
                        jsonIdArray.append(json)
                    }
                }
                
                for item in jsonIdArray {
                        tickerArray.append(self.jsonToTicker(json: item))
                }
            case .failure(let errorFailure):
                error = errorFailure
            }
            completion(tickerArray, error)
        }
    }
 
    
    private func jsonToTicker(json: JSON) -> Ticker {
       return Ticker(id: json["id"].stringValue,
                            name: json["name"].stringValue,
                            symbol: json["symbol"].stringValue,
                            rank: json["rank"].stringValue,
                            price_usd: json["price_usd"].stringValue,
                            price_btc: json["price_btc"].stringValue,
                            volume_usd_24h: json["24h_volume_usd"].stringValue,
                            market_cap_usd: json["market_cap_usd"].stringValue,
                            percent_change_1h: json["percent_change_1h"].stringValue,
                            percent_change_24h: json["percent_change_24h"].stringValue,
                            percent_change_7d: json["percent_change_7d"].stringValue)
    }
    */
    
  
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
                
                let timestamp = json["price_usd"].arrayValue[0][0].doubleValue
                minDate = NSDate(timeIntervalSince1970: TimeInterval(timestamp / 1000)) as Date?
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
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: ticher)
        let userDefaults = UserDefaults(suiteName: "group.mialin.valentyn.crypto.monitor")
        userDefaults?.set(idArray, forKey: "id")
        userDefaults?.set(encodedData, forKey: "cryptocurrency")
        if lastUpdate != nil{
            userDefaults?.set(lastUpdate, forKey: "lastUpdate")
        }
        userDefaults?.synchronize()
    }

}



