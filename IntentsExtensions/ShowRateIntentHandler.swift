//
//  ShowRateIntentHandler.swift
//  IntentsExtensions
//
//  Created by Valentyn Mialin on 9/24/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import CryptoCurrency

public class ShowRateIntentHandler: NSObject, ShowPriceIntentHandling {
    
    public func confirm(intent: ShowPriceIntent, completion: @escaping (ShowPriceIntentResponse) -> Void) {
        // Различные проверки на доступность действия
        // ...
        
        print(intent.id ?? "name error")
        completion(ShowPriceIntentResponse(code: ShowPriceIntentResponseCode.ready, userActivity: nil))
    }
    
    
    public func handle(intent: ShowPriceIntent, completion: @escaping (ShowPriceIntentResponse) -> Void) {
        // Код с выполнением действия
        // ...
        
        print(SettingsUserDefaults.getCurrentCurrency())
        CryptoCurrencyKit.fetchTicker(coinName: intent.id!) { response in
            //  guard let strongSelf = self else { return }
            let userActivity = NSUserActivity(activityType: "Valentyn.Mialin.crypto.monitor.show-currency")
            switch response {
            case .success(let ticker):
                DispatchQueue.main.async {
                    let response = ShowPriceIntentResponse(code: .success, userActivity: nil)
                    response.name = ticker.name
                    response.priceUSD = ticker.priceToString(for: .usd)
                    response.priceBTC = ticker.priceBtcToString()
                    response.percentChange1h = NSNumber(value: ticker.percentChange1h ?? 0)
                    response.percentChange24h = NSNumber(value: ticker.percentChange24h ?? 0)
                    response.percentChange7d = NSNumber(value: ticker.percentChange7d ?? 0)
                    response.userActivity = userActivity
                    completion(response)
                }
            case .failure:
                DispatchQueue.main.async {
                    let response = ShowPriceIntentResponse(code: .failure, userActivity: nil)
                    completion(response)
                }
            }
        }
    }
}
