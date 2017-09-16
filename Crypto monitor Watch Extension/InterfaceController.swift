//
//  InterfaceController.swift
//  Crypto monitor Watch Extension
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var cryptocurrencyTable: WKInterfaceTable!
    @IBOutlet var emptyGroup: WKInterfaceGroup!
    // Our WatchConnectivity Session for communicating with the iOS app
    var watchSession : WCSession?
    
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        print("WCSession")
        let userDefaults = UserDefaults()
        if let percentChange = applicationContext["percentChange"] as? Int {
            userDefaults.set(percentChange, forKey: "percentChange")
        }
        
        if let priceCurrency = applicationContext["priceCurrency"] as? Int {
            userDefaults.set(priceCurrency, forKey: "priceCurrency")
        }
        
        if let id = applicationContext["id"] as? [String] {
            userDefaults.removeObject(forKey: "cryptocurrency")
            userDefaults.removeObject(forKey: "lastUpdate")
            userDefaults.set(id, forKey: "id")
        }
        userDefaults.synchronize()
        load()
    }
    
    // Sender
    private func updateApplicationContext() {
        do {
            let userDefaults = UserDefaults()
            let percentChange = Int(userDefaults.integer(forKey: "percentChange"))
            let priceCurrency = Int(userDefaults.integer(forKey: "priceCurrency"))
            
            let context = ["percentChange" : percentChange, "priceCurrency" : priceCurrency] as [String : Any]
            try watchSession?.updateApplicationContext(context)
        
            let complicationServer = CLKComplicationServer.sharedInstance()
            
            for complication in complicationServer.activeComplications! {
                print("UPDATE sender")
                complicationServer.reloadTimeline(for: complication)
            }
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        
    }

    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate")
        
        if (WKExtension.shared().applicationState == .active) {
            updateUserActivity("Valentyn.Mialin.crypto.monitor.Activity", userInfo: ["" : ""], webpageURL: nil)
            load()
        }
        else{
            viewCache()
        }
        
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            // Add self as a delegate of the session so we can handle messages
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func viewCache() {
        if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
            if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                self.tableView(ticker: cacheTicker)
            }
        }
    }
    
    private func load() {
        if let idArray = UserDefaults().array(forKey: "id") as? [String] {
            if !idArray.isEmpty {
                NetworkRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                    if error == nil {
                        if let ticker = ticker {
                            print("ticker cout \(ticker.count)")
                            self.setUserDefaults(ticher: ticker, lastUpdate: Date())
                            DispatchQueue.main.async() {
                                self.tableView(ticker: ticker)
                                print("UPDATE 2")
                                let complicationServer = CLKComplicationServer.sharedInstance()
                                for complication in complicationServer.activeComplications! {
                                    complicationServer.reloadTimeline(for: complication)
                                }
                            }
                        }
                    }
                })
            }
            else{
                let complicationServer = CLKComplicationServer.sharedInstance()
                for complication in complicationServer.activeComplications! {
                    complicationServer.reloadTimeline(for: complication)
                }
                cryptocurrencyTable.setHidden(true)
                emptyGroup.setHidden(false)
            }
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: timeIntervalRefresh), userInfo: nil) { (error: Error?) in
                if let error = error {
                    print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
                }
            } 
        }
    }

    private func tableView(ticker: [Ticker])  {
        if !ticker.isEmpty{
            cryptocurrencyTable.setHidden(false)
            emptyGroup.setHidden(true)
            
            if let idArray = UserDefaults().array(forKey: "id") as? [String] {
                var tickerFilter = [Ticker]()
                for id in idArray{
                    if let json = ticker.filter({ $0.id == id}).first{
                        tickerFilter.append(json)
                    }
                }
                
                cryptocurrencyTable.setNumberOfRows(tickerFilter.count, withRowType: "cell")
                for index in 0..<cryptocurrencyTable.numberOfRows {
                    guard let controller = cryptocurrencyTable.rowController(at: index) as? cryptocurrencyRowController else { continue }
                    controller.ticker = tickerFilter[index]
                }
            }
        }
        else{
            cryptocurrencyTable.setHidden(true)
            emptyGroup.setHidden(false)
        }

    }
    
    //MARK: UserDefaults
    private func setUserDefaults(ticher: [Ticker], lastUpdate: Date) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: ticher)
        let userDefaults = UserDefaults()
        userDefaults.set(encodedData, forKey: "cryptocurrency")
        userDefaults.set(lastUpdate, forKey: "lastUpdate")
        userDefaults.synchronize()
    }
    
    //MARK: Actions
    @IBAction func oneHourSelected() {
        UserDefaults().set(0, forKey: "percentChange")
        UserDefaults().synchronize()
        viewCache()
        updateApplicationContext()
    }
    
    @IBAction func oneDaySelected() {
        UserDefaults().set(1, forKey: "percentChange")
        UserDefaults().synchronize()
        viewCache()
        updateApplicationContext()
    }
    
    @IBAction func sevenDaySelected() {
        UserDefaults().set(2, forKey: "percentChange")
        UserDefaults().synchronize()
        viewCache()
        updateApplicationContext()
    }
    
}

