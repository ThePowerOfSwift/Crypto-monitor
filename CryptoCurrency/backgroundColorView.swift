//
//  backgroundColorView.swift
//  Coin
//
//  Created by Valentyn Mialin on 9/24/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import UIKit

public class PercentChangeView: UIViewController {
    public static func backgroundColor(view: UIView?, percentChange: Double?) {
        guard let view = view else { return }
        guard let percentChange = percentChange else {
            view.backgroundColor = .orange
            return
        }
        
        if percentChange >= 0 {
            view.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
        }
        else{
            view.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
        }
    }
}
    


