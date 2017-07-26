//
//  CryptocurrencyInfoViewController.swift
//  Coin
//
//  Created by Mialin Valentin on 13.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import Charts

class CryptocurrencyInfoViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var zoomSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataCurrencyLabel: UILabel!
    @IBOutlet weak var dataCurrencyChangeLabel: UILabel!
    @IBOutlet weak var dataSecondaryLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    var ticker : Ticker?
    

    
    var currencyCharts: CurrencyCharts?
    
    let userCalendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ticker?.name
        
        lineChartView.delegate = self
        lineChartView.chartDescription?.text = "Tap node for details"
        lineChartView.chartDescription?.textColor = UIColor.white
        lineChartView.gridBackgroundColor = UIColor.darkGray
        lineChartView.noDataText = "No data provided"
        
        lineChartView.leftAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.scaleYEnabled = false
        
        let font = UIFont.systemFont(ofSize: 10)
        selectSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        
        
        if let ticker = ticker {
            
            let url = URL(string: "https://files.coinmarketcap.com/static/img/coins/64x64/\(ticker.id).png")!
            imageView.af_setImage(withURL: url)
            
            nameLabel.text = "\(ticker.name) (\(ticker.symbol))"
            dataCurrencyLabel.text = "\(ticker.price_usd) USD"
            dataCurrencyChangeLabel.text = "(\(ticker.percent_change_24h)%)"
            
            if ticker.percent_change_24h >= 0 {
                dataCurrencyChangeLabel.textColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            }
            else{
                dataCurrencyChangeLabel.textColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 25
            dataSecondaryLabel.text = formatter.string(from: ticker.price_btc as NSNumber)! + " BTC"
            rankLabel.text = String(ticker.rank)
            
            marketcapLabel.minimumScaleFactor = 0.5
            marketcapLabel.adjustsFontSizeToFitWidth = true
            marketcapLabel.text = formatCurrency(value: ticker.market_cap_usd)
            
            volumeLabel.minimumScaleFactor = 0.5
            volumeLabel.adjustsFontSizeToFitWidth = true
            volumeLabel.text = formatCurrency(value: ticker.volume_usd_24h)
        }
        
        let keyStore = NSUbiquitousKeyValueStore ()
        selectSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "typeChart"))
        zoomSegmentedControl.selectedSegmentIndex = Int(keyStore.longLong(forKey: "zoomChart"))
        
        
        load()
    }
    
    func load() {
        
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
        case 1:
            of = userCalendar.date(byAdding: .weekOfYear, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 7
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
        case 2:
            of = userCalendar.date(byAdding: .month, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
        case 3:
            of = userCalendar.date(byAdding: .month, value: -3, to: Date())! as NSDate
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("dd.MM")
        case 4:
            of = userCalendar.date(byAdding: .year, value: -1, to: Date())! as NSDate
            xAxis.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
        case 5:
            of = Calendar.current.date(from: userCalendar.dateComponents([.year], from: Date()))! as NSDate
            xAxis.labelCount = 6
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
        case 6:
            xAxis.labelCount = 5
            dateFormatter.setLocalizedDateFormatFromTemplate("MM.yy")
        default:
            break
        }
        
        // Set the x values date formatter
        xAxis.valueFormatter = ChartXAxisFormatter(dateFormatter: dateFormatter)
        
        AlamofireRequest().getCurrencyCharts(id: (ticker?.id)!, of: of) { (currencyCharts: CurrencyCharts?) in
            self.currencyCharts = currencyCharts
              self.lineChartView.zoom(scaleX: 0.0, scaleY: 0.0, x: 0.0, y: 0.0)
            self.lineView()
        }
    }
    
    func lineView() {

        
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
                yVals1.append(ChartDataEntry(x: Double(Int(i.timestamp / 1000)), y: i.item))
            }
            
            
            
            // Create a data set with our array
            let set1 = LineChartDataSet(values: yVals1, label: nil)
            set1.drawValuesEnabled = false // Убрать надписи
            set1.drawCirclesEnabled = false
            set1.setColor(UIColor.black) // color line
            
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
        load()
    }
    
    func formatCurrency(value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        let result = formatter.string(from: value as NSNumber)
        return result!
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    //  fileprivate var referenceTimeInterval: TimeInterval?
    
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        //   self.referenceTimeInterval = referenceTimeInterval
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
