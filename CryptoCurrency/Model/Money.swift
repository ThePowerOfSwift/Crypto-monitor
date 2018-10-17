//
//  Money.swift
//  Coin
//
//  Created by Valentyn Mialin on 9/24/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation

public enum Money: String, CaseIterable {
    case aed = "AED"
    case ars = "ARS"
    case aud = "AUD"
    case bch = "BCH"
    case bdt = "BDT"
    case bhd = "BHD"
    case bmd = "BMD"
    case bnb = "BNB"
    case brl = "BRL"
    case btc = "BTC"
    case cad = "CAD"
    case chf = "CHF"
    case clp = "CLP"
    case cny = "CNY"
    case czk = "CZK"
    case dkk = "DKK"
    case eos = "EOS"
    case eth = "ETH"
    case eur = "EUR"
    case gbp = "GBP"
    case hkd = "HKD"
    case huf = "HUF"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case jpy = "JPY"
    case krw = "KRW"
    case kwd = "KWD"
    case lkr = "LKR"
    case ltc = "LTC"
    case mmk = "MMK"
    case mxn = "MXN"
    case myr = "MYR"
    case nok = "NOK"
    case nzd = "NZD"
    case php = "PHP"
    case pkr = "PKR"
    case pln = "PLN"
    case rub = "RUB"
    case sar = "SAR"
    case sek = "SEK"
    case sgd = "SGD"
    case thb = "THB"
    case `try` = "TRY"
    case twd = "TWD"
    case usd = "USD"
    case vef = "VEF"
    case xag = "XAG"
    case xau = "XAU"
    case xdr = "XDR"
    case xlm = "XLM"
    case xrp = "XRP"
    case zar = "ZAR"
    
    public var flag: String {
        switch self {
        case .aed:
            return "🇦🇪"
        case .ars:
            return "🇦🇷"
        case .aud:
            return "🇦🇺"
        case .bch:
            return "  "
        case .bdt:
            return "🇧🇩"
        case .bhd:
            return "🇧🇭"
        case .bmd:
            return "🇧🇲"
        case .bnb:
            return " "
        case .brl:
            return "🇧🇷"
        case .btc:
            return " "
        case .cad:
            return "🇨🇦"
        case .chf:
            return "🇱🇮"
        case .clp:
            return "🇨🇱"
        case .cny:
            return "🇨🇳"
        case .czk:
            return "🇨🇿"
        case .dkk:
            return "🇩🇰"
        case .eos:
            return " "
        case .eth:
            return " "
        case .eur:
            return "🇪🇺"
        case .gbp:
            return "🇬🇧"
        case .hkd:
            return "🇭🇰"
        case .huf:
            return "🇭🇺"
        case .idr:
            return "🇮🇩"
        case .ils:
            return "🇮🇱"
        case .inr:
            return "🇮🇳"
        case .jpy:
            return "🇯🇵"
        case .krw:
            return "🇰🇷"
        case .kwd:
            return "🇰🇼"
        case .lkr:
            return "🇱🇰"
        case .ltc:
            return " "
        case .mmk:
            return "🇲🇲"
        case .mxn:
            return "🇲🇽"
        case .myr:
            return "🇲🇾"
        case .nok:
            return "🇳🇴"
        case .nzd:
            return "🇳🇿"
        case .php:
            return "🇵🇭"
        case .pkr:
            return "🇵🇰"
        case .pln:
            return "🇵🇱"
        case .rub:
            return "🇷🇺"
        case .sar:
            return "🇸🇦"
        case .sek:
            return "🇸🇪"
        case .sgd:
            return "🇸🇬"
        case .thb:
            return "🇹🇭"
        case .try:
            return "🇹🇷"
        case .twd:
            return "🇹🇼"
        case .usd:
            return "🇺🇸"
        case .vef:
            return "🇻🇪"
        case .xag:
            return " "
        case .xau:
            return " "
        case .xdr:
            return " "
        case .xlm:
            return " "
        case .xrp:
            return " "
        case .zar:
            return "🇿🇦"
        }
    }
}
