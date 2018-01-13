import Foundation
import Alamofire

public struct CryptoCurrencyKit {
    
    public static func fetchTickers(convert: Money = .usd, idArray: [String]?, limit: Int? = nil, response: ((_ r: ResponseA<Ticker>) -> Void)?) {
        var urlString = "https://api.coinmarketcap.com/v1/ticker/"
        urlString.append("?convert=\(convert.rawValue)")
        if let limit = limit {
            urlString.append("&limit=\(limit)")
        }
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        //   urlRequest.timeoutInterval = 5
        // urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        
        let closure: ((ResponseA<Ticker>) -> Void)? = { r in
            switch r {
            case .success(let data):
                var tickerFilterArray = [Ticker]()
                if let idArray = idArray {
                    for id in idArray{
                        if let json = data.filter({ $0.id == id}).first{
                            tickerFilterArray.append(json)
                        }
                    }
                }
                else{
                    tickerFilterArray = data
                }
                response?(ResponseA.success(tickerFilterArray))
            case .failure(let error):
                print(error.localizedDescription)
                response?(ResponseA.failure(error: error))
            }
        }
        requestA(urlRequest: urlRequest, idArray: idArray, response: closure)
    }
    
    public static func fetchTicker(coinName: String, convert: Money = .usd, response: ((_ r: ResponseD<Ticker>) -> Void)?) {
        var urlString = "https://api.coinmarketcap.com/v1/ticker/"
        urlString.append(coinName)
        urlString.append("/?convert=\(convert.rawValue)")
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        let closure: ((ResponseA<Ticker>) -> Void)? = { r in
            switch r {
            case .success(let data):
                response?(ResponseD.success(data[0]))
            case .failure(let error):
                response?(ResponseD.failure(error: error))
            }
        }
        requestA(urlRequest: urlRequest, idArray: nil, response: closure)
    }
    
    public static func fetchGlobal(convert: Money = .usd, response: ((_ r: ResponseD<Global>) -> Void)?) {
        let urlRequest = URLRequest(url: URL(string: "https://api.coinmarketcap.com/v1/global/")!)
        requestD(urlRequest: urlRequest, response: response)
    }
}

extension CryptoCurrencyKit {
    public enum Money: String {
        case usd = "USD"
        case eur = "EUR"
        case btc = "BTC"
        // case aud = "AUD" //
        // case brl = "BRL"
        
        case gbp = "GBP"
        case jpy = "JPY"
        case cny = "CNY"
        case hkd = "HKD"
        /*
         case cad = "CAD"
         case chf = "CHF"
         case clp = "CLP"
         case cny = "CNY"
         case czk = "CZK"
         case dkk = "DKK"
         case gbp = "GBP"
         case hkd = "HKD"
         case huf = "HUF"
         case idr = "IDR"
         case ils = "ILS"
         case inr = "INR"
         case jpy = "JPY"
         case krw = "KRW"
         case mxn = "MXN"
         case myr = "MYR"
         case nok = "NOK"
         case nsd = "NZD"
         case php = "PHP"
         case pkr = "PKR"
         case pln = "PLN"
         case rub = "RUB"
         case sek = "SEK"
         case sgd = "SGD"
         case thb = "THB"
         case tryl = "TRY"
         case twd = "TWD"
         case zar = "ZAR"
         */
        
    
        public var flag: String {
            switch self {
            case .usd:
                return "🇺🇸" //💵
            case .eur:
                return "🇪🇺" //💶
            case .btc:
                return "₿"
            case .gbp:
                return "🇬🇧"
            case .jpy:
                return "🇯🇵"
            case .cny:
                return "🇨🇳"
            case .hkd:
                return "🇭🇰"
            }
        }
    
        
        /*
         public var symbol: String {
         switch self {
         case .aud:
         return "$"
         case .brl:
         return ""
         case .cny:
         return "¥"
         case .eur:
         return "€"
         case .gbp:
         return "£"
         case .jpy:
         return "¥"
         case .usd:
         return "$"
         case .hkd:
         return "$"
         }
         }
         */
        
        public static var allValues: [Money] {
            return [.usd,
                    .eur,
                    .btc,
                    .gbp,
                    .jpy,
                    .cny,
                    .hkd
                
                
                /* .aud,
                 .brl,
                 .cad,
                 .chf,
                 .clp,
                 .cny,
                 .czk,
                 .dkk,
                 .gbp,
                 .hkd,
                 .huf,
                 .idr,
                 .ils,
                 .inr,
                 .jpy,
                 .krw,
                 .mxn,
                 .myr,
                 .nok,
                 .php,
                 .pkr,
                 .pln,
                 .rub,
                 .sek,
                 .sgd,
                 .thb,
                 .tryl,
                 .twd,
                 .zar*/]
        }
        
