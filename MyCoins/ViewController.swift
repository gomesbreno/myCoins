//
//  ViewController.swift
//  MyCoins
//
//  Created by Breno Gomes on 19/11/18.
//  Copyright © 2018 Gomes Industries. All rights reserved.
//

import UIKit
import SwiftChart
import Alamofire


class ViewController: UIViewController {
        
    @IBOutlet weak var chart: Chart!    
    
    @IBOutlet weak var usdView: UIView!
    
    @IBOutlet weak var usdtView: UIView!
    @IBOutlet weak var cadView: UIView!
    @IBOutlet weak var eurView: UIView!
    @IBOutlet weak var gpbView: UIView!
    @IBOutlet weak var arsView: UIView!
    
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var lbUsd: UILabel!
    @IBOutlet weak var lbUsdt: UILabel!
    @IBOutlet weak var lbCad: UILabel!
    @IBOutlet weak var lbEur: UILabel!
    @IBOutlet weak var lbGbp: UILabel!
    @IBOutlet weak var lbArs: UILabel!
    
    let url = "https://economia.awesomeapi.com.br/all"
    var coinList: CoinList!
    
    var hoursList: [Int]!
    var usdBidList: [String]!
    var usdtBidList: [String]!
    var cadBidList: [String]!
    var eurBidList: [String]!
    var gbpBidList: [String]!
    var arsBidList: [String]!
    var btcBidList: [String]!
    
