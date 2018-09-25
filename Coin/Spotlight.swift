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
import Intents
import os.log

extension MainVC {
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        DispatchQueue.global(qos: .background).async {
            if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
                CSSearchableIndex.default().deleteAllSearchableItems()
                self.indexItem(ticker: cacheTicker)
            }
        }
    }
    
    func indexItem(ticker: [Ticker]) {
        DispatchQueue.global(qos: .background).async {
            var searchableItems = [CSSearchableItem]()
            
            for ticker in ticker{
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                
                // Set the title.
                searchableItemAttributeSet.title = ticker.name
                // Set the description.
                searchableItemAttributeSet.contentDescription = ticker.symbol
 
                searchableItemAttributeSet.keywords = ["coin", "монета", "Pièce de monnaie", "Münze",
                                                       "cryptocurrency", "Криптовалюта", "Cryptomonnaie", "Kryptowährung",
                                                       "rates", "обменный курс", "taux de change", "Tauschrate" ]
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: ticker.id, domainIdentifier: "mialin.Coin", attributeSet: searchableItemAttributeSet)
                searchableItems.append(searchableItem)
                
                if #available(iOS 12.0, *) {
                    let intent = ShowRateIntent()
                    intent.id = ticker.id
                //    intent.name = ticker.name
                    
                    let interaction = INInteraction(intent: intent, response: nil)
                    
                    // The order identifier is used to match with the donation so the interaction
                    // can be deleted if a soup is removed from the menu.
                    //interaction.identifier = order.identifier.uuidString
                    
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
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully indexed!")
                }
            }
   
        }
    }
    
    func deindexItem(identifier: String) {
        DispatchQueue.global(qos: .background).async {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(identifier)"]) { error in
                if let error = error {
                    print("Deindexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully removed!")
                }
            }
        }
    }
}



