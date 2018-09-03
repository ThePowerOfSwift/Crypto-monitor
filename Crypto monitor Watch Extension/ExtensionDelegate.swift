//
//  ExtensionDelegate.swift
//  Crypto monitor Watch Extension
//
//  Created by Mialin Valentin on 24.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import WatchKit
import CryptoCurrency

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate, URLSessionDelegate {
    
    var savedTask:WKRefreshBackgroundTask?
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        BackgroundRefresh.schedule()
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
     //   scheduleBackgroundRefresh(in: 3 * 60)
    }
    
    func applicationWillResignActive() {
        print("applicationWillResignActive")
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
                scheduleURLSession()
                BackgroundRefresh.schedule()
                
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
    
    func scheduleURLSession() {
        print("scheduleURLSession")
        var urlString = "https://api.coinmarketcap.com/v1/ticker/"
        urlString.append("?convert=\(SettingsUserDefaults.getCurrentCurrency().rawValue)")
        urlString.append("&limit=0")
        
        
        if let url = URL(string: urlString) {
            let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
            backgroundConfigObject.sessionSendsLaunchEvents = true
            backgroundConfigObject.timeoutIntervalForResource = 60
            let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
            
            let task = backgroundSession.downloadTask(with: url)
            task.resume()
        } else {
            print("Url error")
        }
    }
    
    //MARK: Delegate methods
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("urlSession")
        
        
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
                   // print(tickerFilterArray)
                    SettingsUserDefaults.setUserDefaults(ticher: tickerFilterArray)
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
            self.savedTask?.setTaskCompletedWithSnapshot(false)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Session did complete")
    }
}



