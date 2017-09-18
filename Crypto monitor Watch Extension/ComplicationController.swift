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
    
    private let formatterUSD: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 10
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    private let formatterBTC: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        return formatter
    }()
    
    private let formatterShortUSD: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 5
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    private let formatterShortBTC: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        return formatter
    }()
    
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .modularLarge:
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
        case .modularSmall:
            if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
                if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                    if !cacheTicker.isEmpty{
                        if cacheTicker.indices.contains(0) {
                            let template = CLKComplicationTemplateModularSmallStackText()
                            template.line1TextProvider = CLKSimpleTextProvider(text: cacheTicker[0].symbol)
                            
                            switch UserDefaults().integer(forKey: "percentChange") {
                            case 0:
                                template.line2TextProvider = CLKSimpleTextProvider(text: String(cacheTicker[0].percent_change_1h) + "%")
                            case 1:
                                template.line2TextProvider = CLKSimpleTextProvider(text: String(cacheTicker[0].percent_change_24h) + "%")
                            case 2:
                                template.line2TextProvider = CLKSimpleTextProvider(text: String(cacheTicker[0].percent_change_7d) + "%")
                            default:
                                break
                            }
                            
                            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                            handler(entry)
                        }
                    }
                    else{
                        let template = CLKComplicationTemplateModularSmallStackImage()
                        template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Stock"))
                        template.line2TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
                        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                        handler(entry)
                    }
                }
            }
        case .utilitarianSmall:
            if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
                if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                    if cacheTicker.indices.contains(0) {
                        let template = CLKComplicationTemplateUtilitarianSmallFlat()
                        
                        switch UserDefaults().integer(forKey: "percentChange") {
                        case 0:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_1h)
                        case 1:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_24h)
                        case 2:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_7d)
                        default:
                            break
                        }
                        template.textProvider = CLKSimpleTextProvider(text: cacheTicker[0].symbol)
                        
                        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                        handler(entry)
                        }
                    }
                }
        case .utilitarianLarge:
            if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
                if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                    if cacheTicker.indices.contains(0) {
                        let template = CLKComplicationTemplateUtilitarianLargeFlat()
                        
                        var priceString = String()
                        var priceShortString = String()
                        
                        switch UserDefaults().integer(forKey: "priceCurrency") {
                        case 0:
                            priceString = formatterUSD.string(from: cacheTicker[0].price_usd as NSNumber)!
                            priceShortString = formatterShortUSD.string(from: cacheTicker[0].price_usd as NSNumber)!
                        case 1:
                            priceString = formatterBTC.string(from: cacheTicker[0].price_btc as NSNumber)!
                            priceShortString = formatterShortBTC.string(from: cacheTicker[0].price_btc as NSNumber)!
                        default:
                            break
                        }
                        
                        switch UserDefaults().integer(forKey: "percentChange") {
                        case 0:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_1h)
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(cacheTicker[0].percent_change_1h)%", shortText: "\(cacheTicker[0].symbol) \(priceShortString) \(cacheTicker[0].percent_change_1h)%")
                            
                        case 1:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_24h)
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(cacheTicker[0].percent_change_24h)%", shortText: "\(cacheTicker[0].symbol) \(priceShortString) \(cacheTicker[0].percent_change_24h)%")
                        case 2:
                            template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_7d)
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(cacheTicker[0].percent_change_7d)%", shortText: "\(cacheTicker[0].symbol) \(priceShortString) \(cacheTicker[0].percent_change_7d)%")
                        default:
                            break
                        }
                        
                        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                        handler(entry)
                    }
                }
            }
        default:
            handler(nil)
        }
        
    }

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }

    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
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
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackImage()
            template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Stock"))
            template.line2TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
            
            handler(template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("No cryptocurrencies", comment: ""))
            handler(template)

        default:
            handler(nil)
        }
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
            
            
            if ticker.indices.contains(0) {
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: formatterUSD.string(from: ticker[0].price_usd as NSNumber)!)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: formatterUSD.string(from: ticker[1].price_usd as NSNumber)!)
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
            
            if ticker.indices.contains(0) {
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: formatterBTC.string(from: ticker[0].price_btc as NSNumber)!)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: formatterBTC.string(from: ticker[1].price_btc as NSNumber)!)
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

