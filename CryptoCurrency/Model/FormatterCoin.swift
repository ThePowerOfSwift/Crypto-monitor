//
//  FormatterCoin.swift
//  Coin
//
//  Created by Valentyn Mialin on 10/11/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation


    public func formatterCurrency(for money: Money, maximumFractionDigits: Int) -> NumberFormatter {
        let formatterCurrency = NumberFormatter()
        formatterCurrency.numberStyle = .currency
        formatterCurrency.currencyCode = money.rawValue
        formatterCurrency.locale  = Locale.current
        formatterCurrency.maximumFractionDigits = maximumFractionDigits
        formatterCurrency.nilSymbol = "-"
        return formatterCurrency
    }
    
//    public func priceToString() -> String {
//        guard let price = currentPrice else { return "-" }
//        let money = SettingsUserDefaults.getCurrentCurrency()
//        let formatter = formatterCurrency(for: money, maximumFractionDigits: 2)
//        return formatter.string(from: NSNumber(value: price))!
//    }
//
//    public func priceChange24HToString() -> String {
//        guard var priceChange24H = priceChange24H else { return "-" }
//        priceChange24H = priceChange24H / 100
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .percent
//        numberFormatter.maximumFractionDigits = 2
//        return numberFormatter.string(for: priceChange24H) ?? "-"
//    }
