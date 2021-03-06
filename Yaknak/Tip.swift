//
//  Tip.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import GeoFire


struct Tip {
    
    var key: String?
    var category: String!
    var description: String!
    var likes: Int!
    var userName: String!
    var addedByUser: String!
    var userPicUrl: String!
    var tipImageUrl: String!
    var isActive: Bool!
    var reportType: String?
    var reportMessage: String?
    var placeId: String?
    var ref: DatabaseReference?
    
    
    init(_ category: String, _ description: String, _ likes: Int, _ userName: String,  _ addedByUser: String, _ userPicUrl: String, _ tipImageUrl: String, reportType: String = "", reportMessage: String = "", _ isActive: Bool, _ placeId: String) {
        
        self.category = category
        self.description = description
        self.likes = likes
        self.userName = userName
        self.addedByUser = addedByUser
        self.userPicUrl = userPicUrl
        self.tipImageUrl = tipImageUrl
        self.isActive = isActive
        self.placeId = placeId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        
        key = snapshot.key
        
        if let tipCategory = (snapshot.value! as! NSDictionary)["category"] as? String {
            category = tipCategory
        }
        else {
            category = ""
        }
        
        if let tipDescription = (snapshot.value! as! NSDictionary)["description"] as? String {
            description = tipDescription
        }
        else {
            description = "Description unavailable"
        }
        
        if let tipLikes = (snapshot.value! as! NSDictionary)["likes"] as? Int {
            likes = tipLikes
        }
        else {
            likes = 0
        }
        
         if let tipUserName = (snapshot.value! as! NSDictionary)["userName"] as? String {
         userName = tipUserName
         }
         else {
         userName = ""
         }
        
        if let byUser = (snapshot.value! as! NSDictionary)["addedByUser"] as? String {
            addedByUser = byUser
        }
        else {
            addedByUser = ""
        }
        
         if let userPic = (snapshot.value! as! NSDictionary)["userPicUrl"] as? String {
         userPicUrl = userPic
         }
         else {
         userPicUrl = ""
         }
        
        if let tipPic = (snapshot.value! as! NSDictionary)["tipImageUrl"] as? String {
            tipImageUrl = tipPic
        }
        else {
            tipImageUrl = ""
        }
        
        if let repType = (snapshot.value! as! NSDictionary)["reportType"] as? String {
            reportType = repType
        }
        else {
            reportType = ""
        }
        
        if let repMessage = (snapshot.value! as! NSDictionary)["reportMessage"] as? String {
            reportMessage = repMessage
        }
        else {
            reportMessage = ""
        }
        
        if let pId = (snapshot.value! as! NSDictionary)["placeId"] as? String {
            placeId = pId
        }
        else {
            placeId = ""
        }
        
        if let active = (snapshot.value! as! NSDictionary)["isActive"] as? Bool {
        isActive = active
        }
        else {
        isActive = true
        }
        
        ref = snapshot.ref
        
    }
    
      
    
    func toAnyObject() -> Any {
        return [
            "category": category,
            "description": description,
            "likes": likes,
            "userName": userName,
            "addedByUser": addedByUser,
            "userPicUrl": userPicUrl,
            "tipImageUrl": tipImageUrl,
            "isActive": isActive,
            "placeId": placeId
        ]
    }
    
    
    func toEdit() -> TipEdit {
    return TipEdit(key!, description, category, tipImageUrl, placeId!)
    }
    
    
}
