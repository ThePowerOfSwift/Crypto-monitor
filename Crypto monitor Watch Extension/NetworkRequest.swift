//
//  NetworkRequest.swift
//  Coin
//
//  Created by Mialin Valentin on 27.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import Foundation

class NetworkRequest{
    
    public func getTickerID(idArray: [String], completion: @escaping ([Ticker]?, Error?) -> Void) {
        let endpoint = "https://api.coinmarketcap.com/v1/ticker/"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            let error = BackendError.urlError(reason: "Could not construct URL")
            completion(nil, error)
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard let responseData = data else {
                print("Error: did not receive data")
                completion(nil, error)
                return
            }
            guard error == nil else {
                completion(nil, error)
                return
            }
            
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
        }
        task.resume()
    }
}

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

class Ticker: NSObject, NSCoding, Codable{
    
    public var id:String
    public var symbol:String
    public var price_usd:String
    public var price_btc:String
    public var percent_change_1h:String?
    public var percent_change_24h:String?
    public var percent_change_7d:String?
    
    public init(id:String,
                symbol:String,
                price_usd:String,
                price_btc:String,
                percent_change_1h:String,
                percent_change_24h:String,
                percent_change_7d:String){
        
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
        self.price_usd = decoder.decodeObject(forKey: "price_usd") as! String
        self.price_btc = decoder.decodeObject(forKey: "price_btc") as! String
        self.percent_change_1h = decoder.decodeObject(forKey: "percent_change_1h") as? String
        self.percent_change_24h = decoder.decodeObject(forKey: "percent_change_24h") as? String
        self.percent_change_7d = decoder.decodeObject(forKey: "percent_change_7d") as? String
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
