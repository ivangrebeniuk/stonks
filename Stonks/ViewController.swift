//
//  ViewController.swift
//  Stonks
//
//  Created by Иван Гребенюк on 14.04.2022.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    // UI
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyNameLabel.text = "Tinkoff"
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        requestDataUpdate()
    }
    
    // Private
    
    private lazy var companies: [String: String] = [
        "Apple": "AAPL",
        "Google": "GOOG",
        "Microsoft": "MSFT",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    private func requestData(for symbol: String) {
        let token = "pk_c1111bc1f154490faa1efedcb4139b95"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data,
               (response as? HTTPURLResponse)?.statusCode == 200,
               error == nil {
                self?.parseQuote(from: data)
            } else {
                print("Network error!")
            }
        }
        
        dataTask.resume()
    }
    
    private func parseQuote(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String: Any],
                  let companyName = json["companyName"] as? String,
                  let companySymbol = json["symbol"] as? String,
                  let price = json["latestPrice"] as? Double,
                  let priceChange = json["change"] as? Double else { return print("Invalid JSON") }
            
            DispatchQueue.main.async { [weak self] in
                self?.displayStockInfo(companyName: companyName,
                                       companySymbol: companySymbol,
                                       price: price,
                                       priceChange: priceChange)
            }
        } catch {
            print("JSON parsing error: ", error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String,
                                  companySymbol: String,
                                  price: Double,
                                  priceChange: Double) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        symbolLabel.text = companySymbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        
        if priceChange == 0 {
            priceChangeLabel.textColor = .black
        }
        if priceChange > 0 {
            priceChangeLabel.textColor = .green
        }
        if priceChange < 0 {
            priceChangeLabel.textColor = .red
        }
    }
    
    private func requestDataUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        symbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        priceChangeLabel.textColor = .black
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestData(for: selectedSymbol)
    }
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestDataUpdate()
    }
}

