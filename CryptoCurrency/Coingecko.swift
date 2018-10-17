//
//  Coingecko.swift
//  Coin
//
//  Created by Valentyn Mialin on 10/9/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import Alamofire

public struct Coingecko {
    
    static private let scheme = "https"
    static private let host = "api.coingecko.com"
    
    public enum ResponseA<T: Codable> {
        case failure(error: Error)
        case success([T])
    }
    
    public enum ResponseB<T: Codable> {
        case failure(error: Error)
        case success(T)
    }
    
//    public static func getCoinsList(response: ((_ r: ResponseB<CoinsList>) -> Void)?) {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = scheme
//        urlComponents.host = host
//        urlComponents.path = "/api/v3/coins/list"
//        
//        guard let url = urlComponents.url else { return }
//        
//        Alamofire.request(url).responseCoinsList { r in
//            switch r.result {
//            case .success(let coinsList):
//                response?(ResponseB.success(coinsList))
//            case .failure(let error):
//                response?(ResponseB.failure(error: error))
//            }
//        }
//    }
    
    public static func getCoinsMarkets(ids: [String], response: ((_ r: ResponseA<Coin>) -> Void)?) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "/api/v3/coins/markets"
        
        let convert = SettingsUserDefaults.getCurrentCurrency()
        let queryCurrency = URLQueryItem(name: "vs_currency", value: convert.rawValue.lowercased())
        let queryIds = URLQueryItem(name: "ids", value: ids.joined(separator: ","))
        
        urlComponents.queryItems = [queryCurrency, queryIds]
        
        guard let url = urlComponents.url else { return }
        
        Alamofire.request(url).responseCoins { r in
            switch r.result {
            case .success(var coins):
                coins = coins.map { ($0, ids.index(of: $0.id) ?? Int.max) }
                    .sorted(by: { $0.1 < $1.1 })
                    .map { $0.0 }
                response?(ResponseA.success(coins))
            case .failure(let error):
                response?(ResponseA.failure(error: error))
            }
        }
    }
    
    public static func getCoinsMarkets(response: ((_ r: ResponseA<Coin>) -> Void)?) {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "/api/v3/coins/markets"
        
        let convert = SettingsUserDefaults.getCurrentCurrency()
        let queryCurrency = URLQueryItem(name: "vs_currency", value: convert.rawValue.lowercased())
        
        urlComponents.queryItems = [queryCurrency]
        
        guard let url = urlComponents.url else { return }
        
        Alamofire.request(url).responseCoins { r in
            switch r.result {
            case .success(let coins):
                response?(ResponseA.success(coins))
            case .failure(let error):
                response?(ResponseA.failure(error: error))
            }
        }
    }
    
    
    public static func getCoinDetails(id: String, response: ((_ r: ResponseB<CoinDetails>) -> Void)?) {

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "/api/v3/coins/" + id
        
        guard let url = urlComponents.url else { return }

        Alamofire.request(url).responseCoinDetails { r in
            switch r.result {
            case .success(let coins):
                response?(ResponseB.success(coins))
            case .failure(let error):
                response?(ResponseB.failure(error: error))
            }
        }
    }
    
    public static func getMarketChart(id: String, period: Period, response: ((_ r: ResponseB<MarketChart>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "/api/v3/coins/" + id + "/market_chart"
        
        let convert = SettingsUserDefaults.getCurrentCurrency()
        let queryCurrency = URLQueryItem(name: "vs_currency", value: convert.rawValue.lowercased())
        let queryDays = URLQueryItem(name: "days", value: period.rawValue)
        
        urlComponents.queryItems = [queryCurrency, queryDays]
        
        guard let url = urlComponents.url else { return }
        
        Alamofire.request(url).responseMarketChart { r in
            switch r.result {
            case .success(let marketChart):
                response?(ResponseB.success(marketChart))
            case .failure(let error):
                response?(ResponseB.failure(error: error))
            }
        }
    }
    
    
    
    public enum Period: String {
        case period24h = "1"
        case period7d  = "7"
        case period14d = "14"
        case period30d = "30"
        case period60d = "60"
        case period90d = "90"
        case periodMax = "max"
        
        public init(index: Int) {
            switch index {
            case 0: self = .period24h
            case 1: self = .period7d
            case 2: self = .period14d
            case 3: self = .period30d
            case 4: self = .period60d
            case 5: self = .period90d
            case 6: self = .periodMax
            default:
                self = .period7d
            }
        }
    }

}
