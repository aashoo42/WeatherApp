//
//  ViewController.swift
//  WeatherApp
//
//  Created by Absoluit on 21/03/2020.
//  Copyright © 2020 Absoluit. All rights reserved.
//

import UIKit

class WeatherVC: UIViewController {

    @IBOutlet weak var hoursCollectionView: UICollectionView!
    @IBOutlet weak var dailyTableView: UITableView!
    @IBOutlet weak var mainBG: UIImageView!
    
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    
    // StackView
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var feelsView: UIView!
    @IBOutlet weak var humidView: UIView!
    @IBOutlet weak var pressureView: UIView!
    @IBOutlet weak var visibilityView: UIView!
    
    @IBOutlet weak var windLbl: UILabel!
    @IBOutlet weak var feelsLbl: UILabel!
    @IBOutlet weak var humidLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var visibilityLbl: UILabel!
    
    
    
    var cityData = NSDictionary()
    
    private var hoursArray = NSArray()
    private var dailyArray = NSArray()
    
    private var showViews = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        let city = cityData["city"] as! String
        let country = cityData["country"] as! String
        
        let queryStr = city + ",\(country)"
        getCurrentWeatherData(queryStr: queryStr)
        getThreeHoursData(queryStr: queryStr)
        getSevenDaysData(queryStr: queryStr)
//
        setupAnimatedViews(isHidden: false)
        getTime()
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (_) in
            self.showViews = !self.showViews
            UIView.animate(withDuration: 1.0, animations: {
                self.setupAnimatedViews(isHidden: self.showViews)
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setupDesign(){
        
    }

    func setupAnimatedViews(isHidden: Bool){
        windView.isHidden = isHidden
        feelsView.isHidden = isHidden
        humidView.isHidden = isHidden
        pressureView.isHidden = !isHidden
        visibilityView.isHidden = !isHidden
    }
    
    func getCurrentWeatherData(queryStr: String){
        
        let headers = [
            "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
            "x-rapidapi-key": "c4b7f6c03amshb614de998b9c9dap1a91e3jsncbcc3a6c56b3"
        ]
        
        let url = "https://community-open-weather-map.p.rapidapi.com/weather?" // Current
        let params = ["callback": "",
                      "id": "",
                      "units": "metric",
                      "q":queryStr]
//        lat
//        lon
//        callback
//        id
//        lang
//        units "metric" or "imperial"
//        mode
        
        AppUtils.sharedUtils.getRestAPIResponse(urlString: url, headers: headers as NSDictionary, parameters: params as NSDictionary, method: .get) { (data) in
            if (data["cod"] as? Int) == 200{
                
                (UIApplication.shared.delegate as! AppDelegate).saveCityToDefault(cityDict: self.cityData)
                
                self.cityLbl.text = data["name"] as? String ?? ""
                self.weatherLbl.text = (((data["weather"] as! NSArray)[0] as! NSDictionary)["description"] as? String ?? "").uppercased()
                self.tempLbl.text = "\(Int((data["main"] as! NSDictionary)["temp"] as! Double))°"
                
                // wind speed
                let windSpeed = (data["wind"] as! NSDictionary)["speed"] as? Double ?? 0.0
                if windSpeed > 0.0 {
                    self.windLbl.text = "\(windSpeed) km/h"
                }else{
                    self.windLbl.text = "--"
                }
                
                // feels like
                let feelsLike = (data["main"] as! NSDictionary)["feels_like"] as? Double ?? 0.0
                if feelsLike > 0.0{
                    self.feelsLbl.text = "\(feelsLike)°"
                }else{
                    self.feelsLbl.text = "--"
                }
                
                // humidity
                let humidity = Int((data["main"] as! NSDictionary)["humidity"] as? Double ?? 0.0)
                if humidity > 0{
                    self.humidLbl.text = "\(humidity)"
                }else{
                    self.humidLbl.text = "--"
                }
                
                
                // pressure
                let pressure = Int((data["main"] as! NSDictionary)["pressure"] as? Double ?? 0.0)
                if pressure > 0{
                    self.pressureLbl.text = "\(pressure)"
                }else{
                    self.pressureLbl.text = "--"
                }
                
                
                // visibility
                let visibility = Int(data["visibility"] as? Double ?? 0)
                if visibility > 0{
                    self.visibilityLbl.text = "\(visibility/1000) km"
                }else{
                    self.visibilityLbl.text = "--"
                }
            }else{
                if (data["message"] != nil){
                    self.navigationController?.popViewController(animated: true)
                    (UIApplication.shared.delegate as! AppDelegate).showErroAlert(alertMsg: data["message"] as! String)
                }
            }
        }
    }
    
    func returnOnlyDay(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }
    
    func getSevenDaysData(queryStr: String){
        
        let headers = [
            "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
            "x-rapidapi-key": "c4b7f6c03amshb614de998b9c9dap1a91e3jsncbcc3a6c56b3"
        ]
        
        let url = "https://community-open-weather-map.p.rapidapi.com/forecast/daily?" // 7 days
        let params = ["callback": "",
                      "id": "",
                      "units": "metric",
                      "q":queryStr]
        
        AppUtils.sharedUtils.getRestAPIResponse(urlString: url, headers: headers as NSDictionary, parameters: params as NSDictionary, method: .get) { (data) in
            if (data["cod"] as? String) == "200"{
                self.dailyArray = data["list"] as? NSArray ?? []
                self.dailyTableView.reloadData()
            }
        }
    }
    
    
    func getThreeHoursData(queryStr: String){
        let headers = [
            "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
            "x-rapidapi-key": "c4b7f6c03amshb614de998b9c9dap1a91e3jsncbcc3a6c56b3"
        ]
        
        let url = "https://community-open-weather-map.p.rapidapi.com/forecast?" // 3 hours
        let params = ["callback": "",
                      "id": "",
                      "units": "metric",
                      "q":queryStr]
        
        AppUtils.sharedUtils.getRestAPIResponse(urlString: url, headers: headers as NSDictionary, parameters: params as NSDictionary, method: .get) { (data) in
            if (data["cod"] as? String) == "200"{

                let daysList = data["list"] as? NSArray ?? []
                self.hoursArray = daysList
                self.hoursCollectionView.reloadData()
            }
        }
    }
    
    func getOnlyHour(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hha"
        let hourStr = dateFormatter.string(from: date)
        return hourStr.lowercased()
    }
    
    func getDateForThreeHoursData(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    
    
    func getTime(){
//        self.mainBG.image = UIImage(named: "Evening")
    let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12 : self.mainBG.image = UIImage(named: "Morning")
        case 12 : self.mainBG.image = UIImage(named: "Morning")
        case 13..<17 : self.mainBG.image = UIImage(named: "Morning")
        case 17..<22 : self.mainBG.image = UIImage(named: "Night")
        default: self.mainBG.image = UIImage(named: "Night")
        }
    }
}

extension WeatherVC : UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hoursArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hoursCollectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourCell
        
        let itemDict = hoursArray[indexPath.row] as! NSDictionary
        
        let main = itemDict["main"] as! NSDictionary
        
        cell.tempLbl.text = "\(Int(main["temp"] as! Double))°"
        
        let timeStamp = itemDict["dt"] as! Int64
        let hour = Date.init(timeIntervalSince1970: TimeInterval(timeStamp))
        let hoursStr = "\(self.getOnlyHour(date: hour))"
        let dateStr = "\(self.getDateForThreeHoursData(date: hour))"
        
        cell.dateLbl.text = dateStr
        cell.hourLbl.text = hoursStr
        
        let clouds = ((itemDict["weather"] as! NSArray)[0] as! NSDictionary)["main"] as! String
        switch clouds {
        case "Clouds":
            cell.imgView.image = UIImage(named: "clouds")
            break
        case "Rain":
            cell.imgView.image = UIImage(named: "rain")
            break
        default:
            cell.imgView.image = UIImage(named: "sun")
            break
        }

        
        return cell
    }
}


