//
//  LoadSubview.swift
//  Coin
//
//  Created by Mialin Valentin on 28.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class LoadSubview: UIView {
     var view:UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "LoadSubview", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
}
