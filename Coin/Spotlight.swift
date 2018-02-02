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

extension CoinTableViewController {
    
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
                // Set the image.
                let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/64x64/\(ticker.id).png")!
                if let cashedImage = UIImageView.af_sharedImageDownloader.imageCache?.image(for: URLRequest(url: url), withIdentifier: nil) {
                    if let data = UIImagePNGRepresentation(cashedImage) {
                        searchableItemAttributeSet.thumbnailData = data
                    }
                }
                
                searchableItemAttributeSet.keywords = ["coin", "монета", "Pièce de monnaie", "Münze",
                                                       "cryptocurrency", "Криптовалюта", "Cryptomonnaie", "Kryptowährung",
                                                       "rates", "обменный курс", "taux de change", "Tauschrate" ]
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: ticker.id, domainIdentifier: "mialin.Coin", attributeSet: searchableItemAttributeSet)
                searchableItems.append(searchableItem)
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



