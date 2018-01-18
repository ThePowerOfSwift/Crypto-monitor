//
//  Ticker.swift
//  CoinCurrency
//
//  Created by Xiaoyu Li on 19/09/2017.
//
import Foundation

public struct Ticker {
    public let id: String
    public let name: String
    public let symbol: String
    public let rank: Int
    
    public let availableSupply: Double?
    public let totalSupply: Double?
    public let percentChange1h: Double?
    public let percentChange24h: Double?
    public let percentChange7d: Double?
    public let lastUpdated: Double?
    
    public let priceBTC: Double?
    public let volumeBTC24h: Double?
    public let marketCapBTC: Double?
    
    public let priceUSD: Double?
    public let volumeUSD24h: Double?
    public let marketCapUSD: Double?
    
    public let priceEUR: Double?
    public let volumeEUR24h: Double?
    public let marketCapEUR: Double?
    
    public let priceGBP: Double?
    public let volumeGBP24h: Double?
    public let marketCapGBP: Double?
    
    public let priceJPY: Double?
    public let volumeJPY24h: Double?
    public let marketCapJPY: Double?
    
    public let priceCNY: Double?
    public let volumeCNY24h: Double?
    public let marketCapCNY: Double?
    
    public let priceHKD: Double?
    public let volumeHKD24h: Double?
    public let marketCapHKD: Double?
    
    public let priceRUB: Double?
    public let volumeRUB24h: Double?
    public let marketCapRUB: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case rank
        
        case availableSupply = "available_supply"
        case totalSupply = "total_supply"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
        case lastUpdated = "last_updated"
        
        case priceBTC = "price_btc"
        case volumeBTC24h = "24h_volume_btc"
        case marketCapBTC = "market_cap_btc"
        
        case priceUSD = "price_usd"
        case volumeUSD24h = "24h_volume_usd"
        case marketCapUSD = "market_cap_usd"
        
        case priceEUR = "price_eur"
        case volumeEUR24h = "24h_volume_eur"
        case marketCapEUR = "market_cap_eur"
        
        case priceGBP = "price_gbp"
        case volumeGBP24h = "24h_volume_gbp"
        case marketCapGBP = "market_cap_gbp"
        
        case priceHKD = "price_hkd"
        case volumeHKD24h = "24h_volume_hkd"
        case marketCapHKD = "market_cap_hkd"
        
        case priceJPY = "price_jpy"
        case volumeJPY24h = "24h_volume_jpy"
        case marketCapJPY = "market_cap_jpy"
        
        case priceCNY = "price_cny"
        case volumeCNY24h = "24h_volume_cny"
        case marketCapCNY = "market_cap_cny"
        
        case priceRUB = "price_rub"
        case volumeRUB24h = "24h_volume_rub"
        case marketCapRUB = "market_cap_rub"
        
        /*  case priceAUD = "price_aud"
         case volumeAUD24h = "24h_volume_aud"
         case marketCapAUD = "market_cap_aud"
         
         case priceBRL = "price_brl"
         case volumeBRL24h = "24h_volume_brl"
         case marketCapBRL = "market_cap_brl"
         
         */
        
        
        /*
         case priceAUD = "price_"
         case volumeAUD24h = "24h_volume_"
         case marketCapAUD = "market_cap_"
         */
        
    }
}

extension Ticker: Equatable {
    public static func ==(lhs: Ticker, rhs: Ticker) -> Bool {
        return lhs.id.hashValue == rhs.id.hashValue
    }
}

extension Ticker {
    public func price(for money: CryptoCurrencyKit.Money) -> Double? {
        switch money {
        case .cny:
            return priceCNY
        case .usd:
            return priceUSD
        case .eur:
            return priceEUR
        case .gbp:
            return priceGBP
        case .hkd:
            return priceHKD
        case .jpy:
            return priceJPY
        case .btc:
            return priceBTC
        case .rub:
            return priceRUB
        }
    }
    