extension WeatherVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dailyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dailyTableView.dequeueReusableCell(withIdentifier: "DailyCell") as! DailyCell
        
        let itemDict = self.dailyArray[indexPath.row] as! NSDictionary
        let timeStamp = itemDict["dt"] as! Int64
        let tempDate = Date.init(timeIntervalSince1970: TimeInterval(timeStamp))
        
        
        if indexPath.row == 0{
            cell.dayLbl.text = "Today"
        }else{
            cell.dayLbl.text = self.returnOnlyDay(date: tempDate)
        }
        
        
        cell.highTempLbl.text = "\(Int((itemDict["temp"] as! NSDictionary)["max"] as! Double))°"
        cell.lowTempLbl.text = "\(Int((itemDict["temp"] as! NSDictionary)["min"] as! Double))°"
        
        
        let rainIntensity = ((itemDict["weather"] as! NSArray)[0] as! NSDictionary)["main"] as? String ?? ""
        let cloudsIntensity = itemDict["clouds"] as? Int64 ?? 0
        
        switch rainIntensity {
        case "Rain":
            if cloudsIntensity > 50{
                cell.imgView.image = UIImage(named: "rain")
            }else{
                cell.imgView.image = UIImage(named: "sun_cloud")
            }
            break
        case "Clouds":
            cell.imgView.image = UIImage(named: "clouds")
            break
        default:
            cell.imgView.image = UIImage(named: "sun")
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}
