//
//  WatchSessionManager.swift
//  Coin
//
//  Created by Mialin Valentin on 28.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//
import WatchConnectivity

// Note that the WCSessionDelegate must be an NSObject
// So no, you cannot use the nice Swift struct here!
class WatchSessionManager: NSObject, WCSessionDelegate {
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Instantiate the Singleton
    static let sharedManager = WatchSessionManager()
    override init() {
        super.init()
    }
    
    // Our WatchConnectivity Session for communicating with the watchOS app
    var watchSession : WCSession?

    // Activate Session
    // This needs to be called to activate the session before first use!
    func startSession() {
        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            watchSession!.delegate = self
            watchSession!.activate()
        }
    }
}

extension WatchSessionManager {
    
    // Sender
    private func updateApplicationContext(context: [String : Any]) {
        do {
            try watchSession?.updateApplicationContext(context)
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        
    }
    
    func updateIdArray(id: [String]) {
        let keyStore = NSUbiquitousKeyValueStore ()
        let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
        let priceCurrency = Int(keyStore.longLong(forKey: "priceCurrency"))
        
        let context = ["id" : id, "percentChange" : percentChange, "priceCurrency" : priceCurrency] as [String : Any]
        updateApplicationContext(context: context)
    }
    
    func updateSettings() {
        let keyStore = NSUbiquitousKeyValueStore ()
        let percentChange = Int(keyStore.longLong(forKey: "percentChange"))
        let priceCurrency = Int(keyStore.longLong(forKey: "priceCurrency"))
        
        let context = ["percentChange" : percentChange, "priceCurrency" : priceCurrency] as [String : Any]
        updateApplicationContext(context: context)
    }

    /*
    // Receiver
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        // handle receiving application context
        
        DispatchQueue.main.async() {
            // make sure to put on the main queue to update UI!
        }
    }*/
}
