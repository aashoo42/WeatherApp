//
//  LocationVC.swift
//  WeatherApp
//
//  Created by mac on 4/2/20.
//  Copyright © 2020 Absoluit. All rights reserved.
//

import UIKit
import GoogleMobileAds

class LocationVC: UIViewController {

    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tvTopContraint: NSLayoutConstraint!
    
    private var citiesArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        
        setupSearchBar()
        
        citiesArray = (UIApplication.shared.delegate as! AppDelegate).getCitiesListFromDefaults()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        self.searchBar.isHidden = !self.searchBar.isHidden
        setupSearchBar()
    }
    
    func setupSearchBar(){
        if self.searchBar.isHidden{
            tvTopContraint.constant = 10
            self.view.endEditing(true)
        }else{
            tvTopContraint.constant = 56
        }
    }
    
    private func getCityFromAPI(cityStr: String){
        let headers = [
            "x-rapidapi-host": "andruxnet-world-cities-v1.p.rapidapi.com",
            "x-rapidapi-key": "c4b7f6c03amshb614de998b9c9dap1a91e3jsncbcc3a6c56b3"
        ]
        
        let url = "https://andruxnet-world-cities-v1.p.rapidapi.com"
        let params = ["query": cityStr,
                      "searchby": "city"]
        AppUtils.sharedUtils.getRestAPIResponse(urlString: url, headers: headers as NSDictionary, parameters: params as NSDictionary, method: .get) { (data) in
            if (data["response"] != nil) && (data["response"] is NSArray){
                self.citiesArray = data["response"] as! NSArray
                
                self.citiesTableView.reloadData()
            }
        }
    }
}

// MARK:- UISearchBarDelegate
extension LocationVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked", searchBar.text!)
        
        getCityFromAPI(cityStr: searchBar.text!)
        self.view.endEditing(true)
    }
}

extension LocationVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.citiesTableView.dequeueReusableCell(withIdentifier: "CityCell") as! CityCell
        let tempDict = citiesArray[indexPath.row] as! NSDictionary
        
        let city = tempDict["city"] as! String
        let country = "\(tempDict["state"] as! String), \(tempDict["country"] as! String)"
        
        cell.cityLbl.text = city
        cell.countryLbl.text = country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDict = citiesArray[indexPath.row] as! NSDictionary
        print(selectedDict)
        
        let objWeatherVC = self.storyboard?.instantiateViewController(withIdentifier: "WeatherVC") as! WeatherVC
        objWeatherVC.cityData = selectedDict
        self.navigationController?.pushViewController(objWeatherVC, animated: true)
        
        (UIApplication.shared.delegate as! AppDelegate).showInterstitialAd(controller: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let selectedDict = citiesArray[indexPath.row] as! NSDictionary
            print("delete thie: ",selectedDict)
            
            (UIApplication.shared.delegate as! AppDelegate).deleteCityFromDefaults(cityDict: selectedDict)
            citiesArray = (UIApplication.shared.delegate as! AppDelegate).getCitiesListFromDefaults()
            self.citiesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerBannerView = GADBannerView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerBannerView.adUnitID = AdsIds.bannerID
        headerBannerView.rootViewController = self
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID as! String]
        headerBannerView.load(GADRequest())
        return headerBannerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
}
