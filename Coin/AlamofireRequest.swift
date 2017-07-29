//
//  Coinmarketcap.swift
//  Karbowanec
//
//  Created by Mialin Valentin on 07.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class CurrencyCharts {
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

class Chart {
    var timestamp:Double
    var item:Double
    
    init(timestamp:Double, value:Double) {
        self.timestamp = timestamp
        self.item = value
    }
    
    
}


class Ticker{
    
    var id:String
    var name:String
    var symbol:String
    var rank:Int
    var price_usd:Float
    var price_btc:Float
    var volume_usd_24h:Float
    var market_cap_usd:Float
    var available_supply:Float
    var total_supply:Float
    var percent_change_1h:Float
    var percent_change_24h:Float
    var percent_change_7d:Float
    var last_updated:NSDate
    
    init(id:String,
         name:String,
         symbol:String,
         rank:Int,
         price_usd:Float,
         price_btc:Float,
         volume_usd_24h:Float,
         market_cap_usd:Float,
         available_supply:Float,
         total_supply:Float,
         percent_change_1h:Float,
         percent_change_24h:Float,
         percent_change_7d:Float,
         last_updated:Int){
        
        self.id = id
        self.name = name
        self.symbol = symbol
        self.rank = rank
        self.price_usd = price_usd
        self.price_btc = price_btc
        self.volume_usd_24h = volume_usd_24h
        self.market_cap_usd = market_cap_usd
        self.available_supply = available_supply
        self.total_supply = total_supply
        self.percent_change_1h = percent_change_1h
        self.percent_change_24h = percent_change_24h
        self.percent_change_7d = percent_change_7d
        self.last_updated = NSDate(timeIntervalSince1970: TimeInterval(last_updated))
    }
    
}

class AlamofireRequest {

    func getTicker(completion: @escaping  ([Ticker]?, Error?) -> ()) {
        
        var tickerArray = [Ticker]()
        var error:Error?
        

        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/").validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                
                let json = JSON(value)
                
                for item in json.arrayValue {                    
                    
                    tickerArray.append(Ticker(id: item["id"].stringValue,
                                              name: item["name"].stringValue,
                                              symbol: item["symbol"].stringValue,
                                              rank: item["rank"].intValue,
                                              price_usd: item["price_usd"].floatValue,
                                              price_btc: item["price_btc"].floatValue,
                                              volume_usd_24h: item["24h_volume_usd"].floatValue,
                                              market_cap_usd: item["market_cap_usd"].floatValue,
                                              available_supply: item["available_supply"].floatValue,
                                              total_supply: item["total_supply"].floatValue,
                                              percent_change_1h: item["percent_change_1h"].floatValue,
                                              percent_change_24h: item["percent_change_24h"].floatValue,
                                              percent_change_7d: item["percent_change_7d"].floatValue,
                                              last_updated: item["last_updated"].intValue))
                }
            case .failure(let errorFailure):
                error = errorFailure
            }
            completion(tickerArray, error)
        }
    }
    
    func getCurrencyCharts(id: String, of: NSDate?, completion: @escaping  (CurrencyCharts?) -> ()) {
        
        var url = "https://graphs.coinmarketcap.com/currencies/" + id + "/"
        
        if let of = of {
            url += String(Int(of.timeIntervalSince1970 * 1000)) + "/" + String(Int(NSDate().timeIntervalSince1970 * 1000)) + "/"
        }
        
        print(url)
        
        Alamofire.request(url).validate().responseJSON { response in
            
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
                
                completion(CurrencyCharts(market_cap_by_available_supply: market_cap_by_available_supply,
                                          price_btc: price_btc,
                                          price_usd: price_usd,
                                          volume_usd: volume_usd))
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
