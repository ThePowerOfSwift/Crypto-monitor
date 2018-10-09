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
    
    public enum ResponseA<T: Codable> {
        case failure(error: Error)
        case success([T])
    }
    
    public static func getCoinsMarkets(ids: [String], vsCurrency: Money, response: ((_ r: ResponseA<Coin>) -> Void)?) {
        var urlString = "https://api.coingecko.com/api/v3/coins/markets"
        let convert = SettingsUserDefaults.getCurrentCurrency()
        
        urlString.append("?vs_currency=\(convert.rawValue.lowercased())")
        urlString.append("&ids=\(ids.joined(separator: ","))")
        
        let url = URL(string: urlString)!
        
        Alamofire.request(url).responseCoins { r in
            switch r.result {
            case .success(let coins):
                response?(ResponseA.success(coins))
            case .failure(let error):
                response?(ResponseA.failure(error: error))
            }
        }
    }
}
