//
//  AppDelegate.swift
//  Coin
//
//  Created by Mialin Valentin on 11.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if !keyStore.bool(forKey: "launchedBefore"){
            
            keyStore.set(["bitcoin", "ethereum", "ripple", "bitcoin-cash"], forKey: "id")
            
            keyStore.set(1, forKey: "percentChange")
            keyStore.set(1, forKey: "typeChart")
            keyStore.set(1, forKey: "zoomChart")
            keyStore.set(true, forKey: "launchedBefore")
            keyStore.synchronize()
        }
        
        /*
        let backImage = UIImage(named: "BackNavigation")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -80.0), for: .default)
        */
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // When you type customSchemeExample://red in the search bar in Safari
        
        if let urlComponents =  NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let queryItems = urlComponents.queryItems as [NSURLQueryItem]?{
                for queryItem in queryItems {
                    if queryItem.name == "id" {
                        if let id = queryItem.value {
                            openID = id
                        }
                    }
                }
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let detailController = storyboard.instantiateViewController(withIdentifier: "CryptocurrencyInfoViewControllerID") as! CryptocurrencyInfoViewController
        (self.window?.rootViewController as! UINavigationController).popToRootViewController(animated: false)
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        (self.window?.rootViewController as! UINavigationController).pushViewController(detailController, animated: false)
        
        return true
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

