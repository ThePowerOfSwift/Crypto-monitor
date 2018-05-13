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
import CryptoCurrency

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
        
        if let currentCurrency = applicationContext["CurrentCurrency"] as? String {
            SettingsUserDefaults.setCurrentCurrency(money: CryptoCurrencyKit.Money(rawValue: currentCurrency)!)
        }
        
        if let id = applicationContext["id"] as? [String] {
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
            
            reloadTimeline()
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate")
        
        if(WCSession.isSupported()){
            watchSession = WCSession.default
            // Add self as a delegate of the session so we can handle messages
            watchSession!.delegate = self
            watchSession!.activate()
        }
        
        if (WKExtension.shared().applicationState == .active) {
            viewCache()
            updateUserActivity("Valentyn.Mialin.crypto.monitor.Activity", userInfo: ["" : ""], webpageURL: nil)
            load()
        }
        else{
            viewCache()
        }
    }

    private func viewCache() {
        if let cacheTicker = SettingsUserDefaults.loadcacheTicker() {
            self.tableView(ticker: cacheTicker)
        }
    }
    
    private func load() {
        print("load")
        if let idArray = UserDefaults().array(forKey: "id") as? [String],  !idArray.isEmpty {
                CryptoCurrencyKit.fetchTickers(convert: SettingsUserDefaults.getCurrentCurrency(), idArray: idArray) { [weak self] (response) in
                    switch response {
                    case .success(let tickers):
                        SettingsUserDefaults.setUserDefaults(ticher: tickers)
                        DispatchQueue.main.async() {
                            self?.tableView(ticker: tickers)
                            self?.reloadTimeline()
                        }
                        print("success")
                    case .failure(let error):
                        print("failure \(error.localizedDescription)")
                    }
                }
            }
        else{
            SettingsUserDefaults.setUserDefaults(ticher: nil)
            SettingsUserDefaults.setIdArray(idArray: nil)
            reloadTimeline()
            cryptocurrencyTable.setHidden(true)
            emptyGroup.setHidden(false)
        }
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: timeIntervalRefresh), userInfo: nil) { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        }
    }
    
    private func reloadTimeline(){
        let complicationServer = CLKComplicationServer.sharedInstance()
        complicationServer.activeComplications?.forEach(complicationServer.reloadTimeline)
    }
    
    private func tableView(ticker: [Ticker])  {
        if !ticker.isEmpty{
            cryptocurrencyTable.setHidden(false)
            emptyGroup.setHidden(true)
            
            cryptocurrencyTable.setNumberOfRows(ticker.count, withRowType: "cell")
            for index in 0..<cryptocurrencyTable.numberOfRows {
                guard let controller = cryptocurrencyTable.rowController(at: index) as? cryptocurrencyRowController else { continue }
                controller.ticker = ticker[index]
            }
        }
        else{
            cryptocurrencyTable.setHidden(true)
            emptyGroup.setHidden(false)
        }
    }
    
    
    
    //MARK: Actions
    @IBAction func oneHourSelected() {
        let userDefaults = UserDefaults()
        userDefaults.set(0, forKey: "percentChange")
        userDefaults.synchronize()
        viewCache()
        updateApplicationContext()
    }
    
    @IBAction func oneDaySelected() {
        let userDefaults = UserDefaults()
        userDefaults.set(1, forKey: "percentChange")
        userDefaults.synchronize()
        viewCache()
        updateApplicationContext()
    }
    
    @IBAction func sevenDaySelected() {
        let userDefaults = UserDefaults()
        userDefaults.set(2, forKey: "percentChange")
        userDefaults.synchronize()
        viewCache()
        updateApplicationContext()
    }
    
}

