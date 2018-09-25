//
//  DZNEmptyData.swift
//  Coin
//
//  Created by Mialin Valentin on 02.02.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//
import DZNEmptyDataSet

// MARK: - Deal with the empty data set
extension MainVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //Add title for empty dataset
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString("No cryptocurrencies", comment: "No cryptocurrencies")
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add description/subtitle on empty dataset
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = NSLocalizedString("Add cryptocurrencies for tracking", comment: "Add cryptocurrencies for tracking")
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add your button
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        let str = NSLocalizedString("Add", comment: "Add")
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline),
                     NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.26, green: 0.47, blue: 0.96, alpha: 1)] as [NSAttributedString.Key : Any]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add action for button
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "add", sender: nil)
    }
}

