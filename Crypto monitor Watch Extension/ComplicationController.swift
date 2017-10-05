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
    
    let formatterCurrencyUSD: NumberFormatter = {
        let formatterCurrencyUSD = NumberFormatter()
        formatterCurrencyUSD.numberStyle = .currency
        formatterCurrencyUSD.currencyCode = "USD"
        formatterCurrencyUSD.maximumFractionDigits = 10
        return formatterCurrencyUSD
    }()
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .modularLarge:
            if let decodedTicker = UserDefaults().object(forKey: "tickers") as? [Data] {
                let cacheTicker = decodedTicker.map { Ticker(data: $0)! }
                print("ComplicationController \(cacheTicker.count)")
                let entry = self.createTimeLineEntry(ticker: Array(cacheTicker.prefix(3)))
                handler(entry)
            }
            else{
                handler(nil)
            }
        case .modularSmall:
            if let decodedTicker = UserDefaults().object(forKey: "tickers") as? [Data] {
                let cacheTicker = decodedTicker.map { Ticker(data: $0)! }
                if !cacheTicker.isEmpty{
                    if cacheTicker.indices.contains(0) {
                        let template = CLKComplicationTemplateModularSmallStackText()
                        template.line1TextProvider = CLKSimpleTextProvider(text: cacheTicker[0].symbol)
                        
                        switch UserDefaults().integer(forKey: "percentChange") {
                        case 0:
                            if let percent_change_1h = cacheTicker[0].percent_change_1h{
                                template.line2TextProvider = CLKSimpleTextProvider(text: percent_change_1h + "%")
                            }
                            else{
                                template.line2TextProvider = CLKSimpleTextProvider(text: "null")
                            }
                        case 1:
                            if let percent_change_24h = cacheTicker[0].percent_change_24h{
                                template.line2TextProvider = CLKSimpleTextProvider(text: percent_change_24h + "%")
                            }
                            else{
                                template.line2TextProvider = CLKSimpleTextProvider(text: "null")
                            }
                        case 2:
                            if let percent_change_7d = cacheTicker[0].percent_change_7d{
                                template.line2TextProvider = CLKSimpleTextProvider(text: percent_change_7d + "%")
                            }
                            else{
                                template.line2TextProvider = CLKSimpleTextProvider(text: "null")
                            }
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
        case .utilitarianSmall:
            if let decodedTicker = UserDefaults().object(forKey: "tickers") as? [Data] {
                let cacheTicker = decodedTicker.map { Ticker(data: $0)! }
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
        case .utilitarianLarge:
            if let decodedTicker = UserDefaults().object(forKey: "tickers") as? [Data] {
                let cacheTicker = decodedTicker.map { Ticker(data: $0)! }
                if cacheTicker.indices.contains(0) {
                    let template = CLKComplicationTemplateUtilitarianLargeFlat()
                    
                    var priceString = String()
                    
                    switch UserDefaults().integer(forKey: "priceCurrency") {
                    case 0:
                        priceString = formatterCurrencyUSD.string(from: NSNumber(value: Double(cacheTicker[0].price_usd)!))!
                    // priceString = "$ " + cacheTicker[0].price_usd
                    case 1:
                        priceString = "₿" +  cacheTicker[0].price_btc
                    default:
                        break
                    }
                    
                    switch UserDefaults().integer(forKey: "percentChange") {
                    case 0:
                        template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_1h)
                        if let percent_change_1h = cacheTicker[0].percent_change_1h{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(percent_change_1h)%")
                        }
                        else{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) null")
                        }
                    case 1:
                        template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_24h)
                        if let percent_change_24h = cacheTicker[0].percent_change_24h{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(percent_change_24h)%")
                        }
                        else{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) null")
                        }
                    case 2:
                        template.imageProvider = colorImage(percentChange: cacheTicker[0].percent_change_7d)
                        
                        if let percent_change_7d = cacheTicker[0].percent_change_7d{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) \(priceString) \(percent_change_7d)%")
                        }
                        else{
                            template.textProvider = CLKSimpleTextProvider(text: "\(cacheTicker[0].symbol) null")
                        }
                    default:
                        break
                    }
                    
                    let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                    handler(entry)
                }
            }
        default:
            handler(nil)
        }
        
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
            handler(nil) 
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
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: formatterCurrencyUSD.string(from: NSNumber(value: Double(ticker[0].price_usd)!))!)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: formatterCurrencyUSD.string(from: NSNumber(value: Double(ticker[1].price_usd)!))!)
            }
            else{
                template.row2Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            if ticker.indices.contains(2) {
                template.row3Column2TextProvider = CLKSimpleTextProvider(text: formatterCurrencyUSD.string(from: NSNumber(value: Double(ticker[2].price_usd)!))!)
            }
            else{
                template.row3Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
        case 1:
            
            if ticker.indices.contains(0) {
                template.row1Column2TextProvider = CLKSimpleTextProvider(text: "₿" + ticker[0].price_btc)
            }
            else{
                template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            
            if ticker.indices.contains(1) {
                template.row2Column2TextProvider = CLKSimpleTextProvider(text: "₿" + ticker[1].price_btc)
            }
            else{
                template.row2Column2TextProvider = CLKSimpleTextProvider(text:"")
            }
            
            if ticker.indices.contains(2) {
                template.row3Column2TextProvider = CLKSimpleTextProvider(text: "₿" + ticker[2].price_btc)
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
    
    
    private func colorImage(percentChange: String?) -> CLKImageProvider {
        if let percentChange = percentChange {
            if Float(percentChange)! >= 0 {
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
        else{
            let imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Line"))
            imageProvider.tintColor = .orange
            return imageProvider
        }
    }
}

