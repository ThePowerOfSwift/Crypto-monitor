//
//  NetworkRequest.swift
//  Coin
//
//  Created by Mialin Valentin on 27.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkRequest{
    
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
                      symbol: json["symbol"].stringValue,
                      price_usd: json["price_usd"].floatValue,
                      price_btc: json["price_btc"].floatValue,
                      percent_change_1h: json["percent_change_1h"].floatValue,
                      percent_change_24h: json["percent_change_24h"].floatValue,
                      percent_change_7d: json["percent_change_7d"].floatValue)
    }
}


class Ticker: NSObject, NSCoding{
    
    public var id:String
    public var symbol:String
    public var price_usd:Float
    public var price_btc:Float
    public var percent_change_1h:Float
    public var percent_change_24h:Float
    public var percent_change_7d:Float
    
    public init(id:String,
                symbol:String,
                price_usd:Float,
                price_btc:Float,
                percent_change_1h:Float,
                percent_change_24h:Float,
                percent_change_7d:Float){
        
        self.id = id
        self.symbol = symbol
        self.price_usd = price_usd
        self.price_btc = price_btc
        self.percent_change_1h = percent_change_1h
        self.percent_change_24h = percent_change_24h
        self.percent_change_7d = percent_change_7d
    }
    
    required public init(coder decoder: NSCoder) {
        self.id =  decoder.decodeObject(forKey: "id") as! String
        self.symbol = decoder.decodeObject(forKey: "symbol") as! String
        self.price_usd = decoder.decodeFloat(forKey: "price_usd")
        self.price_btc = decoder.decodeFloat(forKey: "price_btc")
        self.percent_change_1h = decoder.decodeFloat(forKey: "percent_change_1h")
        self.percent_change_24h = decoder.decodeFloat(forKey: "percent_change_24h")
        self.percent_change_7d = decoder.decodeFloat(forKey: "percent_change_7d")
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(symbol, forKey: "symbol")
        coder.encode(price_usd, forKey: "price_usd")
        coder.encode(price_btc, forKey: "price_btc")
        coder.encode(percent_change_1h, forKey: "percent_change_1h")
        coder.encode(percent_change_24h, forKey: "percent_change_24h")
        coder.encode(percent_change_7d, forKey: "percent_change_7d")
    }
}
