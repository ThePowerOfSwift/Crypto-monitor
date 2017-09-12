//
//  ComplicationController.swift
//  Coin
//
//  Created by Mialin Valentin on 02.09.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        
        return formatter
    }()
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if complication.family == .modularLarge {
            if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
                if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                    print("ComplicationController \(cacheTicker.count)")
                    let entry = self.createTimeLineEntry(ticker: Array(cacheTicker.prefix(3)))
                    handler(entry)
                }
            }
            else{
                handler(nil)
            }
        }
        else {
            handler(nil)
        }
    }

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }

    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = CLKComplicationTemplateModularLargeColumns()
        
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: "BTC")
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "ETH")
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: "BCH")
        
        template.row1Column2TextProvider = CLKSimpleTextProvider(text: "$ -")
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: "$ -")
        template.row3Column2TextProvider = CLKSimpleTextProvider(text: "$ -")
        
        template.row1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
        template.row1ImageProvider?.tintColor = .red
        template.row2ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
        template.row2ImageProvider?.tintColor = .red
        template.row3ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
        template.row3ImageProvider?.tintColor = .red
        
        handler(template)
    }
    
    func createTimeLineEntry(ticker : [Ticker]) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularLargeColumns()
        let userDefaults = UserDefaults()
        
        do {
            switch userDefaults.integer(forKey: "percentChange") {
            case 0:
                if ticker.indices.contains(0) {
                    template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_1h)
                }
                if ticker.indices.contains(1) {
                    template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_1h)
                }
                if ticker.indices.contains(2) {
                    template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_1h)
                }
            case 1:
                if ticker.indices.contains(0) {
                    template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_24h)
                }
                if ticker.indices.contains(1) {
                    template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_24h)
                }
                if ticker.indices.contains(2) {
                    template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_24h)
                }
            case 2:
                if ticker.indices.contains(0) {
                    template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_7d)
                }
                if ticker.indices.contains(1) {
                    template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_7d)
                }
                if ticker.indices.contains(2) {
                    template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_7d)
                }
            default:
                break
            }
        }

        if ticker.indices.contains(0) {
             template.row1Column1TextProvider = CLKSimpleTextProvider(text: ticker[0].symbol)
        }
        else{
            template.row1Column1TextProvider = CLKSimpleTextProvider(text:"")
        }
        if ticker.indices.contains(1) {
             template.row2Column1TextProvider = CLKSimpleTextProvider(text: ticker[1].symbol)
        }
        else{
            template.row2Column1TextProvider = CLKSimpleTextProvider(text:"")
        }
        if ticker.indices.contains(2) {
            template.row3Column1TextProvider = CLKSimpleTextProvider(text: ticker[2].symbol)
        }
        else{
            template.row3Column1TextProvider = CLKSimpleTextProvider(text:"")
        }
        
        switch userDefaults.integer(forKey: "priceCurrency") {
        case 0:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 25
            formatter.locale = Locale(identifier: "en_US")
            
            if ticker.indices.contains(0) {
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: ticker[0].price_usd as NSNumber)!)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: ticker[1].price_usd as NSNumber)!)
            }
            else{
                template.row2Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            if ticker.indices.contains(2) {
                template.row3Column2TextProvider = CLKSimpleTextProvider(text: dateFormatter.string(from: Date()))
            }
            else{
                template.row3Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
        case 1:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            
            if ticker.indices.contains(0) {
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: "₿ " + formatter.string(from: ticker[0].price_btc as NSNumber)!)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: "₿ " + formatter.string(from: ticker[1].price_btc as NSNumber)!)
            }
            else{
                template.row2Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            
            if ticker.indices.contains(2) {
                template.row3Column2TextProvider = CLKSimpleTextProvider(text: dateFormatter.string(from: Date()))
            }
            else{
                template.row3Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
        default:
            break
        }
        
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        return(entry)
    }
    

    private func colorImage(percentChange: Float) -> CLKImageProvider {
        if percentChange >= 0 {
            let imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Top"))
            imageProvider.tintColor = .green
            return imageProvider
        }
        else{
            let imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            imageProvider.tintColor = .red
            return imageProvider
        }
    }
}

