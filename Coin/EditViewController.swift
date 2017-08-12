//
//  EditViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptocurrencyRequest

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var emptySubview:EmptySubview?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "editCryptocurrency")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.isEditing = true
        
        /*
        if getTickerID == nil {
            self.performSegue(withIdentifier: "addSegue", sender: nil)
        }
        else{
            if getTickerID!.isEmpty {
                self.performSegue(withIdentifier: "addSegue", sender: nil)
            }
        }
*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
         cryptocurrencyView()
    }
    
    
    func cryptocurrencyView() {
        if getTickerID != nil{
            if getTickerID!.isEmpty {
                self.showEmptySubview()
            }
            else{
                if let subviews = self.view?.subviews {
                    for view in subviews{
                        if (view is EmptySubview) {
                            view.removeFromSuperview()
                        }
                    }
                }
                tableView.reloadData()
            }
        }
        else{
            self.showEmptySubview()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getTickerID == nil{
            return 0
        }
        else{
            return getTickerID!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCryptocurrency", for: indexPath) as! EditTableViewCell
        let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(getTickerID![row].id).png")!
        cell.cryptocurrencyImageView.af_setImage(withURL: url)
        cell.cryptocurrencyNameLabel?.text = getTickerID![row].name

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{          
            let keyStore = NSUbiquitousKeyValueStore ()
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                if let index = idArray.index(of: getTickerID![indexPath.row].id){
                    idArray.remove(at: index)
                    getTickerID!.remove(at: indexPath.row)
                    
                    // set iCloud key-value
                    keyStore.set(idArray, forKey: "id")
                    keyStore.synchronize()
                    
                    // set UserDefaults
                    SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
                }
            }
            cryptocurrencyView()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            
            if let index = idArray.index(of: getTickerID![sourceIndexPath.row].id){
                idArray.remove(at: index)
                idArray.insert(getTickerID![sourceIndexPath.row].id, at: destinationIndexPath.row)
                getTickerID!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                
                // set iCloud key-value
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
                
                // set UserDefaults
                SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: nil)
            }
        }
    }

    //MARK:Subview
    func showEmptySubview() {
        
        self.emptySubview = EmptySubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height ))
        self.view.insertSubview(emptySubview!, at: 1)
        self.emptySubview?.addCryptocurrency.addTarget(self, action: #selector(addShow(_:)), for: UIControlEvents.touchUpInside)
        
    }
    
    func addShow(_ sender:UIButton) {
        self.performSegue(withIdentifier: "addSegue", sender: nil)
    }
    
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
