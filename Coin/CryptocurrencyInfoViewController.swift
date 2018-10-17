//
//  CryptocurrencyInfoViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 13.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency
import Alamofire
import SwiftChart
import CoreSpotlight
import Intents
import IntentsUI
import os.log

class CryptocurrencyInfoViewController: UIViewController {
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var lineChartActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LineChartErrorView: UIView!
    @IBOutlet weak var LineChartErrorLabel: UILabel!
    
    @IBOutlet weak var zoomSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var oneHourChangeView: UIView!
    @IBOutlet weak var oneHourChangeLabel: UILabel!
    @IBOutlet weak var dayChangeView: UIView!
    @IBOutlet weak var dayChangeLabel: UILabel!
    @IBOutlet weak var weekChangeView: UIView!
    @IBOutlet weak var weekChangeLabel: UILabel!
    
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var priceUsdLabel: UILabel!
    @IBOutlet weak var priceBtcLabel: UILabel!
    @IBOutlet weak var priceConvertLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    var coin : Coin? {
        didSet {
            viewCoin()
        }
    }

    weak var coinsDelegate: CoinsDelegate?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(newCurrentCurrency), name: .newCurrentCurrency, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        percentChangeView()
        
        selectSegmentedControl?.selectedSegmentIndex = SettingsUserDefaults.getTypeChart()
        zoomSegmentedControl?.selectedSegmentIndex = SettingsUserDefaults.getZoomChart()
        
        viewCoin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.priceUsdLabel.text = ""
        self.priceBtcLabel.text = ""
        self.priceConvertLabel.text = ""
        self.rankLabel.text = ""
        self.marketcapLabel.text = ""
        self.volumeLabel.text = ""
        loadCoinDetails()
        getMarketChart()
    }
    
    //MARK: - Notification
    @objc func willEnterForeground(_ notification: NSNotification!) {
        if (navigationController?.visibleViewController as? CryptocurrencyInfoViewController) != nil {
            print("unlock 2 ")
            refresh()
        }
    }
    
    @objc func newCurrentCurrency(notification : NSNotification) {
        loadCoinDetails()
    }
    
    private func percentChangeView() {
        oneHourChangeView?.layer.cornerRadius = 3
        oneHourChangeView?.layer.masksToBounds = true
        dayChangeView?.layer.cornerRadius = 3
        dayChangeView?.layer.masksToBounds = true
        weekChangeView?.layer.cornerRadius = 3
        weekChangeView?.layer.masksToBounds = true
    }
    
    
    private func zoomSelectedSegment(index: Int){
        var index = index
        
        if self.zoomSegmentedControl.selectedSegmentIndex >= index && self.zoomSegmentedControl.selectedSegmentIndex <= 4 {
            self.zoomSegmentedControl.selectedSegmentIndex = index
        }
        
        index = index + 1
        for i in index..<5{
            self.zoomSegmentedControl.setEnabled(false, forSegmentAt: i)
        }
    }
    
    private func loadCoinDetails() {
        guard let coin = coin else { return }
        
        
        Coingecko.getCoinDetails(id: coin.id) { [weak self] (response) in
            switch response {
            case .success(let сoinDetails):
                DispatchQueue.main.async() {
                    self?.priceUsdLabel.text = сoinDetails.marketData.currentPriceToString(money: .usd)
                    self?.priceBtcLabel.text = сoinDetails.marketData.currentPriceToString(money: .btc)
                   
                    let money = SettingsUserDefaults.getCurrentCurrency()
                    if money == .usd || money == .btc {
                        self?.priceConvertLabel.text = ""
                    }
                    else{
                        self?.priceConvertLabel.text = сoinDetails.marketData.currentPriceToString(money: money)
                    }
                    
                    self?.rankLabel.text = String(сoinDetails.marketCapRank)
                    let marketData = сoinDetails.marketData
                    self?.marketcapLabel.text = marketData.marketCapToString(money: money)
                    self?.volumeLabel.text = marketData.totalVolumeToString(money: money)

                    // 24h
                    self?.oneHourChangeLabel?.text = marketData.priceChangePercentageToString(period: .priceChange24H, money: money)
                    let priceChangePercentage24H = marketData.priceChangePercentage(period: .priceChange24H, money: money)
                    PercentChangeView.backgroundColor(view:  self?.oneHourChangeView, percentChange: priceChangePercentage24H)
                    // 7d
                    self?.dayChangeLabel?.text = marketData.priceChangePercentageToString(period: .priceChange7D, money: money)
                    let priceChangePercentage7D = marketData.priceChangePercentage(period: .priceChange7D, money: money)
                    PercentChangeView.backgroundColor(view:  self?.dayChangeView, percentChange: priceChangePercentage7D)
                    // 14d
                    self?.weekChangeLabel?.text = marketData.priceChangePercentageToString(period: .priceChange14D, money: money)
                    let priceChangePercentage14D = marketData.priceChangePercentage(period: .priceChange14D, money: money)
                    PercentChangeView.backgroundColor(view:  self?.dayChangeView, percentChange: priceChangePercentage14D)
                }
            case .failure(let error):
                self?.errorAlert(error: error)
            }
        }
}
    
    private func getMarketChart() {
        guard let coin = coin else { return }
        
        Coingecko.getMarketChart(id: coin.id, period: .oneDay) { [weak self] (response) in
            switch response {
            case .success(let marketChart):
                DispatchQueue.main.async() {
                   // print(marketChart)
                }
            case .failure(let error):
                self?.errorAlert(error: error)
            }
        }
    }
    private func viewCoin() {
        guard let coin = coin else { return }
        
        self.title = coin.symbol.uppercased()
        self.nameLabel?.text  = coin.name
    }