    public func volume24h(for money: CryptoCurrencyKit.Money) -> Double? {
        switch money {
        case .cny:
            return volumeCNY24h
        case .usd:
            return volumeUSD24h
        case .eur:
            return volumeEUR24h
        case .gbp:
            return volumeGBP24h
        case .hkd:
            return volumeHKD24h
        case .jpy:
            return volumeJPY24h
        case .btc:
            return volumeBTC24h
        case .rub:
            return volumeRUB24h
        }
    }
    
    public func marketCap(for money: CryptoCurrencyKit.Money) -> Double? {
        switch money {
        case .cny:
            return marketCapCNY
        case .usd:
            return marketCapUSD
        case .eur:
            return marketCapEUR
        case .gbp:
            return marketCapGBP
        case .hkd:
            return marketCapHKD
        case .jpy:
            return marketCapJPY
        case .btc:
            return marketCapBTC
        case .rub:
            return marketCapRUB
        }
    }
    
    func formatterCurrency(for money: CryptoCurrencyKit.Money, maximumFractionDigits: Int) -> NumberFormatter {
        let formatterCurrency = NumberFormatter()
        formatterCurrency.numberStyle = .currency
        formatterCurrency.currencyCode = money.rawValue
        //formatterCurrency.locale = Locale(identifier: "en_US")
        formatterCurrency.locale  = Locale.current
        formatterCurrency.maximumFractionDigits = maximumFractionDigits
        formatterCurrency.nilSymbol = "-"
        return formatterCurrency
    }
    
    func formatterBtc() -> NumberFormatter {
        let formatterBtc = NumberFormatter()
        formatterBtc.locale = Locale.current
        formatterBtc.numberStyle = .currency
        formatterBtc.maximumFractionDigits = 8
        formatterBtc.currencySymbol = "₿"
        formatterBtc.nilSymbol = "-"
        return formatterBtc
    }
    
    public func priceBtcToString() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 8
        formatter.currencySymbol = "₿"
        formatter.nilSymbol = "-"


        return formatterCurrency(for: .btc, maximumFractionDigits: 8).string(for: priceBTC)!
    }
    
    public func priceToString(for money: CryptoCurrencyKit.Money) -> String {
        guard let price = price(for: money) else { return "-" }
        if price > 0.01 {
            let formatter = formatterCurrency(for: money, maximumFractionDigits: 2)
            return formatter.string(from: NSNumber(value: price))!
        }
        else{
            let formatter = formatterCurrency(for: money, maximumFractionDigits: 8)
            return formatter.string(from: NSNumber(value: price))!
        }
    }
    
    public func marketCapToString(for money: CryptoCurrencyKit.Money, maximumFractionDigits: Int) -> String {
        let  marketCap = self.marketCap(for: money)
        
        if let marketCap = marketCap {
            let formatterCurrency = self.formatterCurrency(for: money, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrency.string(from: NSNumber(value: marketCap))!
        }
        else{
            return "-"
        }
    }
    
    public func volumeToString(for money: CryptoCurrencyKit.Money, maximumFractionDigits: Int) -> String {
        let volume = self.volume24h(for: money)
        
        if let volume = volume {
            let formatterCurrency = self.formatterCurrency(for: money, maximumFractionDigits: maximumFractionDigits)
            return formatterCurrency.string(from: NSNumber(value: volume))!
        }
        else{
            return "-"
        }
    }
    
    
    
    
    public func priceCurrency() -> String {

        let currency =  SettingsUserDefaults().getCurrentCurrency()
        
        switch currency {
        case .btc:
            return priceBtcToString()
        default:
            guard let price = price(for: currency) else { return "-" }
            if price > 0.01 {
                let formatter = formatterCurrency(for: currency, maximumFractionDigits: 2)
                return formatter.string(from: NSNumber(value: price))!
            }
            else{
                let formatter = formatterCurrency(for: currency, maximumFractionDigits: 8)
                return formatter.string(from: NSNumber(value: price))!
            }
        }
    }
    
    
    public func percentChangeCurrent() -> String {
        var percentChange:Double?
        #if os(iOS)
            let dd = NSUbiquitousKeyValueStore().longLong(forKey: "percentChange")
        #endif
        
        #if os(watchOS)
            let dd = UserDefaults().integer(forKey: "percentChange")
        #endif
        
        switch dd {
        case 0:
            percentChange = percentChange1h
        case 1:
            percentChange = percentChange24h
        case 2:
            percentChange = percentChange7d
        default:
            break
        }
        
        if let percentChange = percentChange {
            return String(percentChange)
        }
        else{
            return "-"
        }
    }
    
    /*
     func percentChangeCurrent() -> String {
     var percentChange:String?
     switch UserDefaults().integer(forKey: "percentChange") {
     case 0:
     percentChange = percent_change_1h
     case 1:
     percentChange = percent_change_24h
     case 2:
     percentChange = percent_change_7d
     default:
     break
     }
     
     if let percentChange = percentChange {
     return percentChange
     }
     else{
     return "-"
     }
     }
     */
    
    
    
}

