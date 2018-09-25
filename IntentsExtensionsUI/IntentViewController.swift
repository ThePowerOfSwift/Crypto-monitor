//
//  IntentViewController.swift
//  IntentsExtensionsUI
//
//  Created by Valentyn Mialin on 9/20/18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import IntentsUI
import CryptoCurrency

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceUsdLabel: UILabel!
    @IBOutlet weak var priceBtcLabel: UILabel!
    
    @IBOutlet weak var oneHourChangeView: UIView!
    @IBOutlet weak var oneHourChangeLabel: UILabel!
    @IBOutlet weak var dayChangeView: UIView!
    @IBOutlet weak var dayChangeLabel: UILabel!
    @IBOutlet weak var weekChangeView: UIView!
    @IBOutlet weak var weekChangeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingChangeView()
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        guard interaction.intent is ShowRateIntent else {
            completion(false, Set(), .zero)
            return
        }
        
        if let response = interaction.intentResponse as? ShowRateIntentResponse {
            
            self.nameLabel?.text = response.name
            
            self.priceUsdLabel?.text = response.priceUSD
            self.priceBtcLabel?.text = response.priceBTC

            // 1h
            self.oneHourChangeLabel?.text = percentChangeToString(percentChange: response.percentChange1h)
            PercentChangeView.backgroundColor(view:  self.oneHourChangeView, percentChange: response.percentChange1h as? Double)
            // 24h
            self.dayChangeLabel?.text = percentChangeToString(percentChange: response.percentChange24h)
            PercentChangeView.backgroundColor(view:  self.dayChangeView, percentChange: response.percentChange24h as? Double)
            // 7d
            self.weekChangeLabel?.text = percentChangeToString(percentChange: response.percentChange7d)
            PercentChangeView.backgroundColor(view:  self.weekChangeView, percentChange: response.percentChange7d as? Double)
        }
        completion(true, parameters, self.desiredSize)
    }
    
    private var desiredSize: CGSize {
        let width = self.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320
        return CGSize(width: width, height: 100)
    }
    
    private func percentChangeToString(percentChange: NSNumber?) -> String {
        return percentChange != nil ? "\(percentChange!)%" : "-"
    }
    
    private func settingChangeView() {
        oneHourChangeView?.layer.cornerRadius = 3
        oneHourChangeView?.layer.masksToBounds = true
        dayChangeView?.layer.cornerRadius = 3
        dayChangeView?.layer.masksToBounds = true
        weekChangeView?.layer.cornerRadius = 3
        weekChangeView?.layer.masksToBounds = true
    }
}
