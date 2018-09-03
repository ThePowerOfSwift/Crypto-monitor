//
//  BackgroundRefresh.swift
//  Crypto monitor Watch Extension
//
//  Created by Valentyn Mialin on 9/4/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import WatchKit

class BackgroundRefresh {
    static func schedule() {
        let fireDate = Date(timeIntervalSinceNow: 60 * 45)
        print("scheduleBackgroundRefresh \(fireDate)")
        // optional, any SecureCoding compliant data can be passed here
        let userInfo = ["reason" : "background update"] as NSDictionary
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: fireDate, userInfo: userInfo) { (error) in
            if (error == nil) {
                print("successfully scheduled background task, use the crown to send the app to the background and wait for handle:BackgroundTasks to fire.")
            }
        }
    }
}
