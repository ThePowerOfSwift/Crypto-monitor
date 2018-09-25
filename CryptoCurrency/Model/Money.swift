//
//  Money.swift
//  Coin
//
//  Created by Valentyn Mialin on 9/24/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation

public enum Money: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case btc = "BTC"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"
    case hkd = "HKD"
    case rub = "RUB"
    case cad = "CAD"
    
    public var flag: String {
        switch self {
        case .usd:
            return "🇺🇸"
        case .eur:
            return "🇪🇺"
        case .btc:
            return "🌍"
        case .gbp:
            return "🇬🇧"
        case .jpy:
            return "🇯🇵"
        case .cny:
            return "🇨🇳"
        case .hkd:
            return "🇭🇰"
        case .rub:
            return "🇷🇺"
        case .cad:
            return "🇨🇦"
        }
    }
}
