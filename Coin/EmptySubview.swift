//
//  EmptySubview.swift
//  Coin
//
//  Created by Mialin Valentin on 11.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class EmptySubview: UIView {
    var view:UIView!

    @IBOutlet weak var addCryptocurrency: UIButton!
    @IBOutlet weak var bottomImageLayout: NSLayoutConstraint!
    
    func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "EmptySubview", bundle: nil)
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
