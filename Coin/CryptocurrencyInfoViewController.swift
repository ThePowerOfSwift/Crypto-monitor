//
//  CryptocurrencyInfoViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 13.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import Charts
import CryptocurrencyRequest
import AlamofireImage

class CryptocurrencyInfoViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lineChartActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LineChartErrorView: UIView!
    @IBOutlet weak var LineChartErrorLabel: UILabel!
    
    @IBOutlet weak var zoomSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataCurrencyLabel: UILabel!
    
    
    @IBOutlet weak var oneHourChangeView: UIView!
    @IBOutlet weak var oneHourChangeLabel: UILabel!
    @IBOutlet weak var dayChangeView: UIView!
    @IBOutlet weak var dayChangeLabel: UILabel!
    @IBOutlet weak var weekChangeView: UIView!
    @IBOutlet weak var weekChangeLabel: UILabel!
    
    
    @IBOutlet weak var dataSecondaryLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    
    
    var ticker : Ticker?
    var loadSubview:LoadSubview?
    var errorSubview:ErrorSubview?
    var currencyCharts: CurrencyCharts?
    let userCalendar = Calendar.current
    
    let formatterCurrencyUSD: NumberFormatter = {
        let formatterCurrencyUSD = NumberFormatter()
        formatterCurrencyUSD.numberStyle = .currency
        formatterCurrencyUSD.currencyCode = "USD"
        formatterCurrencyUSD.maximumFractionDigits = 10
        formatterCurrencyUSD.locale = Locale(identifier: "en_US")
        return formatterCurrencyUSD
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        self.title = ticker?.name
        
        // percent change view
        oneHourChangeView.layer.cornerRadius = 3
        oneHourChangeView.layer.masksToBounds = true
        dayChangeView.layer.cornerRadius = 3
        dayChangeView.layer.masksToBounds = true
        weekChangeView.layer.cornerRadius = 3
        weekChangeView.layer.masksToBounds = true
        
        lineChartView.isHidden = true
        lineChartView.delegate = self
        lineChartView.chartDescription?.enabled = false
        lineChartView.gridBackgroundColor = UIColor.darkGray
        lineChartView.noDataText = "No data load"
        
        lineChartView.leftAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.scaleYEnabled = false
        
        let font = UIFont.systemFont(ofSize: 10)
        selectSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        let keyStore = NSUbiquitousKeyValueStore ()
        selectSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "typeChart"))
        zoomSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "zoomChart"))
        /*
         if getTickerID == nil {
         refresh()
         }
         */
        AlamofireRequest().getMinDateCharts(id: openID, completion: { (minDate: Date?, error : Error?) in
            if error == nil {
                if let minDate = minDate{
                    // 1 weak
                    if  minDate >=  self.userCalendar.date(byAdding: .weekOfYear, value: -1, to: Date())! {
                        self.zoomSelectedSegment(index: 1)
                    }
                    else{
                        // 1m
                        if  minDate >=  self.userCalendar.date(byAdding: .month, value: -1, to: Date())! {
                            self.zoomSelectedSegment(index: 2)
                        }
                        else{
                            // 3m
                            if  minDate >=  self.userCalendar.date(byAdding: .month, value: -3, to: Date())! {
                                self.zoomSelectedSegment(index: 3)
                            }
                            else{
                                // 1 year
                                if  minDate >=  self.userCalendar.date(byAdding: .year, value: -1, to: Date())! {
                                    self.zoomSelectedSegment(index: 4)
                                }
                            }
                        }
                    }
                }
                self.loadlineView()
            }
            else{
                DispatchQueue.main.async() {
                    self.lineChartErrorView(error: error!)
                }
            }
        })
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewCryptocurrencyInfo()
    }
    
    //Unlock
    @objc func applicationDidBecomeActiveNotification(notification : NSNotification) {
        loadTicker()
    }
    
    func zoomSelectedSegment(index: Int){
        var index = index
        
        if self.zoomSegmentedControl.selectedSegmentIndex >= index && self.zoomSegmentedControl.selectedSegmentIndex <= 4 {
            self.zoomSegmentedControl.selectedSegmentIndex = index
        }
        
        index = index + 1
        for i in index..<5{
            self.zoomSegmentedControl.setEnabled(false, forSegmentAt: i)
        }
    }
    
    func loadTicker() {
        startRefreshActivityIndicator()
        
        let keyStore = NSUbiquitousKeyValueStore ()
        if  let idArray = keyStore.array(forKey: "id") as? [String] {
            AlamofireRequest().getTickerID(idArray: idArray, completion: { (ticker : [Ticker]?, error : Error?) in
                if error == nil {
                    if let ticker = ticker {
                        
                        getTickerID = ticker
                        SettingsUserDefaults().setUserDefaults(ticher: getTickerID!, idArray: idArray, lastUpdate: Date())
                        DispatchQueue.main.async() {
                            self.viewCryptocurrencyInfo()
                        }
                    }
                }
                else{
                    self.showErrorSubview(error: error!, frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                }
            })
        }
    }
    
    func viewCryptocurrencyInfo() {
        refreshBarButtonItem()
        
        if getTickerID != nil {
            if let tick = getTickerID!.first(where: {$0.id == openID}) {
                ticker = tick
            }
            if let ticker = ticker {
                
                let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/64x64/\(ticker.id).png")!
                imageView.af_setImage(withURL: url)
                
                navigationItem.title = ticker.symbol
                nameLabel.text = ticker.name
                let price_usd = Double(ticker.price_usd)
                dataCurrencyLabel.text = formatterCurrencyUSD.string(from: NSNumber(value:price_usd!))
                
                // 1h
                oneHourChangeLabel.text = ticker.percent_change_1h != nil ? ticker.percent_change_1h! + "%" : "null"
                backgroundColorView(view: oneHourChangeView, percentChange: ticker.percent_change_1h)
                // 24h
                dayChangeLabel.text = ticker.percent_change_24h != nil ? ticker.percent_change_24h! + "%" : "null"
                backgroundColorView(view: dayChangeView, percentChange: ticker.percent_change_24h)
                // 7d
                weekChangeLabel.text = ticker.percent_change_7d != nil ? ticker.percent_change_7d! + "%" : "null"
                backgroundColorView(view: weekChangeView, percentChange: ticker.percent_change_7d)
                
                dataSecondaryLabel.text = "₿" + String(ticker.price_btc)
                rankLabel.text = String(ticker.rank)
                
                marketcapLabel.text = ticker.market_cap_usd != nil ? formatterCurrencyUSD.string(from: NSNumber(value: Double(ticker.market_cap_usd!)!)) : "null"
                volumeLabel.text = ticker.volume_usd_24h != nil ? formatterCurrencyUSD.string(from: NSNumber(value: Double(ticker.volume_usd_24h!)!)) : "null"
            }
        }
        
        if let subviews = self.view.superview?.subviews {
            for view in subviews{
                if (view is LoadSubview || view is ErrorSubview) {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    func backgroundColorView(view: UIView, percentChange: String?) {
        if let percentChange = percentChange{
            if Float(percentChange)! >= 0 {
                view.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            }
            else{
                view.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
            }
        }
        else{
            view.backgroundColor = .orange
        }
    }
    
    
    func loadlineView() {
        
        lineChartView.isHidden = true
        lineChartActivityIndicator.isHidden = false
        
        var of: NSDate?
        
        let xAxis = self.lineChartView.xAxis
        xAxis.labelPosition = .bottom
        
        // xAxis.labelCount = 3
        xAxis.drawLabelsEnabled = true
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        switch zoomSegmentedControl.selectedSegmentIndex {
        case 0:
            of = userCalendar.date(byAdding: .day, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            lineChartView.viewPortHandler.setMaximumScaleX(4.0)
        case 1:
            of = userCalendar.date(byAdding: .weekOfYear, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 7
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView.viewPortHandler.setMaximumScaleX(1.5)
        case 2:
            of = userCalendar.date(byAdding: .month, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView.viewPortHandler.setMaximumScaleX(1.5)
        case 3:
            of = userCalendar.date(byAdding: .month, value: -3, to: Date())! as NSDate
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
            lineChartView.viewPortHandler.setMaximumScaleX(1.5)
        case 4:
            of = userCalendar.date(byAdding: .year, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            lineChartView.viewPortHandler.setMaximumScaleX(1.75)
        case 5:
            of = Calendar.current.date(from: userCalendar.dateComponents([.year], from: Date()))! as NSDate
            xAxis.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            lineChartView.viewPortHandler.setMaximumScaleX(1.0)
        case 6:
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("MM.yy")
            lineChartView.viewPortHandler.setMaximumScaleX(3.0)
        default:
            break
        }
        
        // Set the x values date formatter
        xAxis.valueFormatter = ChartXAxisFormatter(dateFormatter: dateFormatter)
        
        AlamofireRequest().getCurrencyCharts(id: openID, of: of, completion: { (currencyCharts: CurrencyCharts?, error: Error?) in
            if error == nil {
                if let currencyCharts = currencyCharts {
                    self.currencyCharts = currencyCharts
                    DispatchQueue.main.async() {
                        self.lineChartView.zoom(scaleX: 0.0, scaleY: 0.0, x: 0.0, y: 0.0)
                        self.lineView()
                    }
                }
            }
            else{
                DispatchQueue.main.async() {
                    self.lineChartErrorView(error: error!)
                }
            }
        })
    }
    
    func lineView() {
        lineChartView.isHidden = false
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
                
                lineChartView.animate(yAxisDuration: 2.0)
            }
            else{
                lineChartView.animate(xAxisDuration: 2.0)
            }
            
            //3 - create an array to store our LineChartDataSets
            var dataSets : [LineChartDataSet] = [LineChartDataSet]()
            dataSets.append(set1)
            
            //4 - pass our months in for our x-axis label value along with our dataSets
            let data: LineChartData = LineChartData(dataSets: dataSets)
            //  data.setValueTextColor(UIColor.white)
            
            //5 - finally set our data
            self.lineChartView.data = data
        }
    }
    
    func refreshBarButtonItem(){
        let refreshBarButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        self.navigationItem.rightBarButtonItem = refreshBarButton
    }
    
    @objc func refresh() {
        loadTicker()
        loadlineView()
    }
    
    func startRefreshActivityIndicator() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.color = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        let refreshBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = refreshBarButton
        activityIndicator.startAnimating()
    }
    
    @IBAction func selectIindexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(selectSegmentedControl.selectedSegmentIndex, forKey: "typeChart")
        keyStore.synchronize()
        lineView()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let keyStore = NSUbiquitousKeyValueStore ()
        keyStore.set(zoomSegmentedControl.selectedSegmentIndex, forKey: "zoomChart")
        keyStore.synchronize()
        loadlineView()
    }
    
    @objc func reload(_ sender:UIButton) {
        refresh()
    }
    
    //MARK: ErrorSubview
    func showErrorSubview(error: Error, frame: CGRect) {
        
        refreshBarButtonItem()
        
        self.errorSubview = ErrorSubview(frame: frame)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.errorSubview?.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.errorSubview?.insertSubview(blurEffectView, at: 0) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.errorSubview?.backgroundColor = UIColor.white
        }
        
        self.errorSubview?.errorStringLabel.text = error.localizedDescription
        self.errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.superview?.addSubview(self.errorSubview!)
    }
    
    func lineChartErrorView(error: Error) {
        self.LineChartErrorView.isHidden = false
        refreshBarButtonItem()
        
        LineChartErrorLabel.text = error.localizedDescription
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