    @objc func resign(_ tap: UITapGestureRecognizer){
        self.informationView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resign(_:)))
        self.informationView.addGestureRecognizer(tap)
        
        self.informationView.isHidden = true
        self.usdView.backgroundColor = ChartColors.purpleColor()
        self.usdtView.backgroundColor = ChartColors.blueColor()
        self.cadView.backgroundColor = ChartColors.cyanColor()
        self.eurView.backgroundColor = ChartColors.redColor()
        self.gpbView.backgroundColor = ChartColors.goldColor()
        self.arsView.backgroundColor = ChartColors.greenColor()
        
        self.chart.delegate = self
        getData()
    }
    
    func prepareChart(){
        var dataUsd:[(x: Int, y: Double)] = []
        var dataUsdt:[(x: Int, y: Double)] = []
        var dataCad:[(x: Int, y: Double)] = []
        var dataEur:[(x: Int, y: Double)] = []
        var dataGbp:[(x: Int, y: Double)] = []
        var dataArs:[(x: Int, y: Double)] = []
        //var dataBtc:[(x: Int, y: Double)] = []
        
        
        for (index, element) in self.hoursList.enumerated() {
            dataUsd.append((x: element, y: Double(self.usdBidList[index].floatValue)))
            dataUsdt.append((x: element, y: Double(self.usdtBidList[index].floatValue)))
            dataCad.append((x: element, y: Double(self.cadBidList[index].floatValue)))
            dataEur.append((x: element, y: Double(self.eurBidList[index].floatValue)))
            dataGbp.append((x: element, y: Double(self.gbpBidList[index].floatValue)))
            dataArs.append((x: element, y: Double(self.arsBidList[index].floatValue)))
            //dataBtc.append((x: element, y: Double(self.btcBidList[index].floatValue)))
        }
 
       
        
        let seriesUsd = ChartSeries(data: dataUsd)
        seriesUsd.color = ChartColors.purpleColor()
        seriesUsd.area = true
        
        
        let seriesUsdt = ChartSeries(data: dataUsdt)
        seriesUsdt.color = ChartColors.blueColor()
        seriesUsdt.area = true
        
        let seriesCad = ChartSeries(data: dataCad)
        seriesCad.color = ChartColors.cyanColor()
        seriesCad.area = true
        
        let seriesEur = ChartSeries(data: dataEur)
        seriesEur.color = ChartColors.redColor()
        seriesEur.area = true
        
        let seriesGbp = ChartSeries(data: dataGbp)
        seriesGbp.color = ChartColors.goldColor()
        seriesGbp.area = true
        //dataArs[0] = (x: 0, y: 4.0)
        
        let seriesArs = ChartSeries(data: dataArs)
        seriesArs.color = ChartColors.greenColor()
        seriesArs.area = true
        
        // Use `xLabels` to add more labels, even if empty
        self.chart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
        
        // Format the labels with a unit
        self.chart.xLabelsFormatter = { String(Int(round($1))) + "h" }
        
        self.chart.minY = 0
        self.chart.maxY = 5
        
        
        self.chart.add([seriesUsd,seriesUsdt,seriesCad,seriesEur,seriesGbp,seriesArs])
    }
    
    func getData(){
        Alamofire.request(url).responseJSON { (response) in
            
            guard let data = response.data else {
                return
            }
            do{
                self.coinList = try JSONDecoder().decode(CoinList.self, from: data)
                let userDefaults = UserDefaults.standard
                
                let date = Date() // save date, so all components use the same date
                let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)
                let hour = calendar.component(.hour, from: date)
                var lastHour:Int!
                
                //obtendo e salvando os horários
                var hoursList: [Int] = []
                hoursList = userDefaults.array(forKey: "hoursList")  as? [Int] ?? [Int]()
                if hoursList.isEmpty{
                    hoursList.append(hour)
                }else{
                    if hour == 0{
                        hoursList = []
                        hoursList.append(hour)
                        lastHour = 0
                    }else{
                        lastHour = hoursList.last
                        if hour != lastHour{
                            hoursList.append(hour)
                        }
                    }
                }
                userDefaults.set(hoursList, forKey: "hoursList")
                print(hoursList)
                self.hoursList = hoursList
                print(self.hoursList)
                
                
                //obtendo e salvando o valor de usd
                var usdBidList: [String] = []
                usdBidList = userDefaults.stringArray(forKey: "usdBidList") ?? [String]()
                if hour == 0{
                    usdBidList = []
                }
                if hour == lastHour{
                    let _ = usdBidList.popLast()
                    usdBidList.append(self.coinList.USD.bid)
                }else{
                    usdBidList.append(self.coinList.USD.bid)
                }
                userDefaults.set(usdBidList, forKey: "usdBidList")
                self.usdBidList = usdBidList
                print(self.usdBidList)
                
                //obtendo e salvando o valor de USDT
                var usdtBidList: [String] = []
                usdtBidList = userDefaults.stringArray(forKey: "usdtBidList") ?? [String]()
                if hour == 0{
                    usdtBidList = []
                }
                if hour == lastHour{
                    let _ = usdtBidList.popLast()
                    usdtBidList.append(self.coinList.USDT.bid)
                }else{
                    usdtBidList.append(self.coinList.USDT.bid)
                }
                userDefaults.set(usdtBidList, forKey: "usdtBidList")
                print(usdtBidList)
                self.usdtBidList = usdtBidList
                
                //obtendo e salvando o valor de CAD
                var cadBidList: [String] = []
                cadBidList = userDefaults.stringArray(forKey: "cadBidList") ?? [String]()
                if hour == 0{
                    cadBidList = []
                }
                if hour == lastHour{
                    let _ = cadBidList.popLast()
                    cadBidList.append(self.coinList.CAD.bid)
                }else{
                    cadBidList.append(self.coinList.CAD.bid)
                }
                userDefaults.set(cadBidList, forKey: "cadBidList")
                print(cadBidList)
                self.cadBidList = cadBidList
                
                //obtendo e salvando o valor de eur
                var eurBidList: [String] = []
                eurBidList = userDefaults.stringArray(forKey: "eurBidList") ?? [String]()
                if hour == 0{
                    eurBidList = []
                }
                if hour == lastHour{
                    let _ = eurBidList.popLast()
                    eurBidList.append(self.coinList.EUR.bid)
                }else{
                    eurBidList.append(self.coinList.EUR.bid)
                }
                userDefaults.set(eurBidList, forKey: "eurBidList")
                print(eurBidList)
                self.eurBidList = eurBidList
                
                //obtendo e salvando o valor de gbp
                var gbpBidList: [String] = []
                gbpBidList = userDefaults.stringArray(forKey: "gbpBidList") ?? [String]()
                if hour == 0{
                    gbpBidList = []
                }
                if hour == lastHour{
                    let _ = gbpBidList.popLast()
                    gbpBidList.append(self.coinList.GBP.bid)
                }else{
                    gbpBidList.append(self.coinList.GBP.bid)
                }
                userDefaults.set(gbpBidList, forKey: "gbpBidList")
                print(gbpBidList)
                self.gbpBidList = gbpBidList
                
                //obtendo e salvando o valor de ars
                var arsBidList: [String] = []
                arsBidList = userDefaults.stringArray(forKey: "arsBidList") ?? [String]()
                if hour == 0{
                    arsBidList = []
                }
                if hour == lastHour{
                    let _ = arsBidList.popLast()
                    arsBidList.append(self.coinList.ARS.bid)
                }else{
                    arsBidList.append(self.coinList.ARS.bid)
                }
                userDefaults.set(arsBidList, forKey: "arsBidList")
                print(arsBidList)
                self.arsBidList = arsBidList
                
                //obtendo e salvando o valor de BTC
                var btcBidList: [String] = []
                btcBidList = userDefaults.stringArray(forKey: "btcBidList") ?? [String]()
                if hour == 0{
                    btcBidList = []
                }
                if hour == lastHour{
                    let _ = btcBidList.popLast()
                    btcBidList.append(self.coinList.BTC.bid)
                }else{
                    btcBidList.append(self.coinList.BTC.bid)
                }
                userDefaults.set(btcBidList, forKey: "btcBidList")
                print(btcBidList)
                self.btcBidList = btcBidList
                
                self.prepareChart()
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: ChartDelegate {
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        self.informationView.isHidden = false
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
                switch seriesIndex{
                    case 0:
                        self.lbUsd.text = "Dólar Comercial: R$ \(value) "
                    case 1:
                        self.lbUsdt.text = "Dólar Turismo: R$ \(value) "
                    case 2:
                        self.lbCad.text = "Dólar  Canadense: R$ \(value) "
                    case 3:
                        self.lbEur.text = "Euro: R$ \(value) "
                    case 4:
                        self.lbGbp.text = "Libra Esterlina: R$ \(value) "
                    case 5:
                        self.lbArs.text = "Peso Argentino: R$ \(value) "
                    default:
                        print("isso não deveria acontecer")
                    
                }
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        //noting
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //noting
    }
    
    
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}
