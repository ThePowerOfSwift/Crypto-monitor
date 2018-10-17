//
//  CryptocurrencyInfoViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 13.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import Charts
import CryptoCurrency
import Alamofire
import CoreSpotlight
import Intents
import IntentsUI
import os.log

class CryptocurrencyInfoViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
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
            loadCoinDetails()
            getMarketChart()
        }
    }
    
    var marketChart: MarketChart? {
        didSet {
            lineViewSettingFormatter()
            lineView()
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
//        loadCoinDetails()
//        getMarketChart()
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
        
        // Chart
        lineChartView?.isHidden = true
        lineChartView?.delegate = self
        lineChartView?.chartDescription?.enabled = false
        lineChartView?.gridBackgroundColor = UIColor.darkGray
        lineChartView?.noDataText = NSLocalizedString("No data load", comment: "lineChartView noDataText")
        
        lineChartView?.leftAxis.enabled = false
        lineChartView?.legend.enabled = false
        lineChartView?.scaleYEnabled = false
        
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
        guard let indexZoom = self.zoomSegmentedControl?.selectedSegmentIndex else { return }
        
        self.lineChartView?.isHidden = true
        self.lineChartActivityIndicator?.isHidden = false
        self.LineChartErrorView?.isHidden = true
        
        let period = Coingecko.Period(index: indexZoom)
        print(period)
        Coingecko.getMarketChart(id: coin.id, period: period) { [weak self] response in
            switch response {
            case .success(let marketChart):
                self?.marketChart = marketChart
            case .failure(let error):
                self?.lineChartErrorView(error: error)
            }
        }
    }
    
    private func lineView() {
        guard let marketChart = self.marketChart else { return }
        let selectedSegmentIndex = self.selectSegmentedControl.selectedSegmentIndex
        
        DispatchQueue .global (qos: .userInitiated) .async {
            // Creating an array of data entries
            var yVals1 = [ChartDataEntry]()
            switch selectedSegmentIndex  {
            case 0:
               yVals1 = marketChart.marketCaps.map({ChartDataEntry(x: $0.first! / 1000, y: $0.last!)})
            case 1:
                yVals1 = marketChart.prices.map({ChartDataEntry(x: $0.first! / 1000, y: $0.last!)})
            case 2:
                yVals1 = marketChart.totalVolumes.map({ChartDataEntry(x: $0.first! / 1000, y: $0.last!)})
            default:
                break
            }
            
            // Create a data set with our array
            let set1 = LineChartDataSet(values: yVals1, label: nil)
            set1.drawValuesEnabled = false // Убрать надписи
            set1.drawCirclesEnabled = false
            set1.setColor(UIColor.black) // color line
            set1.highlightEnabled = false
            
            if selectedSegmentIndex == 3 || selectedSegmentIndex == 0 {
                set1.fill = Fill.fillWithColor(.black)
                set1.fillAlpha = 1.0
                set1.drawFilledEnabled = true // Draw the Gradient
                
                self.lineChartView?.animate(yAxisDuration: 2.0)
            }
            else{
                self.lineChartView?.animate(xAxisDuration: 2.0)
            }
            
            //3 - create an array to store our LineChartDataSets
            var dataSets : [LineChartDataSet] = [LineChartDataSet]()
            dataSets.append(set1)
            
            //4 - pass our months in for our x-axis label value along with our dataSets
            let data: LineChartData = LineChartData(dataSets: dataSets)
            //  data.setValueTextColor(UIColor.white)
            
            //5 - finally set our data
            DispatchQueue.main.async() {
                self.lineChartView?.isHidden = false
                self.lineChartActivityIndicator.isHidden = true
                self.LineChartErrorView.isHidden = true
                
                self.lineChartView?.data = data
            }
        }
        
    }
    
    private func lineViewSettingFormatter() {
//
//        self.lineChartView?.isHidden = true
//        self.lineChartActivityIndicator?.isHidden = false
//        self.LineChartErrorView?.isHidden = true
//
        let xAxis = self.lineChartView?.xAxis
        xAxis?.labelPosition = .bottom
        
        // xAxis.labelCount = 3
        xAxis?.drawLabelsEnabled = true
        xAxis?.drawLimitLinesBehindDataEnabled = true
        xAxis?.avoidFirstLastClippingEnabled = true
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        switch self.zoomSegmentedControl.selectedSegmentIndex {
        case 0:
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(4.0)
        case 1:
            xAxis?.labelCount = 7
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 2:
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 3:
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 4:
            xAxis?.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(1.75)
        case 5:
            xAxis?.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(1.0)
        case 6:
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("MM.yy")
            self.lineChartView?.viewPortHandler.setMaximumScaleX(3.0)
        default:
            break
        }
        // Set the x values date formatter
        xAxis?.valueFormatter = ChartXAxisFormatter(dateFormatter: dateFormatter)
    }
    
    
    private func viewCoin() {
        guard let coin = coin else { return }
        
        self.title = coin.symbol.uppercased()
        self.nameLabel?.text  = coin.name
    }
    
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
        lineView()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        guard let index = self.zoomSegmentedControl?.selectedSegmentIndex else { return }
        SettingsUserDefaults.setZoomChart(segmentIndex: index)
        getMarketChart()
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
