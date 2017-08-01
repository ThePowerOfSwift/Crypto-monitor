//
//  TodayViewController.swift
//  Cryptocurrency monitor widget
//
//  Created by Mialin Valentin on 01.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tableView: UITableView!


    var id = [String]()
    
    let x = ["ss", "sdf", "freger"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let keyStore = NSUbiquitousKeyValueStore ()
        print(keyStore.array(forKey: "id") as! [String])
        id = keyStore.array(forKey: "id") as! [String]
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.preferredContentSize.height = 200
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let keyStore = NSUbiquitousKeyValueStore ()
        id = keyStore.array(forKey: "id") as! [String]
        self.tableView.reloadData()
        
        
        completionHandler(NCUpdateResult.newData)
    }
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            let height = 44.0 * Float(id.count)
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
        }
        else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return id.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellIdentifier", for: indexPath)
        
        let item = id[indexPath.row]
        cell.textLabel?.text = item
        cell.textLabel?.textColor = UIColor.black
        
        return cell
    }
}
