//
//  MarketChart.swift
//  Coin
//
//  Created by Valentyn Mialin on 10/17/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let marketChart = try? newJSONDecoder().decode(MarketChart.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseMarketChart { response in
//     if let marketChart = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public struct MarketChart: Codable {
    let prices, marketCaps, totalVolumes: [[Double]]
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}

// MARK: - Alamofire response handlers

extension DataRequest {
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
    func responseMarketChart(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<MarketChart>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

