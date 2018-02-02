//
//  DZNEmptyData.swift
//  Coin
//
//  Created by Mialin Valentin on 02.02.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//
import DZNEmptyDataSet

// MARK: - Deal with the empty data set
extension CoinTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //Add title for empty dataset
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString("No cryptocurrencies", comment: "No cryptocurrencies")
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add description/subtitle on empty dataset
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString("Add cryptocurrencies for tracking", comment: "Add cryptocurrencies for tracking")
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add your button
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let str = NSLocalizedString("Add", comment: "Add")
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
                     NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.26, green: 0.47, blue: 0.96, alpha: 1)] as [NSAttributedStringKey : Any]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add action for button
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "add", sender: nil)
    }
}

