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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "editCryptocurrency")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.isEditing = true
        cryptocurrencyView()
    }
    

    func cryptocurrencyView() {
        if let subviews = self.view.superview?.subviews {
            for view in subviews{
                if (view is LoadSubview || view is ErrorSubview) {
                    view.removeFromSuperview()
                }
            }
        }
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
         cryptocurrencyView()
    }
    
    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        cryptocurrencyView()
        print("iCloud key-value-store change detected")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTickerID.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "editCryptocurrency", for: indexPath) as! EditTableViewCell
        
       let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(getTickerID[row].id).png")!
        cell.cryptocurrencyImageView.af_setImage(withURL: url)
        cell.cryptocurrencyNameLabel?.text = getTickerID[row].name

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{          
            let keyStore = NSUbiquitousKeyValueStore ()
            
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                
                if let index = idArray.index(of: getTickerID[indexPath.row].id){
                    idArray.remove(at: index)
                    getTickerID.remove(at: indexPath.row)
                    
                    keyStore.set(idArray, forKey: "id")
                    keyStore.synchronize()
                }
                cryptocurrencyView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       
        let keyStore = NSUbiquitousKeyValueStore ()
        
        if var idArray = keyStore.array(forKey: "id") as? [String] {
            
            if let index = idArray.index(of: getTickerID[sourceIndexPath.row].id){
                idArray.remove(at: index)
                idArray.insert(getTickerID[sourceIndexPath.row].id, at: destinationIndexPath.row)
                getTickerID.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                print(getTickerID)
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
            }
        }
        

    }

    
    @IBAction func Done(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
