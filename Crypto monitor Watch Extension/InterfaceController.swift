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

class InterfaceController: WKInterfaceController, WCSessionDelegate{

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
        
        if let id = applicationContext["id"] as? [String] {
            
            let userDefaultsIdArray = userDefaults.array(forKey: "id") as! [String]
            
            if userDefaultsIdArray != id {
                userDefaults.removeObject(forKey: "cryptocurrency")
                userDefaults.set(id, forKey: "id")
                userDefaults.synchronize()
            }
            
            
        }
        
        if let percentChange = applicationContext["percentChange"] as? Int {
            userDefaults.set(percentChange, forKey: "percentChange")
        }
        
        if let priceCurrency = applicationContext["priceCurrency"] as? Int {
            userDefaults.set(priceCurrency, forKey: "priceCurrency")
        }
        
        userDefaults.synchronize()
        load()

    }
    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("willActivate")
        super.willActivate()
        
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            // Add self as a delegate of the session so we can handle messages
            watchSession!.delegate = self
            watchSession!.activate()
        }
        loadCache()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func loadCache() {
        if let decodedTicker = UserDefaults().data(forKey: "cryptocurrency"){
            if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: decodedTicker) as? [Ticker] {
                self.tableView(ticker: cacheTicker)
                
            }
        }
        
        if let lastUpdate = UserDefaults().object(forKey: "lastUpdate") as? Date {
            if lastUpdate <= (Calendar.current.date(byAdding: .minute, value: -5, to: Date())! ){
                load()
            }
        }
        else{
            load()
        }
    }
    
    private func load() {
        if let idArray = UserDefaults().array(forKey: "id") as? [String] {
            if !idArray.isEmpty {
                NetworkRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                    if error == nil {
                        if let ticker = ticker {
                            self.setUserDefaults(ticher: ticker, idArray: idArray, lastUpdate: Date())
                            DispatchQueue.main.async() {
                                self.tableView(ticker: ticker)
                            }
                        }
                    }
                    else{
                        //  self.showErrorSubview(error: error!)
                    }
                })
            }
            else{
                tableView(ticker: [Ticker]())
            }
        }
    }
    
    func tableView(ticker: [Ticker])  {
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
    
    //MARK: UserDefaults
    private func setUserDefaults(ticher: [Ticker], idArray: [String], lastUpdate: Date) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: ticher)
        let userDefaults = UserDefaults()
        userDefaults.set(idArray, forKey: "id")
        userDefaults.set(encodedData, forKey: "cryptocurrency")
        userDefaults.set(lastUpdate, forKey: "lastUpdate")
        userDefaults.synchronize()
    }
}

