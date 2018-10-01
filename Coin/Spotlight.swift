//
//  Spotlight.swift
//  Coin
//
//  Created by Mialin Valentin on 02.02.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//
import UIKit
import MobileCoreServices
import CoreSpotlight
import CryptoCurrency
import os.log

class SearchableIndex {
    static func indexItem(tickers: [Ticker]) {
        DispatchQueue.global(qos: .background).async {
            var searchableItems = [CSSearchableItem]()
            let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            
            searchableItemAttributeSet.keywords = ["coin", "монета", "Pièce de monnaie", "Münze",
                                                   "cryptocurrency", "Криптовалюта", "Cryptomonnaie", "Kryptowährung",
                                                   "rates", "обменный курс", "taux de change", "Tauschrate" ]
            for ticker in tickers{
                // Set the title.
                searchableItemAttributeSet.title = ticker.name
                // Set the description.
                searchableItemAttributeSet.contentDescription = ticker.symbol
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: ticker.id, domainIdentifier: "mialin.Coin", attributeSet: searchableItemAttributeSet)
                searchableItems.append(searchableItem)
            }
            
            self.deleteAll()
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
                if let error = error {
                    os_log("Indexing error: %@", log: OSLog.default, type: .error, error as CVarArg)
                } else {
                    os_log("Search item successfully indexed!")
                }
            }
        }
    }
    
    static func deindexItem(identifier: String) {
        DispatchQueue.global(qos: .background).async {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(identifier)"]) { error in
                if let error = error {
                    os_log("Deindexing error: %@", log: OSLog.default, type: .error, error as CVarArg)
                } else {
                    os_log("Search item successfully removed!")
                }
            }
        }
    }
    static func deleteAll() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}

extension MainVC {
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        DispatchQueue.global(qos: .background).async {
            if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
                SearchableIndex.indexItem(tickers: cacheTicker)
            }
        }
    }
}




