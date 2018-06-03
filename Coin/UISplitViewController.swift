//
//  UISplitViewController.swift
//  Coin
//
//  Created by Valentyn Mialin on 03.06.2018.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation
import UIKit

extension UISplitViewController {
    var primaryViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    var secondaryViewController: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }
}
