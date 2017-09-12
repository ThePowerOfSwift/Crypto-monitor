//
//  ExtensionDelegate.swift
//  Crypto monitor Watch Extension
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit

let timeIntervalRefresh = TimeInterval(15 * 60)

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: timeIntervalRefresh), userInfo: nil) { (error: Error?) in
            if let error = error {
                print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
            }
        }
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task : WKRefreshBackgroundTask in backgroundTasks {
            print("received background task: ", task)
            // only handle these while running in the background
            if (WKExtension.shared().applicationState == .background) {
                // Use a switch statement to check the task type
                switch task {
                case let backgroundTask as WKApplicationRefreshBackgroundTask:
                    // Be sure to complete the background task once you’re done.
                    print("backgroundTask \(Date())")
                    
                    if let idArray = UserDefaults().array(forKey: "id") as? [String] {
                        if !idArray.isEmpty {
                            NetworkRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                                if error == nil {
                                    if let ticker = ticker {
                                        self.setUserDefaults(ticher: ticker, idArray: idArray, lastUpdate: Date())
                                        DispatchQueue.main.async() {
                                            let complicationServer = CLKComplicationServer.sharedInstance()
                                            for complication in complicationServer.activeComplications! {
                                                print("UPDATE backgroundTask")
                                                complicationServer.reloadTimeline(for: complication)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                    
                    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: timeIntervalRefresh), userInfo: nil) { (error: Error?) in
                        if let error = error {
                            print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
                        }
                    }
                    
                    backgroundTask.setTaskCompleted()
                case let snapshotTask as WKSnapshotRefreshBackgroundTask:

                    print("snapshotTask \(Date())")
                    snapshotTask.setTaskCompleted(restoredDefaultState: false, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                    
                case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                    // Be sure to complete the connectivity task once you’re done.
                    connectivityTask.setTaskCompleted()
                case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                    // Be sure to complete the URL session task once you’re done.
                    urlSessionTask.setTaskCompleted()
                default:
                    // make sure to complete unhandled task types
                    task.setTaskCompleted()
                }
            }
        }
    }

    func setUserDefaults(ticher: [Ticker], idArray: [String], lastUpdate: Date) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: ticher)
        let userDefaults = UserDefaults()
        userDefaults.set(idArray, forKey: "id")
        userDefaults.set(encodedData, forKey: "cryptocurrency")
        userDefaults.set(lastUpdate, forKey: "lastUpdate")
        userDefaults.synchronize()
    }
 

}
