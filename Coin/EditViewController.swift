//
//  EditViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 20.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var percentChangeSegmentedControl: UISegmentedControl!
    
    var id : [String]?
   
    var ticker = [Ticker]()
    var cryptocurrency = [Ticker]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        percentChangeSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "percentChange"))
        
        tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "editCryptocurrency")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.isEditing = true
        cryptocurrencyView()
    }
    

    func cryptocurrencyView() {
        let keyStore = NSUbiquitousKeyValueStore ()
        if let idArray = keyStore.array(forKey: "id") as? [String] {
            
            cryptocurrency.removeAll()
            for id in idArray {
                if let tick = ticker.first(where: {$0.id == id}) {
                    cryptocurrency.append(tick)
                }
            }
            tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        cryptocurrencyView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "editCryptocurrency", for: indexPath) as! EditTableViewCell
        
       let row = indexPath.row
        
        let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/32x32/\(cryptocurrency[row].id).png")!
        cell.cryptocurrencyImageView.af_setImage(withURL: url)
        cell.cryptocurrencyNameLabel?.text = cryptocurrency[row].name

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
        print("Delete " + String(indexPath.row))
            
            let keyStore = NSUbiquitousKeyValueStore ()
            
         //   cryptocurrency.remove(at: indexPath.row)
            
            if var idArray = keyStore.array(forKey: "id") as? [String] {
                
                if let index = idArray.index(of: cryptocurrency[indexPath.row].id){
                    idArray.remove(at: index)
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
            
            if let index = idArray.index(of: cryptocurrency[sourceIndexPath.row].id){
                idArray.remove(at: index)
                idArray.insert(cryptocurrency[sourceIndexPath.row].id, at: destinationIndexPath.row)
                
                keyStore.set(idArray, forKey: "id")
                keyStore.synchronize()
            }
        }
        
    }
    
    @IBAction func percentIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(percentChangeSegmentedControl.selectedSegmentIndex, forKey: "percentChange")
        keyStore.synchronize()
    }
    
    @IBAction func Done(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            
            if let navVC = segue.destination as? UINavigationController {
                if let vc = navVC.viewControllers.first as? AddTableViewController {
                    vc.ticker = ticker
                }
            }
        }
    }
}
