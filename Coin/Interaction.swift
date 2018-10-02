//
//  Interaction.swift
//  Coin
//
//  Created by Valentyn Mialin on 9/29/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import CryptoCurrency
import Intents
import os.log

@available(iOS 12.0, *)
class Interaction {
    static func donate(tickers: [Ticker]) {
        for ticker in tickers{
            let intent = ShowPriceIntent()
            intent.id = ticker.id
            intent.name = ticker.name
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.identifier = ticker.id
            
            interaction.donate { (error) in
                if error != nil {
                    if let error = error as NSError? {
                        os_log("Interaction donation failed: %@", log: OSLog.default, type: .error, error)
                    }
                } else {
                    os_log("Successfully donated interaction")
                }
            }
        }
    }
    
    static func delete(ticker: Ticker) {
        INInteraction.delete(with: ticker.id, completion: nil)
    }
    static func deleteAll() {
        INInteraction.deleteAll()
    }
}
