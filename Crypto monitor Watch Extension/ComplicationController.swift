//
//  ComplicationController.swift
//  Coin
//
//  Created by Mialin Valentin on 02.09.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import ClockKit
import CryptoCurrency

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        if let tickers = SettingsUserDefaults.loadcacheTicker(), tickers.indices.contains(0) {
            switch complication.family {
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeColumns()
                
                if tickers.indices.contains(0) {
                    template.row1ImageProvider = colorImage(percentChange: tickers[0].percentChangeCurrent())
                    template.row1Column1TextProvider = CLKSimpleTextProvider(text: tickers[0].symbol)
                    template.row1Column2TextProvider =  CLKSimpleTextProvider(text: tickers[0].priceCurrency())
                }
                else{
                    template.row1Column1TextProvider = CLKSimpleTextProvider(text:"")
                    template.row1Column2TextProvider = CLKSimpleTextProvider(text:"")
                }
                
                if tickers.indices.contains(1) {
                    template.row2ImageProvider = colorImage(percentChange: tickers[1].percentChangeCurrent())
                    template.row2Column1TextProvider = CLKSimpleTextProvider(text: tickers[1].symbol)
                    template.row2Column2TextProvider =  CLKSimpleTextProvider(text: tickers[1].priceCurrency())
                }
                else{
                    template.row2Column1TextProvider = CLKSimpleTextProvider(text:"")
                    template.row2Column2TextProvider = CLKSimpleTextProvider(text:"")
                }
                
                if tickers.indices.contains(2) {
                    template.row3ImageProvider = colorImage(percentChange: tickers[2].percentChangeCurrent())
                    template.row3Column1TextProvider = CLKSimpleTextProvider(text: tickers[2].symbol)
                    template.row3Column2TextProvider =  CLKSimpleTextProvider(text: tickers[2].priceCurrency())
                }
                else{
                    template.row3Column1TextProvider = CLKSimpleTextProvider(text:"")
                    template.row3Column2TextProvider = CLKSimpleTextProvider(text:"")
                }
                
                let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(entry)
                
            case .modularSmall:
                
                if tickers.indices.contains(0) {
                    let template = CLKComplicationTemplateModularSmallStackText()
                    template.line1TextProvider = CLKSimpleTextProvider(text: tickers[0].symbol)
                    template.line2TextProvider = CLKSimpleTextProvider(text: tickers[0].percentChangeCurrent())
                    handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                }
                else{
                    let template = CLKComplicationTemplateModularSmallStackImage()
                    template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Stock"))
                    template.line2TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
                    handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                }
                
            case .utilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.imageProvider = colorImage(percentChange: tickers[0].percentChangeCurrent())
                template.textProvider = CLKSimpleTextProvider(text: "\(tickers[0].symbol) \(tickers[0].percentChangeCurrent())")
                
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                
            case .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.imageProvider = colorImage(percentChange: tickers[0].percentChangeCurrent())
                template.textProvider = CLKSimpleTextProvider(text: tickers[0].symbol)
                
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                
                let priceString = tickers[0].priceCurrency()
                let percentChange = tickers[0].percentChangeCurrent()
                
                template.imageProvider = colorImage(percentChange: tickers[0].percentChangeCurrent())
                template.textProvider = CLKSimpleTextProvider(text: "\(tickers[0].symbol) \(priceString) \(percentChange)%")
                
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeStackText()
                
                template.line1TextProvider = CLKSimpleTextProvider(text: tickers[0].symbol)
                template.line2TextProvider = CLKSimpleTextProvider(text: tickers[0].percentChangeCurrent() + "%")
                
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            default:
                handler(nil)
            }
        }
        else{
            switch complication.family {
            case .modularLarge:
                let template = CLKComplicationTemplateModularLargeTallBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Crypto monitor")
                template.bodyTextProvider = CLKSimpleTextProvider(text: "")
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            case .modularSmall:
                let template = CLKComplicationTemplateModularSmallStackImage()
                template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Stock"))
                template.line2TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            case .utilitarianSmall, .utilitarianSmallFlat:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            case .utilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("No cryptocurrencies", comment: ""))
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            case .extraLarge:
                let template = CLKComplicationTemplateExtraLargeStackImage()
                template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Stock"))
                template.line2TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("No", comment: "Нет"))
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            default:
                handler(nil)
            }
        }
    }
    
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeColumns()
            
            template.row1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            template.row1Column1TextProvider = CLKSimpleTextProvider(text:"BTC")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text:"$14,330.30")
            
            template.row2ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Top"))
            template.row2Column1TextProvider = CLKSimpleTextProvider(text:"XRP")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text:"$1.3364")
            
            template.row3ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            template.row3Column1TextProvider = CLKSimpleTextProvider(text:"ETH")
            template.row3Column2TextProvider = CLKSimpleTextProvider(text:"$711.706")
            
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "BTC")
            template.line2TextProvider = CLKSimpleTextProvider(text: "-5.7")
            handler(template)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            template.textProvider = CLKSimpleTextProvider(text: "BTC -5.7")
            handler(template)
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            template.textProvider = CLKSimpleTextProvider(text: "BTC")
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Down"))
            template.textProvider = CLKSimpleTextProvider(text: "BTC $14,172.80 -5.7%")
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "BTC")
            template.line2TextProvider = CLKSimpleTextProvider(text: "-5.7%")
            handler(template)
        default:
            handler(nil)
        }
    }
    
    func colorImage(percentChange: String?) -> CLKImageProvider {
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

