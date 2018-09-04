import Foundation
import Alamofire

public struct CryptoCurrencyKit {
    
    public static func fetchTickers(idArray: [String]? = nil, limit: Int? = 0, response: ((_ r: Response<Ticker>) -> Void)?) {
        DispatchQueue .global (qos: .utility) .async {
            var urlString = "https://api.coinmarketcap.com/v1/ticker/"
            let convert = SettingsUserDefaults.getCurrentCurrency()
            
            urlString.append("?convert=\(convert.rawValue)")
            urlString.append("&limit=\(limit ?? 0)")
            
            let url = URL(string: urlString)!
            let urlRequest = URLRequest(url: url)
            
            let closure: ((Response<Ticker>) -> Void)? = { r in
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
                    DispatchQueue.main.async {
                        response?(Response.success(tickerFilterArray))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        response?(Response.failure(error: error))
                    }
                }
            }
            requestA(urlRequest: urlRequest, idArray: idArray, response: closure)
        }
    }
}
    public enum Money: String {
        case usd = "USD"
        case eur = "EUR"
        case btc = "BTC"
        case gbp = "GBP"
        case jpy = "JPY"
        case cny = "CNY"
        case hkd = "HKD"
        case rub = "RUB"
        
        public var flag: String {
            switch self {
            case .usd:
                return "🇺🇸"
            case .eur:
                return "🇪🇺"
            case .btc:
                return "🌍"
            case .gbp:
                return "🇬🇧"
            case .jpy:
                return "🇯🇵"
            case .cny:
                return "🇨🇳"
            case .hkd:
                return "🇭🇰"
            case .rub:
                return "🇷🇺"
            }
        }
        
        public static var allValues: [Money] {
            return [.usd,
                    .eur,
                    .btc,
                    .gbp,
                    .jpy,
                    .cny,
                    .hkd,
                    .rub]
        }
        
        public static var allRawValues: [String] {
            return allValues.map { $0.rawValue }
        }
    }

extension CryptoCurrencyKit {
    public enum Response<T: Codable> {
        case failure(error: Error)
        case success([T])
    }
    
    static func requestA<T>(urlRequest: URLRequest, idArray: [String]?, response: ((_ r: Response<T>) -> Void)?) {

        Alamofire.SessionManager.default.request(urlRequest).validate().responseData { res in
            switch res.result {
            case .success(let responseData):
                let decoder = JSONDecoder()
                do {
                    let objects = try decoder.decode([T].self, from: responseData)
                    response?(Response.success(objects))
                } catch let decodeE {
                    response?(Response.failure(error: decodeE))
                }
            case .failure(let error):
                response?(Response.failure(error: error))
            }
        }
    }
}
