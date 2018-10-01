//
//  AppDelegate.swift
//  Coin
//
//  Created by Mialin Valentin on 11.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator
import CryptoCurrency
import CoreSpotlight
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var masterViewController: MainVC?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //SplitViewController
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let rightNavController = splitViewController.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? CryptocurrencyInfoViewController
            else { fatalError() }
        
        splitViewController.preferredDisplayMode = .allVisible
        
        self.masterViewController = leftNavController.topViewController as? MainVC
        self.masterViewController?.coinDelegate = detailViewController
        detailViewController.coinsDelegate = masterViewController
        
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if !keyStore.bool(forKey: "launchedBefore"){
            
            keyStore.set(["bitcoin", "ethereum", "ripple", "bitcoin-cash", "cardano", "litecoin", "neo", "nem", "stellar", "karbowanec"], forKey: "id")
            keyStore.set(1, forKey: "percentChange")
            keyStore.set(1, forKey: "typeChart")
            keyStore.set(1, forKey: "zoomChart")
            keyStore.set(true, forKey: "launchedBefore")
            keyStore.synchronize()
        }
        
        // Load IAP
        IAPHandler.shared.requestProducts()
        
        Review.IncrementAppRuns()

        // NetworkActivityIndicatorManager
        NetworkActivityIndicatorManager.shared.isEnabled = true

        return true
    }
    

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        print(userActivity.activityType)
        
        if userActivity.activityType == CSSearchableItemActionType {
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                showTicker(tickerID: id)
            }
        } else{
            if #available(iOS 12.0, *) {
                if userActivity.activityType == "Valentyn.Mialin.crypto.monitor.show-currency" {
                    if let intent = userActivity.interaction?.intent as? ShowRateIntent,
                        let id = intent.id{
                        showTicker(tickerID: id)
                    }
                }
            }
        }
        return true
    }
    
    private func showTicker(tickerID: String) {
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(tickerID, forKey: "selectDefaultItemID")
        keyStore.synchronize()
        self.masterViewController?.showTickerID(tickerID: tickerID)
    }
    


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // When you type customSchemeExample://red in the search bar in Safari
        
        if let urlComponents =  NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = urlComponents.queryItems as [NSURLQueryItem]?{
                for queryItem in queryItems {
                    
                    switch queryItem.name {
                    case "id":
                        if let tickerID = queryItem.value {
                            let keyStore = NSUbiquitousKeyValueStore ()
                            keyStore.set(tickerID, forKey: "selectDefaultItemID")
                            keyStore.synchronize()
                            
                            self.masterViewController?.showTickerID(tickerID: tickerID)
                        }
                    case "add":
                        self.masterViewController?.emptyTicker()
                    default:
                        break
                    }
                }
            }
        }        
        return true
    }

    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error) {
        

            let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
            print(message)

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    //    print("AppDelegate applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

