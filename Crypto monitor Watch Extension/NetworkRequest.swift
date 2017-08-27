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
                      name: json["name"].stringValue,
                      symbol: json["symbol"].stringValue,
                      rank: json["rank"].intValue,
                      price_usd: json["price_usd"].floatValue,
                      price_btc: json["price_btc"].floatValue,
                      volume_usd_24h: json["24h_volume_usd"].floatValue,
                      market_cap_usd: json["market_cap_usd"].floatValue,
                      available_supply: json["available_supply"].floatValue,
                      total_supply: json["total_supply"].floatValue,
                      percent_change_1h: json["percent_change_1h"].floatValue,
                      percent_change_24h: json["percent_change_24h"].floatValue,
                      percent_change_7d: json["percent_change_7d"].floatValue,
                      last_updated: json["last_updated"].intValue)
    }
    

}


class Ticker: NSObject, NSCoding{
    
    public var id:String
    public var name:String
    public var symbol:String
    public var rank:Int
    public var price_usd:Float
    public var price_btc:Float
    public var volume_usd_24h:Float
    public var market_cap_usd:Float
    public var available_supply:Float
    public var total_supply:Float
    public var percent_change_1h:Float
    public var percent_change_24h:Float
    public var percent_change_7d:Float
    public var last_updated:NSDate
    
    
    
    public init(id:String,
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
    
    required public init(coder decoder: NSCoder) {
        self.id =  decoder.decodeObject(forKey: "id") as! String
        self.name =  decoder.decodeObject(forKey: "name") as! String
        self.symbol = decoder.decodeObject(forKey: "symbol") as! String
        self.rank = Int(decoder.decodeInt64(forKey: "rank"))
        self.price_usd = decoder.decodeFloat(forKey: "price_usd")
        self.price_btc = decoder.decodeFloat(forKey: "price_btc")
        self.volume_usd_24h = decoder.decodeFloat(forKey: "volume_usd_24h")
        self.market_cap_usd = decoder.decodeFloat(forKey: "market_cap_usd")
        self.available_supply = decoder.decodeFloat(forKey: "available_supply")
        self.total_supply = decoder.decodeFloat(forKey: "total_supply")
        self.percent_change_1h = decoder.decodeFloat(forKey: "percent_change_1h")
        self.percent_change_24h = decoder.decodeFloat(forKey: "percent_change_24h")
        self.percent_change_7d = decoder.decodeFloat(forKey: "percent_change_7d")
        self.last_updated = decoder.decodeObject(forKey: "last_updated") as! NSDate
        
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
        coder.encode(available_supply, forKey: "available_supply")
        coder.encode(total_supply, forKey: "total_supply")
        coder.encode(percent_change_1h, forKey: "percent_change_1h")
        coder.encode(percent_change_24h, forKey: "percent_change_24h")
        coder.encode(percent_change_7d, forKey: "percent_change_7d")
        coder.encode(last_updated, forKey: "last_updated")
    }
}