extension Ticker: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(String(describing: rank), forKey: .rank)
        try container.encode(doubleToString(double: availableSupply), forKey: .availableSupply)
        try container.encode(doubleToString(double: totalSupply), forKey: .totalSupply)
        try container.encode(doubleToString(double: percentChange1h), forKey: .percentChange1h)
        try container.encode(doubleToString(double: percentChange24h), forKey: .percentChange24h)
        try container.encode(doubleToString(double: percentChange7d), forKey: .percentChange7d)
        try container.encode(doubleToString(double: lastUpdated), forKey: .lastUpdated)
        try container.encode(doubleToString(double: priceBTC), forKey: .priceBTC)
        try container.encode(doubleToString(double: volumeBTC24h), forKey: .volumeBTC24h)
        try container.encode(doubleToString(double: marketCapBTC), forKey: .marketCapBTC)
        try container.encode(doubleToString(double: priceUSD), forKey: .priceUSD)
        try container.encode(doubleToString(double: volumeUSD24h), forKey: .volumeUSD24h)
        try container.encode(doubleToString(double: marketCapUSD), forKey: .marketCapUSD)
        try container.encode(doubleToString(double: priceEUR), forKey: .priceEUR)
        try container.encode(doubleToString(double: volumeEUR24h), forKey: .volumeEUR24h)
        try container.encode(doubleToString(double: marketCapEUR), forKey: .marketCapEUR)
        try container.encode(doubleToString(double: priceGBP), forKey: .priceGBP)
        try container.encode(doubleToString(double: volumeGBP24h), forKey: .volumeGBP24h)
        try container.encode(doubleToString(double: marketCapGBP), forKey: .marketCapGBP)
        try container.encode(doubleToString(double: priceCNY), forKey: .priceCNY)
        try container.encode(doubleToString(double: volumeCNY24h), forKey: .volumeCNY24h)
        try container.encode(doubleToString(double: marketCapCNY), forKey: .marketCapCNY)
        try container.encode(doubleToString(double: priceHKD), forKey: .priceHKD)
        try container.encode(doubleToString(double: volumeHKD24h), forKey: .volumeHKD24h)
        try container.encode(doubleToString(double: marketCapHKD), forKey: .marketCapHKD)
        try container.encode(doubleToString(double: priceJPY), forKey: .priceJPY)
        try container.encode(doubleToString(double: volumeJPY24h), forKey: .volumeJPY24h)
        try container.encode(doubleToString(double: marketCapJPY), forKey: .marketCapJPY)
        try container.encode(doubleToString(double: priceRUB), forKey: .priceRUB)
        try container.encode(doubleToString(double: volumeRUB24h), forKey: .volumeRUB24h)
        try container.encode(doubleToString(double: marketCapRUB), forKey: .marketCapRUB)
    }
    
    func doubleToString(double: Double?) -> String? {
        if let double = double {
            return "\(double)"
        }
        else{
            return nil
        }
    }
}

