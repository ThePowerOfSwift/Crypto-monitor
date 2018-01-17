//
//  Charts.swift
//  Coin
//
//  Created by Mialin Valentin on 12.01.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
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

struct ChartRequest {
    
    public func cancelRequest(url: String = "https://graphs.coinmarketcap.com/currencies/")  {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach
                {
                    if ($0.originalRequest?.url?.absoluteString.range(of: url) != nil)
                    {
                        $0.cancel()
                    }
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
        
        cancelRequest() // url: "https://graphs.coinmarketcap.com/currencies/" + id + "/"
        
        Alamofire.SessionManager.default.request(url).validate().responseJSON { response in
            
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