//    private func viewCryptocurrencyInfo() {
//        DispatchQueue.main.async() {
//            self.refreshBarButtonItem()
//
//            guard let ticker = self.ticker else { return }
//
//            // title
//            self.navigationItem.title = ticker.symbol
//
//            let money = SettingsUserDefaults.getCurrentCurrency()
//
//            self.nameLabel?.text = ticker.name
//
//            self.priceUsdLabel?.text = ticker.priceToString(for: .usd)
//            self.priceBtcLabel?.text = ticker.priceBtcToString()
//
//            if money == .usd || money == .btc {
//                self.priceConvertLabel?.text = ""
//            }
//            else{
//                self.priceConvertLabel?.text = ticker.priceToString(for: money)
//            }
//
//            // 1h
//            self.oneHourChangeLabel?.text = ticker.percentChange1h != nil ? "\(ticker.percentChange1h!)%" : "-"
//            PercentChangeView.backgroundColor(view:  self.oneHourChangeView, percentChange: ticker.percentChange1h)
//            // 24h
//            self.dayChangeLabel?.text = ticker.percentChange24h != nil ? "\(ticker.percentChange24h!)%" : "-"
//            PercentChangeView.backgroundColor(view:  self.dayChangeView, percentChange: ticker.percentChange24h)
//            // 7d
//            self.weekChangeLabel?.text = ticker.percentChange7d != nil ? "\(ticker.percentChange7d!)%" : "-"
//            PercentChangeView.backgroundColor(view:  self.weekChangeView, percentChange: ticker.percentChange7d)
//
//            self.rankLabel?.text = String(ticker.rank)
//
//            self.marketcapLabel?.text = ticker.marketCapToString(for: money, maximumFractionDigits: 10)
//            self.volumeLabel?.text = ticker.volumeToString(for: money, maximumFractionDigits: 10)
//        }
//    }
    
    private func refreshBarButtonItem(){
        let refreshBarButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        self.navigationItem.rightBarButtonItem = refreshBarButton
    }
    
    @objc private func refresh() {
        loadCoinDetails()
      //  loadlineView()
    }
    
    private func startRefreshActivityIndicator() {
        DispatchQueue.main.async() {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
            activityIndicator.color = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            let refreshBarButton = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.rightBarButtonItem = refreshBarButton
            activityIndicator.startAnimating()
        }
    }
    
    @IBAction func selectIindexChanged(_ sender: UISegmentedControl) {
        guard let index = self.selectSegmentedControl?.selectedSegmentIndex else { return }
        SettingsUserDefaults.setTypeChart(segmentIndex: index)
       // lineView()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        guard let index = self.zoomSegmentedControl?.selectedSegmentIndex else { return }
        SettingsUserDefaults.setZoomChart(segmentIndex: index)
      //  loadlineView()
    }
    
    //MARK: - Siri Shortcut
    @available(iOS 12.0, *)
    private func addVoiceShortcutButton() {
        let intent = ShowPriceIntent()
        intent.id = self.coin!.id
        intent.name = self.coin!.name
        
        let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
        addShortcutButton.shortcut = INShortcut(intent: intent)
        addShortcutButton.delegate = self
        addShortcutButton.tag = 99
        
        addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
        for view in self.view.subviews {
            if view.tag == 99 {
                view.removeFromSuperview()
            }
        }
        self.view.addSubview(addShortcutButton)
        self.view.rightAnchor.constraint(equalTo: addShortcutButton.rightAnchor, constant: 8.0).isActive = true
        self.priceStackView.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
        self.priceStackView.rightAnchor.constraint(equalTo: addShortcutButton.leftAnchor, constant: -8.0).isActive = true
    }
    
    //MARK: - ErrorSubview
    func errorAlert(error: Error) {
        if (error as NSError).code != -999 {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func lineChartErrorView(error: Error) {
        if (error as NSError).code != -999 {
            DispatchQueue.main.async() {
                self.LineChartErrorView.isHidden = false
                self.refreshBarButtonItem()
                self.LineChartErrorLabel.text = error.localizedDescription
            }
        }
    }
}

extension CryptocurrencyInfoViewController: CoinDelegate {
    func coinSelected(_ coin: Coin) {
        
        self.coin = coin

        
        
        
//        self.ticker = ticker
//        self.lineChartView?.clear()
//        if #available(iOS 12.0, *) {
//            addVoiceShortcutButton()
//        }
//        
//        loadTicker()
//        loadlineView()
//        getMinDateCharts()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
