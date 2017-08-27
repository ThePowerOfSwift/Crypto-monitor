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
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
      //  let message = applicationContext["message"] as? String
      //  messageLabel.setText(message)
        print("data")

        NSKeyedUnarchiver.setClass(Ticker.self, forClassName: "Ticker")
        let data = applicationContext["data"] as? Data
        if let data = data {
            if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: data ) as? [Ticker] {
                tableView(ticker: cacheTicker)
            }
        }
    }

    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func awake(withContext context: Any?) {
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func tableView(ticker: [Ticker])  {
        cryptocurrencyTable.setNumberOfRows(ticker.count, withRowType: "cell")
        for index in 0..<cryptocurrencyTable.numberOfRows {
            guard let controller = cryptocurrencyTable.rowController(at: index) as? cryptocurrencyRowController else { continue }
            controller.ticker = ticker[index]
        }

    }
    
    
    
    /*
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Received context")
        print(applicationContext["FlightTime"])
    }
    */
    /*
    private func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Received context")
        print(applicationContext["data"])
        
        let data = applicationContext["data"]
        
        if let cacheTicker = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? [Ticker] {
            tableView(ticker: cacheTicker)
        }
        
    }*/

}

