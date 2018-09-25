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
    @IBOutlet weak var priceUsdLabel: UILabel!
    
    @IBOutlet weak var oneHourChangeView: UIView!
    @IBOutlet weak var oneHourChangeLabel: UILabel!
    @IBOutlet weak var dayChangeView: UIView!
    @IBOutlet weak var dayChangeLabel: UILabel!
    @IBOutlet weak var weekChangeView: UIView!
    @IBOutlet weak var weekChangeLabel: UILabel!
    
    @IBOutlet weak var priceBtcLabel: UILabel!
    @IBOutlet weak var priceConvertLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    
    var ticker : Ticker?
    var currencyCharts: CurrencyCharts?
    let userCalendar = Calendar.current
    var minDate: Date?
    var coinTableViewController: MainVC? = nil
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(newCurrentCurrency), name: .newCurrentCurrency, object: nil)
        
        percentChangeView()
        
        let keyStore = NSUbiquitousKeyValueStore()
        selectSegmentedControl?.selectedSegmentIndex = Int(keyStore.longLong(forKey: "typeChart"))
        zoomSegmentedControl?.selectedSegmentIndex = Int(keyStore.longLong(forKey: "zoomChart"))
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = ticker?.symbol
        lineChartView?.clear()
        
        if #available(iOS 12.0, *) {
            let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
            
            let activity = NSUserActivity(activityType: "Valentyn.Mialin.crypto.monitor.show-currency")
            activity.title = NSLocalizedString("Show the \(String(describing: ticker?.name)) rate", comment: "")
            activity.userInfo = ["tickerID" : ticker?.id ?? "bitcoin"] // 3
            activity.isEligibleForSearch = true // 4
            activity.isEligibleForPrediction = true // 5
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier("Valentyn.Mialin.crypto.monitor.show-currency") // 6
            view.userActivity = activity // 7
            activity.becomeCurrent() // 8
            
            addShortcutButton.shortcut = INShortcut(userActivity: activity)
            addShortcutButton.delegate = self
            
            addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(addShortcutButton)
            self.view.centerXAnchor.constraint(equalTo: addShortcutButton.centerXAnchor).isActive = true
            self.view.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ChartRequest.cancelRequest { _ in }
    }

    @objc func newCurrentCurrency(notification : NSNotification) {
        loadTicker()
    }
    
    private func percentChangeView() {
        oneHourChangeView?.layer.cornerRadius = 3
        oneHourChangeView?.layer.masksToBounds = true
        dayChangeView?.layer.cornerRadius = 3
        dayChangeView?.layer.masksToBounds = true
        weekChangeView?.layer.cornerRadius = 3
        weekChangeView?.layer.masksToBounds = true
        
        lineChartView?.isHidden = true
        lineChartView?.delegate = self
        lineChartView?.chartDescription?.enabled = false
        lineChartView?.gridBackgroundColor = UIColor.darkGray
        lineChartView?.noDataText = NSLocalizedString("No data load", comment: "lineChartView noDataText")
        
        lineChartView?.leftAxis.enabled = false
        lineChartView?.legend.enabled = false
        lineChartView?.scaleYEnabled = false
    }
    
    private func getMinDateCharts() {
        guard let ticker = ticker else { return }
        ChartRequest.getMinDateCharts(id: ticker.id, completion: { [weak self] (minDate: Date?, error : Error?) in
            guard let strongSelf = self else { return }
            if error == nil {
                if let minDate = minDate{
                    strongSelf.minDate = minDate
                    // 1 weak
                    if  minDate >=  strongSelf.userCalendar.date(byAdding: .weekOfYear, value: -1, to: Date())! {
                        strongSelf.zoomSelectedSegment(index: 1)
                    }
                    else{
                        // 1m
                        if  minDate >=  strongSelf.userCalendar.date(byAdding: .month, value: -1, to: Date())! {
                            strongSelf.zoomSelectedSegment(index: 2)
                        }
                        else{
                            // 3m
                            if  minDate >=  strongSelf.userCalendar.date(byAdding: .month, value: -3, to: Date())! {
                                strongSelf.zoomSelectedSegment(index: 3)
                            }
                            else{
                                // 1 year
                                if  minDate >=  strongSelf.userCalendar.date(byAdding: .year, value: -1, to: Date())! {
                                    strongSelf.zoomSelectedSegment(index: 4)
                                }
                            }
                        }
                    }
                }
                strongSelf.loadlineView()
            }
            else{
                strongSelf.lineChartErrorView(error: error!)
            }
        })
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
    
    private func loadTicker() {
        guard let ticker = ticker else { return }
        
        startRefreshActivityIndicator()
        
        let keyStore = NSUbiquitousKeyValueStore()
        guard let idArray = keyStore.array(forKey: "id") as? [String] else { return }
        
        CryptoCurrencyKit.fetchTickers(idArray: idArray) { [weak self] (response) in
            guard let strongSelf = self else { return }
            
            switch response {
            case .success(let tickers):
                SettingsUserDefaults.setUserDefaults(ticher: tickers)
                
                if let ticker = tickers.first(where: {$0.id == ticker.id}) {
                    strongSelf.ticker = ticker
                }
                strongSelf.viewCryptocurrencyInfo()
            case .failure(let error):
                strongSelf.errorAlert(error: error)
            }
        }
    }
    
    private func viewCryptocurrencyInfo() {
        DispatchQueue.main.async() {
            self.refreshBarButtonItem()
            
            guard let ticker = self.ticker else { return }
            
            // title
            self.navigationItem.title = ticker.symbol
            
            let money = SettingsUserDefaults.getCurrentCurrency()
            
            self.nameLabel?.text = ticker.name
            
            self.priceUsdLabel?.text = ticker.priceToString(for: .usd)
            self.priceBtcLabel?.text = ticker.priceBtcToString()
            
            if money == .usd || money == .btc {
                self.priceConvertLabel?.text = ""
            }
            else{
                self.priceConvertLabel?.text = ticker.priceToString(for: money)
            }
            
            // 1h
            self.oneHourChangeLabel?.text = ticker.percentChange1h != nil ? "\(ticker.percentChange1h!)%" : "-"
            PercentChangeView.backgroundColor(view:  self.oneHourChangeView, percentChange: ticker.percentChange1h)
            // 24h
            self.dayChangeLabel?.text = ticker.percentChange24h != nil ? "\(ticker.percentChange24h!)%" : "-"
            PercentChangeView.backgroundColor(view:  self.dayChangeView, percentChange: ticker.percentChange24h)
            // 7d
            self.weekChangeLabel?.text = ticker.percentChange7d != nil ? "\(ticker.percentChange7d!)%" : "-"
            PercentChangeView.backgroundColor(view:  self.weekChangeView, percentChange: ticker.percentChange7d)
            
            self.rankLabel?.text = String(ticker.rank)
            
            self.marketcapLabel?.text = ticker.marketCapToString(for: money, maximumFractionDigits: 10)
            self.volumeLabel?.text = ticker.volumeToString(for: money, maximumFractionDigits: 10)
        }
    }
    
   
    
    private func loadlineView() {
        guard let ticker = ticker else { return }
        guard self.minDate != nil else {
            self.lineView()
            return
        }
        
        lineChartView?.isHidden = true
        lineChartActivityIndicator?.isHidden = false
        LineChartErrorView?.isHidden = true
        
        var of: NSDate?
        
        let xAxis = self.lineChartView?.xAxis
        xAxis?.labelPosition = .bottom
        
        // xAxis.labelCount = 3
        xAxis?.drawLabelsEnabled = true
        xAxis?.drawLimitLinesBehindDataEnabled = true
        xAxis?.avoidFirstLastClippingEnabled = true
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        switch zoomSegmentedControl.selectedSegmentIndex {
        case 0:
            of = userCalendar.date(byAdding: .day, value: -1, to: Date())! as NSDate
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            lineChartView?.viewPortHandler.setMaximumScaleX(4.0)
        case 1:
            of = userCalendar.date(byAdding: .weekOfYear, value: -1, to: Date())! as NSDate
            xAxis?.labelCount = 7
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 2:
            of = userCalendar.date(byAdding: .month, value: -1, to: Date())! as NSDate
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 3:
            of = userCalendar.date(byAdding: .month, value: -3, to: Date())! as NSDate
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView?.viewPortHandler.setMaximumScaleX(1.5)
        case 4:
            of = userCalendar.date(byAdding: .year, value: -1, to: Date())! as NSDate
            xAxis?.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            lineChartView?.viewPortHandler.setMaximumScaleX(1.75)
        case 5:
            of = Calendar.current.date(from: userCalendar.dateComponents([.year], from: Date()))! as NSDate
            xAxis?.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            lineChartView?.viewPortHandler.setMaximumScaleX(1.0)
        case 6:
            xAxis?.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("MM.yy")
            lineChartView?.viewPortHandler.setMaximumScaleX(3.0)
        default:
            break
        }
        
        // Set the x values date formatter
        xAxis?.valueFormatter = ChartXAxisFormatter(dateFormatter: dateFormatter)
        
        ChartRequest.getCurrencyCharts(id: ticker.id, of: of, completion: { [weak self] (currencyCharts: CurrencyCharts?, error: Error?) in
            guard let strongSelf = self else { return }
            if error == nil {
                if let currencyCharts = currencyCharts {
                    strongSelf.currencyCharts = currencyCharts
                    DispatchQueue.main.async() {
                        strongSelf.lineChartView?.zoom(scaleX: 0.0, scaleY: 0.0, x: 0.0, y: 0.0)
                        strongSelf.lineView()
                    }
                }
            }
            else{
                strongSelf.lineChartErrorView(error: error!)
            }
        })
        
    }
    
    private func lineView() {
        lineChartView?.isHidden = false
        lineChartActivityIndicator.isHidden = true
        LineChartErrorView.isHidden = true
        
        if let currencyCharts = self.currencyCharts {
            // Creating an array of data entries
            var yVals1 = [ChartDataEntry]()
            var char = [Chart]()
            
            switch selectSegmentedControl.selectedSegmentIndex {
                
            case 0:
                char = currencyCharts.market_cap_by_available_supply
            case 1:
                char = currencyCharts.price_usd
            case 2:
                char = currencyCharts.price_btc
            case 3:
                char = currencyCharts.volume_usd
            default:
                break
            }
            
            for i in char {
                yVals1.append(ChartDataEntry(x: Double(Int(i.timestamp / 1000)), y: Double(i.item)))
            }
            
            // Create a data set with our array
            let set1 = LineChartDataSet(values: yVals1, label: nil)
            set1.drawValuesEnabled = false // Убрать надписи
            set1.drawCirclesEnabled = false
            set1.setColor(UIColor.black) // color line
            set1.highlightEnabled = false
            
            if selectSegmentedControl.selectedSegmentIndex == 3 || selectSegmentedControl.selectedSegmentIndex == 0 {
                set1.fill = Fill.fillWithColor(.black)
                set1.fillAlpha = 1.0
                set1.drawFilledEnabled = true // Draw the Gradient
                
                lineChartView?.animate(yAxisDuration: 2.0)
            }
            else{
                lineChartView?.animate(xAxisDuration: 2.0)
            }
            
            //3 - create an array to store our LineChartDataSets
            var dataSets : [LineChartDataSet] = [LineChartDataSet]()
            dataSets.append(set1)
            
            //4 - pass our months in for our x-axis label value along with our dataSets
            let data: LineChartData = LineChartData(dataSets: dataSets)
            //  data.setValueTextColor(UIColor.white)
            
            //5 - finally set our data
            self.lineChartView?.data = data
        }
    }
    
    private func refreshBarButtonItem(){
        let refreshBarButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        self.navigationItem.rightBarButtonItem = refreshBarButton
    }
    
    @objc func refresh() {
        loadTicker()
        loadlineView()
    }
    
    private func startRefreshActivityIndicator() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.color = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        let refreshBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = refreshBarButton
        activityIndicator.startAnimating()
    }
    
    @IBAction func selectIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(selectSegmentedControl?.selectedSegmentIndex, forKey: "typeChart")
        keyStore.synchronize()
        lineView()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(zoomSegmentedControl?.selectedSegmentIndex, forKey: "zoomChart")
        keyStore.synchronize()
        loadlineView()
    }

    @objc func reload(_ sender:UIButton) {
        refresh()
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
    func coinSelected(_ ticker: Ticker) {
        self.ticker = ticker
        viewCryptocurrencyInfo()
        loadTicker()
        getMinDateCharts()
    }
}

@available(iOS 12.0, *)
extension CryptocurrencyInfoViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    /// - Tag: edit_phrase
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}
@available(iOS 12.0, *)
extension CryptocurrencyInfoViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
@available(iOS 12.0, *)
extension CryptocurrencyInfoViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter
            else {
                return ""
        }
        let date = Date(timeIntervalSince1970: value )
        return dateFormatter.string(from: date)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
