//
//  Coins.swift
//  Coin
//
//  Created by Valentyn Mialin on 10/9/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//
// To parse the JSON, add this file to your project and do:
//
//   let coins = try? newJSONDecoder().decode(Coins.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCoins { response in
//     if let coins = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public typealias Coins = [Coin]

public struct Coin: Codable {
    public let id: String
    public let symbol: String
    public let name: String
    public let image: String
    public let currentPrice: Double?
    public let marketCap: Double?
    public let marketCapRank: Int?
    public let totalVolume: Double?
    public let high24H: Double?
    public let low24H: Double?
    public let priceChange24H: Double?
    public let priceChangePercentage24H: Double?
    public let marketCapChange24H: Double?
    public let marketCapChangePercentage24H: Double?
    public let circulatingSupply: String?
    public let totalSupply: Int?
    public let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case symbol = "symbol"
        case name = "name"
        case image = "image"
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case lastUpdated = "last_updated"
    }
    
    public init(id: String, symbol: String, name: String, image: String, currentPrice: Double?, marketCap: Double?, marketCapRank: Int?, totalVolume: Double?, high24H: Double?, low24H: Double?, priceChange24H: Double?, priceChangePercentage24H: Double?, marketCapChange24H: Double?, marketCapChangePercentage24H: Double?, circulatingSupply: String?, totalSupply: Int?, lastUpdated: String?) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.totalVolume = totalVolume
        self.high24H = high24H
        self.low24H = low24H
        self.priceChange24H = priceChange24H
        self.priceChangePercentage24H = priceChangePercentage24H
        self.marketCapChange24H = marketCapChange24H
        self.marketCapChangePercentage24H = marketCapChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Alamofire response handlers

public extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    public func responseCoins(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Coins>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

extension Coin {
    public func priceToString() -> String {
        guard let price = currentPrice else { return "-" }
        let money = SettingsUserDefaults.getCurrentCurrency()
        let formatter = formatterCurrency(for: money, maximumFractionDigits: 2)
        return formatter.string(from: NSNumber(value: price))!
    }
    
    public func priceChange24HToString() -> String {
        guard var priceChange24H = priceChange24H else { return "-" }
        priceChange24H = priceChange24H / 100
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(for: priceChange24H) ?? "-"
    }
}
