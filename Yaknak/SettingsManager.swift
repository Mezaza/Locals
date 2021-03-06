//
//  SettingsManager.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import FirebaseDatabase


class SettingsManager {
    
    static let shared = SettingsManager()
    let dataService: DataService!
    // get default storage
    private var defaultStorage = UserDefaults.standard
  
  
  private init() {
    dataService = DataService()
  }

  
    
    // Define derived property for all Key/Value settings.
    
    // refresh time (in seconds)
    var refreshTime: Int {
        get{
            if defaultStorage.object(forKey: "refreshTime") != nil {
                let returnValue = defaultStorage.object(forKey: "refreshTime") as! Int
                return returnValue
            }else{
                return 10   // default value
            }
        }set{
            defaultStorage.set(newValue, forKey: "refreshTime")
        }
    }
    
    // default volume
    var defaultVolume: Float {
        get{
            if defaultStorage.object(forKey: "defaultVolume") != nil {
                let returnValue = defaultStorage.object(forKey: "defaultVolume") as! Float
                return returnValue
            }else{
                return 0.5      // default value
            }
        }set{
            defaultStorage.set(newValue, forKey: "defaultVolume")
        }
    }
    
    
    
    // default walking duration (0: 5 mins, 1: 10 mins, 2: 15 mins, 3: 30 mins, 4: 45 mins, 5: 60 mins)
    var defaultWalkingDuration: Int {
        get {
            if defaultStorage.object(forKey: "defaultWalkingDuration") != nil {
                let storedValue = defaultStorage.object(forKey: "defaultWalkingDuration") as! Int
                return storedValue
            }
            else {
                return 15    // default value, 15 mins
            }
        }
        set {
            defaultStorage.set(newValue, forKey: "defaultWalkingDuration")
        }
    }
    

    

    
    /** Default tip display setting for friends */
    var defaultShowTips: Bool {
    
        get {
            if defaultStorage.object(forKey: "defaultShowTips") != nil {
            let storedValue = defaultStorage.object(forKey: "defaultShowTips") as! Bool
                return storedValue
            }
            else {
            return true    // default true
            }

        }
        
        set {
            self.dataService.setDefaultShowTips(newValue) { (success) in
                
                if success {
                print("Privacy setting saved...")
                self.defaultStorage.set(newValue, forKey: "defaultShowTips")
                }
                else {
                    print("Privacy setting could not be saved...")
                }
            }
        }
    
    
    }
  
    
    /*
     // Push notifications in future
     // enable Notifications (true/false)
     var enableNotifications: Bool {
     get{
     if defaultStorage.objectForKey("enableNotifications") != nil {
     let returnValue = defaultStorage.objectForKey("enableNotifications") as! Bool
     return returnValue
     }else{
     return false    // default value
     }
     }set{
     defaultStorage.setBool(newValue, forKey: "enableNotifications")
     }
     }
     
     
     */
    // you can add more derived property here, based on settings required for the application
    
}
