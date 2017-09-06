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
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if complication.family == .modularLarge {
            
            if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
                if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                   let entry = self.createTimeLineEntry(ticker: Array(cacheTicker.prefix(3)))
                    handler(entry)
                }
            }
        }
        else {
            handler(nil)
        }
    }
    

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
/*
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        handler(Date(timeIntervalSinceNow: TimeInterval(10*60)))
    }
    */
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = CLKComplicationTemplateModularLargeColumns()
        
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: "BTC")
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: "ETH")
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: "BCH")
        
        template.row1Column2TextProvider = CLKSimpleTextProvider(text: "$4627.99")
        template.row2Column2TextProvider = CLKSimpleTextProvider(text: "$350.99")
        template.row3Column2TextProvider = CLKSimpleTextProvider(text: "$580.99")
        
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
        
        
        switch userDefaults.integer(forKey: "percentChange") {
        case 0:
            template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_1h)
            template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_1h)
            template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_1h)
        case 1:
            template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_24h)
            template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_24h)
            template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_24h)
        case 2:
            template.row1ImageProvider = colorImage(percentChange: ticker[0].percent_change_7d)
            template.row2ImageProvider = colorImage(percentChange: ticker[1].percent_change_7d)
            template.row3ImageProvider = colorImage(percentChange: ticker[2].percent_change_7d)
        default:
            break
        }
        
        template.row1Column1TextProvider = CLKSimpleTextProvider(text: ticker[0].symbol)
        template.row2Column1TextProvider = CLKSimpleTextProvider(text: ticker[1].symbol)
        template.row3Column1TextProvider = CLKSimpleTextProvider(text: ticker[2].symbol)
 
        switch userDefaults.integer(forKey: "priceCurrency") {
        case 0:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 25
            formatter.locale = Locale(identifier: "en_US")
            
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: ticker[0].price_usd as NSNumber)!)
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: ticker[1].price_usd as NSNumber)!)
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: ticker[2].price_usd as NSNumber)!)
        case 1:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "₿ " + formatter.string(from: ticker[0].price_btc as NSNumber)!)
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "₿ " + formatter.string(from: ticker[1].price_btc as NSNumber)!)
            template.row3Column2TextProvider = CLKSimpleTextProvider(text: "₿ " + formatter.string(from: ticker[2].price_btc as NSNumber)!)
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
    
    /*
    func createTimeLineEntry(headerText: String, bodyText: String, date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        
        template.headerTextProvider = CLKSimpleTextProvider(text: headerText)
        template.body1TextProvider = CLKSimpleTextProvider(text: bodyText)
        
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        return(entry)
    }*/
    


}
