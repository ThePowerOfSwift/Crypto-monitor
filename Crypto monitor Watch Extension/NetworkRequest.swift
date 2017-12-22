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
        let endpoint = "https://api.coinmarketcap.com/v1/ticker/?convert=EUR&limit=0"
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

public struct Ticker: Decodable {
    public let id:String
    public let symbol:String
    public let price_usd:String?
    public let price_btc:String?
    public let percent_change_1h:String?
    public let percent_change_24h:String?
    public let percent_change_7d:String?
    public let price_eur:String?
}

extension Ticker {
    public func encode() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(id, forKey: "id")
        archiver.encode(symbol, forKey: "symbol")
        archiver.encode(price_usd, forKey: "price_usd")
        archiver.encode(price_btc, forKey: "price_btc")
        archiver.encode(percent_change_1h, forKey: "percent_change_1h")
        archiver.encode(percent_change_24h, forKey: "percent_change_24h")
        archiver.encode(percent_change_7d, forKey: "percent_change_7d")
        archiver.encode(price_eur, forKey: "price_eur")
        archiver.finishEncoding()
        return data as Data
    }
        public init?(data: Data) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            defer {
                unarchiver.finishDecoding()
            }
            guard let id = unarchiver.decodeObject(forKey: "id") as? String else { return nil }
            guard let symbol = unarchiver.decodeObject(forKey: "symbol") as? String else { return nil }
            guard let price_usd = unarchiver.decodeObject(forKey: "price_usd") as? String else { return nil }
            guard let price_btc = unarchiver.decodeObject(forKey: "price_btc") as? String else { return nil }
            guard let percent_change_1h = unarchiver.decodeObject(forKey: "percent_change_1h") as? String else { return nil }
            guard let percent_change_24h = unarchiver.decodeObject(forKey: "percent_change_24h") as? String else { return nil }
            guard let percent_change_7d = unarchiver.decodeObject(forKey: "percent_change_7d") as? String else { return nil }
            guard let price_eur = unarchiver.decodeObject(forKey: "price_eur") as? String else { return nil }
            
            self.id = id
            self.symbol = symbol
            self.price_usd = price_usd
            self.price_btc = price_btc
            self.percent_change_1h = percent_change_1h
            self.percent_change_24h = percent_change_24h
            self.percent_change_7d = percent_change_7d
            self.price_eur = price_eur
        }
}
