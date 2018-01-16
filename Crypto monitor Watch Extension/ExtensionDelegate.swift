//
//  ExtensionDelegate.swift
//  Crypto monitor Watch Extension
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import CryptoCurrency

let timeIntervalRefresh = TimeInterval(30 * 60)

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate, URLSessionDelegate {
    
    var savedTask:WKRefreshBackgroundTask?
    
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
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                print("backgroundTask \(Date())")
                
                let config = URLSessionConfiguration.background(withIdentifier: "asdfghjkl")
                
                config.waitsForConnectivity = true
                config.sessionSendsLaunchEvents = true
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                
                var urlString = "https://api.coinmarketcap.com/v1/ticker/"
                urlString.append("?convert=\(SettingsUserDefaults().getCurrentCurrency().rawValue)")
                urlString.append("&limit=0")
                
                let task = session.downloadTask(with: URL(string: urlString)!)
                task.resume()
                
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: timeIntervalRefresh), userInfo: nil) { (error: Error?) in
                    if let error = error {
                        print("Error occurred while scheduling background refresh: \(error.localizedDescription)")
                    }
                }
                self.savedTask = backgroundTask
            //  backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                print("snapshotTask \(Date())")
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                
                print("WKURLSessionRefreshBackgroundTask \(Date())")
                urlSessionTask.setTaskCompletedWithSnapshot(true)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    //MARK: Delegate methods
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print ("server error")
                return
        }
        
        do {
            let data = try Data(contentsOf: location)
            if let idArray = UserDefaults().array(forKey: "id") as? [String], !idArray.isEmpty {
                let decoder = JSONDecoder()
                do {
                    let tickerDecodeArray = try decoder.decode([Ticker].self, from: data)
                    var tickerFilterArray = [Ticker]()
                    for id in idArray{
                        if let json = tickerDecodeArray.filter({ $0.id == id}).first{
                            tickerFilterArray.append(json)
                        }
                    }
                    
                    SettingsUserDefaults().setUserDefaults(ticher: tickerFilterArray, idArray: idArray, lastUpdate: Date())
                    DispatchQueue.main.async {
                        let complicationServer = CLKComplicationServer.sharedInstance()
                        complicationServer.activeComplications?.forEach(complicationServer.reloadTimeline)
                    }
                    self.savedTask?.setTaskCompletedWithSnapshot(true)
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                }
            }
        }
        catch{
            print("error read file")
        }
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    
}