        public static var allRawValues: [String] {
            return allValues.map { $0.rawValue }
        }
    }
}

extension CryptoCurrencyKit {
    public enum ResponseD<T: Codable> {
        case failure(error: Error)
        case success(T)
    }
    
    public enum ResponseA<T: Codable> {
        case failure(error: Error)
        case success([T])
    }
    
    static func requestA<T>(urlRequest: URLRequest, idArray: [String]?, response: ((_ r: ResponseA<T>) -> Void)?) {
        print("requestA")
        //    let configuration = URLSessionConfiguration.default
        //  let session = URLSession(configuration: configuration)
        
        //   let destination = DownloadRequest.suggestedDownloadDestination()
        /*   Alamofire.download(urlRequest).responseData { res in
         switch res.result{
         case.success(let responseData):
         let decoder = JSONDecoder()
         do {
         let objects = try decoder.decode([T].self, from: responseData)
         response?(ResponseA.success(objects))
         } catch let decodeE {
         response?(ResponseA.failure(error: decodeE))
         }
         case .failure(let error):
         response?(ResponseA.failure(error: error))
         }
         }
         */
        /*
         let destination: DownloadRequest.DownloadFileDestination = { _, _ in
         var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
         documentsURL.appendPathComponent("duck.png")
         return (documentsURL, [.removePreviousFile])
         }
         */
        /*
        if FileManager.default.fileExists(atPath: res.destinationURL!.path) {
            FileManager.default.removeItem(atPath: res.destinationURL!.path)
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(urlRequest, to: destination).validate().responseData { res in
            //          guard let data = res.result.value else { return }
            DispatchQueue.main.async {
                switch res.result{
                case.success(let responseData):
                    let decoder = JSONDecoder()
                    do {
                        let data = try Data(contentsOf: res.destinationURL!)
                        let objects = try decoder.decode([T].self, from: data)
                        
                        if FileManager.default.fileExists(atPath: res.destinationURL!.path) {
                            try FileManager.default.removeItem(atPath: res.destinationURL!.path)
                        }
                        
                        response?(ResponseA.success(objects))
                    } catch let decodeE {
                        response?(ResponseA.failure(error: decodeE))
                    }
                case .failure(let error):
                    response?(ResponseA.failure(error: error))
                }
            }
        }
    }
        */
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach
                {
                    if ($0.originalRequest?.url?.absoluteString.range(of: "https://api.coinmarketcap.com/v1/ticker/") != nil)
                    {
                        $0.cancel()
                    }
            }
        }
       

        
        Alamofire.SessionManager.default.request(urlRequest).validate().responseData { res in
            switch res.result {
            case .success(let responseData):
                print("Validation Successful getTicker2")
                
                let decoder = JSONDecoder()
                do {
                    let objects = try decoder.decode([T].self, from: responseData)
                    response?(ResponseA.success(objects))
                } catch let decodeE {
                    response?(ResponseA.failure(error: decodeE))
                }
            case .failure(let error):
                response?(ResponseA.failure(error: error))
            }
        }
    }
    
        
        /*
         session.dataTask(with: urlRequest) { (data, res, error) in
         print(res)
         print(error?.localizedDescription)
         guard let httpResponse = res as? HTTPURLResponse,
         (200...299).contains(httpResponse.statusCode) else {
         print("res error")
         return
         }
         
         DispatchQueue.main.async {
         if let data = data {
         do {
         let objects = try JSONDecoder().decode([T].self, from: data)
         response?(ResponseA.success(objects))
         } catch let decodeE {
         response?(ResponseA.failure(error: decodeE))
         }
         } else if let error = error {
         print(error.localizedDescription)
         response?(ResponseA.failure(error: error))
         }
         }
         }.resume()*/
        // }
        
        static func requestD<T>(urlRequest: URLRequest, response: ((_ r: ResponseD<T>) -> Void)?) {
            URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        do {
                            let object = try JSONDecoder().decode(T.self, from: data)
                            response?(ResponseD.success(object))
                        } catch let decodeE {
                            response?(ResponseD.failure(error: decodeE))
                        }
                    } else if let error = error {
                        response?(ResponseD.failure(error: error))
                    }
                }
                }.resume()
        }
    
}
