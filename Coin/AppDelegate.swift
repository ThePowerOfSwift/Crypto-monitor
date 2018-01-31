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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if !keyStore.bool(forKey: "launchedBefore"){
            
            keyStore.set(["bitcoin", "ethereum", "ripple", "bitcoin-cash", "cardano", "litecoin", "neo", "nem", "stellar", "karbowanec"], forKey: "id")
            keyStore.set(1, forKey: "percentChange")
            keyStore.set(1, forKey: "typeChart")
            keyStore.set(1, forKey: "zoomChart")
            keyStore.set(true, forKey: "launchedBefore")
            keyStore.synchronize()
        }

        // NetworkActivityIndicatorManager
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                openID = uniqueIdentifier
                showViewControllet(withIdentifier: "CryptocurrencyInfoViewControllerID")
            }
        }
        return true
    }
    


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // When you type customSchemeExample://red in the search bar in Safari
        
        if let urlComponents =  NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = urlComponents.queryItems as [NSURLQueryItem]?{
                for queryItem in queryItems {
                    
                    switch queryItem.name {
                    case "id":
                        if let id = queryItem.value {
                            openID = id
                            showViewControllet(withIdentifier: "CryptocurrencyInfoViewControllerID")
                        }
                    case "add":
                        showViewControllet(withIdentifier: "CoinTableViewControllerID")
                    default:
                        break
                    }
                }
            }
        }        
        return true
    }

    func showViewControllet(withIdentifier: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let detailController = storyboard.instantiateViewController(withIdentifier: withIdentifier)// as! CryptocurrencyInfoViewController
        (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: false)
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        (self.window?.rootViewController as! UINavigationController).pushViewController(detailController, animated: false)

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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

