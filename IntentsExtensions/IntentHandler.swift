//
//  IntentHandler.swift
//  IntentsExtensions
//
//  Created by Valentyn Mialin on 9/20/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//
//Abstract:
//IntentHandler that vends instances of ShowRateIntent for iOS

import Intents

class IntentHandler: INExtension{
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ShowRateIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        return ShowRateIntentHandler()
    }
}
