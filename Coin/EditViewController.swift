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
    
    let id = ["bitcoin", "ethereum", "ethereum-classic", "karbowanec",]
   
    var ticker = [Ticker]()
    var cryptocurrency = [Ticker]()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "editCryptocurrency")
        
        

        print("open")
        print(ticker.count)
        for id in id {
            if let tick = ticker.first(where: {$0.id == id}) {
                cryptocurrency.append(tick)
                print(tick.name)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.isEditing = true
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