extension Ticker {
    public init(id: String, symbol: String, name: String, rank: Int, availableSupply: Double?, totalSupply: Double?, percentChange1h: Double?, percentChange24h: Double?, percentChange7d: Double?, lastUpdated: Double?, priceBTC: Double?, volumeBTC24h: Double?, marketCapBTC: Double?,
                priceUSD: Double?, volumeUSD24h: Double?, marketCapUSD: Double?,
                priceEUR: Double?, volumeEUR24h: Double?, marketCapEUR: Double?,
                priceGBP: Double?, volumeGBP24h: Double?, marketCapGBP: Double?,
                priceJPY: Double?, volumeJPY24h: Double?, marketCapJPY: Double?,
                priceCNY: Double?, volumeCNY24h: Double?, marketCapCNY: Double?,
                priceHKD: Double?, volumeHKD24h: Double?, marketCapHKD: Double?,
                priceRUB: Double?, volumeRUB24h: Double?, marketCapRUB: Double?
        
        ) {
        self.init(id: id, symbol: symbol, name: name, rank: rank, availableSupply: availableSupply, totalSupply: totalSupply, percentChange1h: percentChange1h, percentChange24h: percentChange24h, percentChange7d: percentChange7d, lastUpdated: lastUpdated, priceBTC: priceBTC, volumeBTC24h: volumeBTC24h, marketCapBTC: marketCapBTC,
                  priceUSD: priceUSD, volumeUSD24h: volumeUSD24h, marketCapUSD: marketCapUSD,
                  priceEUR: priceEUR, volumeEUR24h: volumeUSD24h, marketCapEUR: marketCapEUR,
                  priceGBP: priceGBP, volumeGBP24h: volumeGBP24h, marketCapGBP: marketCapGBP,
                  priceJPY: priceJPY, volumeJPY24h: volumeJPY24h, marketCapJPY: marketCapJPY,
                  priceCNY: priceCNY, volumeCNY24h: volumeCNY24h, marketCapCNY: marketCapCNY,
                  priceHKD: priceHKD, volumeHKD24h: volumeHKD24h, marketCapHKD: marketCapHKD,
                  priceRUB: priceRUB, volumeRUB24h: volumeRUB24h, marketCapRUB: marketCapRUB)
    }
}

