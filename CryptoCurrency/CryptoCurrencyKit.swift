import Foundation
import Alamofire

public struct CryptoCurrencyKit {
    
    public static func fetchTickers(idArray: [String]? = nil, limit: Int? = 0, response: ((_ r: ResponseA<Ticker>) -> Void)?) {
        DispatchQueue .global (qos: .utility) .async {
            var urlString = "https://api.coinmarketcap.com/v1/ticker/"
            let convert = SettingsUserDefaults.getCurrentCurrency()
            
            urlString.append("?convert=\(convert.rawValue)")
            urlString.append("&limit=\(limit ?? 0)")
            
            let url = URL(string: urlString)!
            let urlRequest = URLRequest(url: url)
            
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
                    DispatchQueue.main.async {
                        response?(ResponseA.success(tickerFilterArray))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        response?(ResponseA.failure(error: error))
                    }
                }
            }
            requestA(urlRequest: urlRequest, idArray: idArray, response: closure)
        }
    }
    
    public static func fetchTicker(coinName: String, response: ((_ r: ResponseD<Ticker>) -> Void)?) {
        var urlString = "https://api.coinmarketcap.com/v1/ticker/"
        urlString.append(coinName)
        let convert = SettingsUserDefaults.getCurrentCurrency()
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

        Alamofire.SessionManager.default.request(urlRequest).validate().responseData { dataResponse in
            switch dataResponse.result {
            case .success(let responseData):
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
