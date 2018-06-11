//
//  ReviewRequest.swift
//  Coin
//
//  Created by Mialin Valentin on 02.02.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation


import Foundation
import StoreKit

class Review {
    
    static private let runIncrementerSetting = "numberOfRuns"  // UserDefauls dictionary key where we store number of runs
    static private let minimumRunCount = 5                     // Minimum number of runs that we should have until we ask for review
    
    static public func IncrementAppRuns() {                   // counter for number of runs for the app. You can call this from App Delegate
        
        let usD = UserDefaults()
        let runs = getRunCounts() + 1
        usD.setValuesForKeys([runIncrementerSetting: runs])
        usD.synchronize()
        
    }
    
    static public func showReview() {
        
        let runs = getRunCounts()
        print("Show Review")
        
        if (runs > minimumRunCount) {
            
            if #available(iOS 10.3, *) {
                print("Review Requested")
                SKStoreReviewController.requestReview()
            }
            
        } else {
            print("Runs are now enough to request review!")
            
        }
    }
    
    static private func getRunCounts () -> Int {               // Reads number of runs from UserDefaults and returns it.
        
        let usD = UserDefaults()
        let savedRuns = usD.value(forKey: runIncrementerSetting)
        
        var runs = 0
        if (savedRuns != nil) {
            
            runs = savedRuns as! Int
        }
        
        print("Run Counts are \(runs)")
        return runs
        
    }

}



