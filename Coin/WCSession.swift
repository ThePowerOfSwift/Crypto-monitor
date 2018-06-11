//
//  WCSession.swift
//  Coin
//
//  Created by Mialin Valentin on 17.05.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import CryptoCurrency
import WatchConnectivity

//MARK: - WCSession
extension CoinTableViewController: WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Sender Watch
    func updateApplicationContext(id: [String]) {
        DispatchQueue.global(qos: .background).async {
            if(WCSession.isSupported()){
                do {
                    let keyStore = NSUbiquitousKeyValueStore ()
                    let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
                    let currentCurrency = SettingsUserDefaults.getCurrentCurrency().rawValue
                    
                    let context = ["id" : id, "percentChange" : percentChange, "CurrentCurrency" : currentCurrency] as [String : Any]
                    try self.watchSession?.updateApplicationContext(context)
                    
                } catch let error as NSError {
                    print("Error: \(error.description)")
                }
            }
        }
    }
    
    // Receiver
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        // handle receiving application context
        DispatchQueue.global(qos: .background).async {
            let keyStore = NSUbiquitousKeyValueStore ()
            
            if let percentChange = applicationContext["percentChange"] as? Int {
                keyStore.set(percentChange, forKey: "percentChange")
            }
            
            if let priceCurrency = applicationContext["priceCurrency"] as? Int {
                keyStore.set(priceCurrency, forKey: "priceCurrency")
            }
            keyStore.synchronize()
            
            self.loadCache()
        }
    }
}
