//
//  CoinManager.swift
//  ByteCoin
//

import Foundation

protocol CoinManagerDelegate{
    func didFetchData(rate: Double, currency: String)
    func didFailWithError(error: Error)
}

class CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "7163F264-59B5-4113-8D13-FF23EAA95000"
    //?apikey=
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var currentlySelectedCurrency: String = ""
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        currentlySelectedCurrency = currency
        let stringUrl = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: stringUrl)
    }
    
    func performRequest(with stringURL: String) {
        if let url = URL(string: stringURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: requestHandler)
            task.resume()
        }
    }
    
    func requestHandler(data: Data?, response: URLResponse?, error: Error?) -> Void{
        if error != nil{
            delegate?.didFailWithError(error: error!)
            return
        }
        if let safeData = data{
            if let decodedValue = parseJSON(data: safeData){
                delegate?.didFetchData(rate: decodedValue, currency: currentlySelectedCurrency)
            }
        }
        
    }
    
    func parseJSON(data: Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(coinData.self, from: data)
            return decodedData.rate
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
