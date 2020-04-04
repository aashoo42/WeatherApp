//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Absoluit on 21/03/2020.
//  Copyright © 2020 Absoluit. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    var interstitial: GADInterstitial!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        SVProgressHUD.setBackgroundColor(UIColor.init(red: 0.0/255.0, green: 157.0/255.0, blue: 215.0/255.0, alpha: 0.5))
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        setupInterstitialAd()
        
        if true{
            showLocationScreen()
        }else{
            showWeatherScreen()
        }
        
        return true
    }
    
    // MARK:- Ads
    func setupInterstitialAd(){
        interstitial = GADInterstitial(adUnitID: AdsIds.interstitialID)
        let request = GADRequest()
        interstitial.load(request)
    }
    
    func showInterstitialAd(controller: UIViewController){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: controller)
        }
    }
    
    // MARK:- Navigation
    func showLocationScreen(){
        let objlocationNC = self.storyboard.instantiateViewController(withIdentifier: "locationNC") as! UINavigationController
        self.window?.rootViewController = objlocationNC
        self.window?.makeKeyAndVisible()
    }
    
    func showWeatherScreen(){
        let objlocationNC = self.storyboard.instantiateViewController(withIdentifier: "weatherNC") as! UINavigationController
        self.window?.rootViewController = objlocationNC
        self.window?.makeKeyAndVisible()
    }
    
    // MARK:- Alerts
    func showInternetAlert(){
        let alert = UIAlertController.init(title: "Internet?", message: "Please check your internet connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showErroAlert(alertMsg: String){
        let alert = UIAlertController.init(title: "Error", message: alertMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    
    // MARK:- Userdefaults
    func saveCityToDefault(cityDict: NSDictionary){
        let currentList = NSMutableArray()
        if UserDefaults.standard.value(forKey: "citiesList") != nil{
            let tempList = UserDefaults.standard.value(forKey: "citiesList") as! NSArray
            if !(tempList.contains(cityDict)){
                currentList.add(cityDict)
                currentList.addObjects(from: tempList as! [Any])
                UserDefaults.standard.set(currentList, forKey: "citiesList")
            }
        }else{
            currentList.add(cityDict)
            UserDefaults.standard.set(currentList, forKey: "citiesList")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func getCitiesListFromDefaults() -> NSArray{
        if UserDefaults.standard.value(forKey: "citiesList") != nil{
            return UserDefaults.standard.value(forKey: "citiesList") as! NSArray
        }
        return NSArray()
    }
    
    func deleteCityFromDefaults(cityDict: NSDictionary){
        if (UserDefaults.standard.value(forKey: "citiesList") != nil){
            let citiesList = UserDefaults.standard.value(forKey: "citiesList") as! NSArray
            let tempArray = NSMutableArray(array: citiesList)
            tempArray.remove(cityDict)
            UserDefaults.standard.set(tempArray, forKey: "citiesList")
            UserDefaults.standard.synchronize()
        }
    }
}

