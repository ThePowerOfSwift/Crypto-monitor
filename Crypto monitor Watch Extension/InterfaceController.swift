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
    // Our WatchConnectivity Session for communicating with the iOS app
    var watchSession : WCSession?
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        print("data")
        
        let id = applicationContext["id"] as? [String]
        if let id = id {
            UserDefaults().set(id, forKey: "id")
        }
    }
    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("watc")

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
    }
    
    private func load() {
        if let idArray = UserDefaults().array(forKey: "id") as? [String] {
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
    }
    
    
    func tableView(ticker: [Ticker])  {
        cryptocurrencyTable.setNumberOfRows(ticker.count, withRowType: "cell")
        for index in 0..<cryptocurrencyTable.numberOfRows {
            guard let controller = cryptocurrencyTable.rowController(at: index) as? cryptocurrencyRowController else { continue }
            controller.ticker = ticker[index]
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