extension Ticker: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        rank =  try Int(values.decode(String.self, forKey: .rank))!
        
        if let availableSupplyTemp = try? values.decode(String.self, forKey: .availableSupply) {
            availableSupply = Double(availableSupplyTemp)
        } else {
            availableSupply = nil
        }
        if let totalSupplyTemp = try? values.decode(String.self, forKey: .totalSupply) {
            totalSupply = Double(totalSupplyTemp)
        } else {
            totalSupply = nil
        }
        if let lastUpdatedTemp = try? values.decode(String.self, forKey: .lastUpdated) {
            lastUpdated = Double(lastUpdatedTemp)
        } else {
            lastUpdated = nil
        }
        
        if let priceBTCTemp = try? values.decode(String.self, forKey: .priceBTC) {
            priceBTC = Double(priceBTCTemp)
        } else {
            priceBTC = nil
        }
        
        if let volumeBTC24hTemp = try? values.decode(String.self, forKey: .volumeBTC24h) {
            volumeBTC24h = Double(volumeBTC24hTemp)
        } else {
            volumeBTC24h = nil
        }
        
        if let marketCapBTCTemp = try? values.decode(String.self, forKey: .marketCapBTC) {
            marketCapBTC = Double(marketCapBTCTemp)
        } else {
            marketCapBTC = nil
        }
        
        if let priceUSDTemp = try? values.decode(String.self, forKey: .priceUSD) {
            priceUSD = Double(priceUSDTemp)
        } else {
            priceUSD = nil
        }
        if let volumeUSD24hTemp = try? values.decode(String.self, forKey: .volumeUSD24h) {
            volumeUSD24h = Double(volumeUSD24hTemp)
        } else {
            volumeUSD24h = nil
        }
        if let marketCapUSDTemp = try? values.decode(String.self, forKey: .marketCapUSD) {
            marketCapUSD = Double(marketCapUSDTemp)
        } else {
            marketCapUSD = nil
        }
        
        if let percentChange1hTemp = try? values.decode(String.self, forKey: .percentChange1h) {
            percentChange1h = Double(percentChange1hTemp)
        } else {
            percentChange1h = nil
        }
        if let percentChange24hTemp = try? values.decode(String.self, forKey: .percentChange24h) {
            percentChange24h = Double(percentChange24hTemp)
        } else {
            percentChange24h = nil
        }
        if let percentChange7dtemp = try? values.decode(String.self, forKey: .percentChange7d) {
            percentChange7d = Double(percentChange7dtemp)
        } else {
            percentChange7d = nil
        }
        
        if let priceEURTemp = try? values.decode(String.self, forKey: .priceEUR) {
            priceEUR = Double(priceEURTemp)
        } else {
            priceEUR = nil
        }
        if let volumeEUR24hTemp = try? values.decode(String.self, forKey: .volumeEUR24h) {
            volumeEUR24h = Double(volumeEUR24hTemp)
        } else {
            volumeEUR24h = nil
        }
        if let marketCapEURTemp = try? values.decode(String.self, forKey: .marketCapEUR) {
            marketCapEUR = Double(marketCapEURTemp)
        } else {
            marketCapEUR = nil
        }
        
        if let priceGBPTemp = try? values.decode(String.self, forKey: .priceGBP) {
            priceGBP = Double(priceGBPTemp)
        } else {
            priceGBP = nil
        }
        if let volumeGBP24hTemp = try? values.decode(String.self, forKey: .volumeGBP24h) {
            volumeGBP24h = Double(volumeGBP24hTemp)
        } else {
            volumeGBP24h = nil
        }
        if let marketCapGBPTemp = try? values.decode(String.self, forKey: .marketCapGBP) {
            marketCapGBP = Double(marketCapGBPTemp)
        } else {
            marketCapGBP = nil
        }
        
        if let priceCNYTemp = try? values.decode(String.self, forKey: .priceCNY) {
            priceCNY = Double(priceCNYTemp)
        } else {
            priceCNY = nil
        }
        if let volumeCNY24hTemp = try? values.decode(String.self, forKey: .volumeCNY24h) {
            volumeCNY24h = Double(volumeCNY24hTemp)
        } else {
            volumeCNY24h = nil
        }
        if let marketCapCNYTemp = try? values.decode(String.self, forKey: .marketCapCNY) {
            marketCapCNY = Double(marketCapCNYTemp)
        } else {
            marketCapCNY = nil
        }
        
        if let priceHKDTemp = try? values.decode(String.self, forKey: .priceHKD) {
            priceHKD = Double(priceHKDTemp)
        } else {
            priceHKD = nil
        }
        if let volumeHKD24hTemp = try? values.decode(String.self, forKey: .volumeHKD24h) {
            volumeHKD24h = Double(volumeHKD24hTemp)
        } else {
            volumeHKD24h = nil
        }
        if let marketCapHKDTemp = try? values.decode(String.self, forKey: .marketCapHKD) {
            marketCapHKD = Double(marketCapHKDTemp)
        } else {
            marketCapHKD = nil
        }
        
        if let priceJPYTemp = try? values.decode(String.self, forKey: .priceJPY) {
            priceJPY = Double(priceJPYTemp)
        } else {
            priceJPY = nil
        }
        if let volumeJPY24hTemp = try? values.decode(String.self, forKey: .volumeJPY24h) {
            volumeJPY24h = Double(volumeJPY24hTemp)
        } else {
            volumeJPY24h = nil
        }
        if let marketCapJPYTemp = try? values.decode(String.self, forKey: .marketCapJPY) {
            marketCapJPY = Double(marketCapJPYTemp)
        } else {
            marketCapJPY = nil
        }
        
        if let priceRUBTemp = try? values.decode(String.self, forKey: .priceRUB) {
            priceRUB = Double(priceRUBTemp)
        } else {
            priceRUB = nil
        }
        if let volumeRUB24hTemp = try? values.decode(String.self, forKey: .volumeRUB24h) {
            volumeRUB24h = Double(volumeRUB24hTemp)
        } else {
            volumeRUB24h = nil
        }
        if let marketCapRUBTemp = try? values.decode(String.self, forKey: .marketCapRUB) {
            marketCapRUB = Double(marketCapRUBTemp)
        } else {
            marketCapRUB = nil
        }
    }
}

