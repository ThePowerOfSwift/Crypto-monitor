//
//  protocol.swift
//  Coin
//
//  Created by Valentyn Mialin on 09.06.2018.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import CryptoCurrency

protocol CoinDelegate: class {
    func coinSelected(_ coin: Coin)
}

protocol CoinsDelegate: class {
    func coins(_ tickers: [Ticker])
}
