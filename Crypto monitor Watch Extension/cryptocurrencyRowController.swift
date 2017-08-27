//
//  cryptocurrencyRowController.swift
//  Coin
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit

class cryptocurrencyRowController: NSObject {
    
    @IBOutlet var symbolLabel: WKInterfaceLabel!
    @IBOutlet var percentChangeLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var cellMainGroup: WKInterfaceGroup!
    
    var ticker:Ticker?{
        didSet {
            if let ticker = ticker {
                
                symbolLabel.setText(ticker.symbol)
                percentChangeLabel.setText(String(ticker.percent_change_7d) + " %")
                priceLabel.setText("$ " + String(ticker.price_usd))
                
                if ticker.percent_change_7d >= 0 {
                    cellMainGroup.setBackgroundColor(UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0))
                }
                else{
                    cellMainGroup.setBackgroundColor( UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0))
                }
            }
        }
    }
    
}

class Ticker: NSObject, NSCoding{
    
    public var id:String
    public var name:String
    public var symbol:String
    public var rank:Int
    public var price_usd:Float
    public var price_btc:Float
    public var volume_usd_24h:Float
    public var market_cap_usd:Float
    public var available_supply:Float
    public var total_supply:Float
    public var percent_change_1h:Float
    public var percent_change_24h:Float
    public var percent_change_7d:Float
    public var last_updated:NSDate
    
    
    
    public init(id:String,
                name:String,
                symbol:String,
                rank:Int,
                price_usd:Float,
                price_btc:Float,
                volume_usd_24h:Float,
                market_cap_usd:Float,
                available_supply:Float,
                total_supply:Float,
                percent_change_1h:Float,
                percent_change_24h:Float,
                percent_change_7d:Float,
                last_updated:Int){
        
        self.id = id
        self.name = name
        self.symbol = symbol
        self.rank = rank
        self.price_usd = price_usd
        self.price_btc = price_btc
        self.volume_usd_24h = volume_usd_24h
        self.market_cap_usd = market_cap_usd
        self.available_supply = available_supply
        self.total_supply = total_supply
        self.percent_change_1h = percent_change_1h
        self.percent_change_24h = percent_change_24h
        self.percent_change_7d = percent_change_7d
        self.last_updated = NSDate(timeIntervalSince1970: TimeInterval(last_updated))
    }
    
    required public init(coder decoder: NSCoder) {
        self.id =  decoder.decodeObject(forKey: "id") as! String
        self.name =  decoder.decodeObject(forKey: "name") as! String
        self.symbol = decoder.decodeObject(forKey: "symbol") as! String
        self.rank = Int(decoder.decodeInt64(forKey: "rank"))
        self.price_usd = decoder.decodeFloat(forKey: "price_usd")
        self.price_btc = decoder.decodeFloat(forKey: "price_btc")
        self.volume_usd_24h = decoder.decodeFloat(forKey: "volume_usd_24h")
        self.market_cap_usd = decoder.decodeFloat(forKey: "market_cap_usd")
        self.available_supply = decoder.decodeFloat(forKey: "available_supply")
        self.total_supply = decoder.decodeFloat(forKey: "total_supply")
        self.percent_change_1h = decoder.decodeFloat(forKey: "percent_change_1h")
        self.percent_change_24h = decoder.decodeFloat(forKey: "percent_change_24h")
        self.percent_change_7d = decoder.decodeFloat(forKey: "percent_change_7d")
        self.last_updated = decoder.decodeObject(forKey: "last_updated") as! NSDate
        
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(symbol, forKey: "symbol")
        coder.encode(rank, forKey: "rank")
        coder.encode(price_usd, forKey: "price_usd")
        coder.encode(price_btc, forKey: "price_btc")
        coder.encode(volume_usd_24h, forKey: "volume_usd_24h")
        coder.encode(market_cap_usd, forKey: "market_cap_usd")
        coder.encode(available_supply, forKey: "available_supply")
        coder.encode(total_supply, forKey: "total_supply")
        coder.encode(percent_change_1h, forKey: "percent_change_1h")
        coder.encode(percent_change_24h, forKey: "percent_change_24h")
        coder.encode(percent_change_7d, forKey: "percent_change_7d")
        coder.encode(last_updated, forKey: "last_updated")
    }
    
}
