//
//  SingleTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GeoFire
import GoogleMaps
import GooglePlaces
import CoreLocation
import Firebase


protocol TipEditDelegate: class {
    func editTip(_ tip: Tip)
}

class SingleTipViewController: UIViewController {
    
    
    var tip: Tip!
    let dataService = DataService()
    var style = NSMutableParagraphStyle()
    let geoTask = GeoTasks()
    var tipImage: UIImage!
    var img: UIImageView!
    var ai = UIActivityIndicatorView()
    var travelMode = TravelMode.Modes.walking
    var placesClient: GMSPlacesClient?
    weak var delegate: TipEditDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        if let navVC = self.navigationController {
        navVC.navigationBar.isHidden = true
        }
        self.style.lineSpacing = 2
        self.placesClient = GMSPlacesClient.shared()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    
    @IBAction func moreTapped(_ sender: Any) {
        self.popUpMenu()
    }
    
    
    
    private func initTipView() {
        
        if let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView {
            
            self.ai = UIActivityIndicatorView(frame: singleTipView.frame)
            singleTipView.addSubview(ai)
            self.ai.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.whiteLarge
            self.ai.color = UIColor.primaryTextColor()
            self.ai.center = CGPoint(UIScreen.main.bounds.width / 2, UIScreen.main.bounds.height / 2)
            self.ai.startAnimating()
            singleTipView.layoutIfNeeded()
            
            if let img = self.tipImage {
                
               self.toggleUI(singleTipView, false)
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if appDelegate.isReachable {
                        self.getLocationDetails(singleTipView, completionHandler: { (placeName, success, showDistance) in
                            
                            if success {
                                
                                singleTipView.tipImage.image = img
                                
                                if let likes = self.tip.likes {
                                    singleTipView.likes.text = "\(likes)"
                                    
                                    if likes == 1 {
                                        singleTipView.likeLabel.text = "Like"
                                    }
                                    else {
                                        singleTipView.likeLabel.text = "Likes"
                                    }
                                }
                                
                                if let desc = self.tip.description {
                                    
                                    let attributes = [NSParagraphStyleAttributeName : self.style]
                                    singleTipView.tipDescription?.attributedText = NSAttributedString(string: desc, attributes: attributes)
                                    singleTipView.tipDescription.textColor = UIColor.primaryTextColor()
                                    singleTipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                    singleTipView.tipDescription.textContainer.lineFragmentPadding = 0
                                    
                                }
                                
                                if placeName != nil {
                                    singleTipView.placeName.text = placeName
                                }
                                else {
                                    if let cat = self.tip.category {
                                        if cat == "eat" {
                                            singleTipView.placeName.text = "An " + cat + " spot"
                                        }
                                        else {
                                            singleTipView.placeName.text = "A " + cat + " spot"
                                        }
                                    }
                                }
                                
                                if showDistance {
                                    self.toggleUI(singleTipView, true)
                                }
                                else {
                                    self.hideDistance(singleTipView)
                                }
                                
                            }
                            
                            
                        })
                    }
                }
                
            }
            
        }
    }
    
    
    func createTipView(_ view: SingleTipView, tip: Tip, completionHandler: @escaping ((_ placeName: String?, _ minutes: UInt?, _ meters: UInt?, _ success: Bool) -> Void)) {
    
    
    
    
    
    }
    
    private func getLocationDetails(_ view: SingleTipView, completionHandler: @escaping ((_ placeName: String?, _ success: Bool, _ showDistance: Bool) -> Void)) {
        
        
        if let placeId = self.tip.placeId {
            
            if !placeId.isEmpty {
                
                DispatchQueue.main.async {
                    
                    self.placesClient?.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            completionHandler(nil, true, false)
                        }
                        
                        if let place = place {
                            
                            if !place.name.isEmpty {
                                
                                if let currLat = LocationService.sharedInstance.currentLocation?.coordinate.latitude {
                                    if let currLong = LocationService.sharedInstance.currentLocation?.coordinate.longitude {
                                self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: place.coordinate.latitude, destinationLong: place.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                    
                                    if success {
                                        
                                        let minutes = self.geoTask.totalDurationInSeconds / 60
                                        if (minutes <= 60) {
                                            view.walkingDistance.text = "\(minutes)"
                                            
                                            if minutes == 1 {
                                                view.walkingLabel.text = "Min"
                                            }
                                            else {
                                                view.walkingLabel.text = "Mins"
                                            }
                                        }
                                        else {
                                            completionHandler(place.name, true, false)
                                        }
                                        completionHandler(place.name, true, true)
                                        
                                        print("The total distance is: " + "\(self.geoTask.totalDistanceInMeters)")
                                        
                                        
                                    }
                                    else {
                                        completionHandler(place.name, true, false)
                                    }
                                    
                                })
                            }
                        }
                            }
                            
                        } else {
                            print("No place details for \(placeId)")
                        }
                    })
                    
                }
                
            }
                
                
            else {
                
                let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
                    
                    if error == nil {
                        
                        if let lat = location?.coordinate.latitude {
                            
                            if let long = location?.coordinate.longitude {
                                
                                if let currLat = LocationService.sharedInstance.currentLocation?.coordinate.latitude {
                                    if let currLong = LocationService.sharedInstance.currentLocation?.coordinate.longitude {
                                
                                self.getAddressFromLatLng(latitude: lat, longitude: long, completionHandler: { (placeName, success) in
                                    
                                    if success {
                                        
                                        self.geoTask.getDirections(currLat, originLong: currLong, destinationLat: lat, destinationLong: long, travelMode: self.travelMode, completionHandler: { (status, success) in
                                            
                                            if success {
                                                
                                                let minutes = self.geoTask.totalDurationInSeconds / 60
                                                if (minutes <= 60) {
                                                    view.walkingDistance.text = "\(minutes)"
                                                    
                                                    if minutes == 1 {
                                                        view.walkingLabel.text = "Min"
                                                    }
                                                    else {
                                                        view.walkingLabel.text = "Mins"
                                                    }
                                                }
                                                else {
                                                    completionHandler(placeName, true, false)
                                                }
                                                completionHandler(placeName, true, true)
                                                
                                                print("The total distance is: " + "\(self.geoTask.totalDistanceInMeters)")
                                                
                                                
                                            }
                                            else {
                                                completionHandler(placeName, true, false)
                                            }
                                            
                                        })
                                    }
                                    
                                })
                            }
                        }
                            }
                            
                        }
                    }
                    else {
                        
                        print(error?.localizedDescription)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    
    private func toggleUI(_ view: SingleTipView, _ show: Bool) {
    
        if show {
            view.isHidden = false
            view.tipImage.contentMode = .scaleAspectFill
            view.tipImage.clipsToBounds = true
            self.ai.stopAnimating()
            self.ai.removeFromSuperview()
        }
        else {
            view.isHidden = true
            }
    
    }
    
    
    private func hideDistance(_ view: SingleTipView) {
        view.likeIconLeadingConstraint.constant = 20.0
        view.walkingIcon.removeFromSuperview()
        view.walkingLabel.removeFromSuperview()
        view.walkingDistance.removeFromSuperview()
        self.toggleUI(view, true)
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.0, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.initTipView()
        })
    }
    
    func removeAnimate() {
        
        UIView.animate(withDuration: 0.15, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.dismiss(animated: true, completion: nil)
               // self.view.removeFromSuperview()
            }
        }
    }
    
    
    
    private func popUpMenu() {
        
        if let tip = self.tip {
            
            let editButtonTitle = "✏️ " + Constants.Notifications.EditTip
            let deleteButtonTitle = "❌  " + Constants.Notifications.DeleteTip
            
            let alertController = MyActionController(title: nil, message: nil, style: .ActionSheet)
            
            alertController.addButton(editButtonTitle, true) {
                self.delegate?.editTip(tip)
                self.removeAnimate()
                }
            
            alertController.addButton(deleteButtonTitle, true) {
                
                let message = "Are you sure you want to delete this tip?"
                let deleteAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                let messageMutableString = NSAttributedString(string: message, attributes: [
                    NSFontAttributeName : UIFont.systemFont(ofSize: 15),
                    NSForegroundColorAttributeName : UIColor.primaryTextColor()
                    ])
                
                deleteAlert.setValue(messageMutableString, forKey: "attributedMessage")
                
                
                
                let defaultAction = UIAlertAction(title: "Delete", style: .default) { action in
                    
                    if let tip = self.tip {
                        LoadingOverlay.shared.showOverlay(view: self.view)
                        self.deleteTip(tip, completionHandler: { (userId, success) in
                            
                            if success {
                                self.updateTotalTipsCount(userId, completionHandler: { success in
                                    
                                    if success {
                                        LoadingOverlay.shared.hideOverlayView()
                                    //    self.delayWithSeconds(1, completion: {
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: "tipsUpdated"), object: nil)
                                            FIRAnalytics.logEvent(withName: "tipDeleted", parameters: ["tipId" : tip.key! as NSObject, "category" : tip.category! as NSObject])
                                    //    })
                                        
                                        self.removeAnimate()
                                    }
                                    
                                })
                            }
                            
                        })
                    }
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                }
                defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                cancel.setValue(UIColor.primaryTextColor(), forKey: "titleTextColor")
                deleteAlert.addAction(defaultAction)
                deleteAlert.addAction(cancel)
                deleteAlert.preferredAction = defaultAction
                deleteAlert.show()            }
            
            alertController.cancelButtonTitle = "Cancel"
            
            alertController.touchingOutsideDismiss = true
            alertController.animated = false
            alertController.show()
        }
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

       
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    func tipImageHeightConstraintMultiplier() -> CGFloat {
        switch self.screenHeight() {
        case 568:
            return 0.68
            
        case 667:
            return 0.73
            
        case 736:
            return 0.75
            
        default:
            return 0.73
        }
    }
    
    
    
    private func deleteTip(_ tip: Tip, completionHandler: @escaping ((_ userId: String, _ success: Bool) -> Void)) {
        
        if let tipId = tip.key {
            
            if let userId = tip.addedByUser {
                
                if let category = tip.category {
                    
                    guard !tipId.isEmpty else {
                        completionHandler(userId, false)
                        return
                    }
                    
                    self.dataService.TIP_REF.child(tipId).removeValue { (error, ref) in
                        
                        if error == nil {
                            
                            self.dataService.CATEGORY_REF.child(category).child(tipId).removeValue(completionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    self.dataService.USER_TIP_REF.child(userId).child(tipId).removeValue(completionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            
                                            
                                            self.dataService.GEO_TIP_REF.child(tipId).removeValue(completionBlock: { (error, ref) in
                                                
                                                if error == nil {
                                                    print("Tip successfully deleted...")
                                                    completionHandler(userId, true)
                                                }
                                            })
                                        }
                                    })
                                    
                                }
                                
                            })
                        }
                        else {
                            print("Tip could not be deleted...")
                            completionHandler(userId, false)
                        }
                        
                    }
                }
            }
        }
    }
    

    
    
    private func updateTotalTipsCount(_ userId: String, completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        
        guard !userId.isEmpty else {
            completionHandler(false)
            return
        }
        
        self.dataService.USER_REF.child(userId).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            if var data = currentData.value as? [String : Any] {
                var count = data["totalTips"] as! Int
                
                if (count > 0) {
                count -= 1
                data["totalTips"] = count
                }
                
                currentData.value = data
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if committed {
                completionHandler(true)
            }
        }
        
        
    }
    
    
    func getAddressFromLatLng(latitude: Double, longitude: Double, completionHandler: @escaping ((_ tipPlace: String?, _ success: Bool) -> Void)) {
        let url = URL(string: "\(Constants.Config.GeoCodeString)latlng=\(latitude),\(longitude)")
        
        let request: URLRequest = URLRequest(url:url!)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if(error != nil) {
                
                print(error?.localizedDescription)
                completionHandler("", false)
                
            } else {
                
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                
                var status = jsonResult.value(forKey: kStatus) as! NSString
                status = status.lowercased as NSString
                
                if(status.isEqual(to: kOK)) {
                    
                    let address = AddressParser()
                    
                    address.parseGoogleLocationData(jsonResult)
                    
                    let addressDict = address.getAddressDictionary()
                    
                    if let placeId = addressDict["placeId"] as? String {
                        
                        DispatchQueue.main.async {
                            
                            self.placesClient?.lookUpPlaceID(placeId, callback: { (place, err) -> Void in
                                if let error = error {
                                    print("lookup place id query error: \(error.localizedDescription)")
                                    return
                                }
                                
                                if let place = place {
                                    
                                    
                                    if !place.name.isEmpty {
                                        print(place.name)
                                        completionHandler(place.name, true)
                                    }
                                    else {
                                        if let address = addressDict["formattedAddess"] as? String {
                                            completionHandler(address, true)
                                        }
                                    }
                                    
                                    
                                } else {
                                    print("No place details for \(placeId)")
                                    if let address = addressDict["formattedAddess"] as? String {
                                        completionHandler(address, true)
                                    }
                                }
                            })
                            
                        }
                    }
                    
                }
                else if(!status.isEqual(to: kZeroResults) && !status.isEqual(to: kAPILimit) && !status.isEqual(to: kRequestDenied) && !status.isEqual(to: kInvalidRequest)){
                    
                    completionHandler(nil, false)
                    
                }
                    
                else {
                    completionHandler(nil, false)
                }
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    
    
    private class AddressParser: NSObject {
        
        fileprivate var latitude = NSString()
        fileprivate var longitude  = NSString()
        fileprivate var streetNumber = NSString()
        fileprivate var route = NSString()
        fileprivate var locality = NSString()
        fileprivate var subLocality = NSString()
        fileprivate var formattedAddress = NSString()
        fileprivate var administrativeArea = NSString()
        fileprivate var administrativeAreaCode = NSString()
        fileprivate var subAdministrativeArea = NSString()
        fileprivate var postalCode = NSString()
        fileprivate var country = NSString()
        fileprivate var subThoroughfare = NSString()
        fileprivate var thoroughfare = NSString()
        fileprivate var ISOcountryCode = NSString()
        fileprivate var state = NSString()
        fileprivate var placeId = NSString()
        
        
        override init() {
            super.init()
        }
        
        fileprivate func getAddressDictionary()-> NSDictionary {
            
            let addressDict = NSMutableDictionary()
            
            addressDict.setValue(latitude, forKey: "latitude")
            addressDict.setValue(longitude, forKey: "longitude")
            addressDict.setValue(streetNumber, forKey: "streetNumber")
            addressDict.setValue(locality, forKey: "locality")
            addressDict.setValue(subLocality, forKey: "subLocality")
            addressDict.setValue(administrativeArea, forKey: "administrativeArea")
            addressDict.setValue(postalCode, forKey: "postalCode")
            addressDict.setValue(country, forKey: "country")
            addressDict.setValue(formattedAddress, forKey: "formattedAddress")
            addressDict.setValue(placeId, forKey: "placeId")
            
            return addressDict
        }
        
        
        fileprivate func parseGoogleLocationData(_ resultDict:NSDictionary) {
            
            let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
            
            let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString
            
            let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
            let location = geometry.object(forKey: "location") as! NSDictionary
            let lat = location.object(forKey: "lat") as! Double
            let lng = location.object(forKey: "lng") as! Double
            let placeId = locationDict.object(forKey: "place_id") as! NSString
            
            self.latitude = lat.description as NSString
            self.longitude = lng.description as NSString
            self.placeId = placeId
            
            let addressComponents = locationDict.object(forKey: "address_components") as! NSArray
            
            self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
            self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
            self.streetNumber = self.subThoroughfare
            self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
            self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
            self.route = component("route", inArray: addressComponents, ofType: "long_name")
            self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
            self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
            self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
            self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
            self.country =  component("country", inArray: addressComponents, ofType: "long_name")
            self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
            
            
            self.formattedAddress = formattedAddrs;
            
        }
        
        fileprivate func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
            let index = inArray.indexOfObject(passingTest:) {obj, idx, stop in
                
                let objDict:NSDictionary = obj as! NSDictionary
                let types:NSArray = objDict.object(forKey: "types") as! NSArray
                let type = types.firstObject as! NSString
                return type.isEqual(to: component as String)
            }
            
            if (index == NSNotFound){
                
                return ""
            }
            
            if (index >= inArray.count) {
                return ""
            }
            
            let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString
            
            if (type.length > 0){
                
                return type
            }
            return ""
            
        }
        
        fileprivate func getPlacemark() -> CLPlacemark {
            
            var addressDict = [String : AnyObject]()
            
            let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array
            
            let kSubAdministrativeArea = "SubAdministrativeArea"
            let kSubLocality           = "SubLocality"
            let kState                 = "State"
            let kStreet                = "Street"
            let kThoroughfare          = "Thoroughfare"
            let kFormattedAddressLines = "FormattedAddressLines"
            let kSubThoroughfare       = "SubThoroughfare"
            let kPostCodeExtension     = "PostCodeExtension"
            let kCity                  = "City"
            let kZIP                   = "ZIP"
            let kCountry               = "Country"
            let kCountryCode           = "CountryCode"
            let kPlaceId               = "PlaceId"
            
            addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
            addressDict[kSubLocality] = self.subLocality as NSString
            addressDict[kState] = self.administrativeAreaCode
            
            addressDict[kStreet] = formattedAddressArray.first! as NSString
            addressDict[kThoroughfare] = self.thoroughfare
            addressDict[kFormattedAddressLines] = formattedAddressArray as AnyObject?
            addressDict[kSubThoroughfare] = self.subThoroughfare
            addressDict[kPostCodeExtension] = "" as AnyObject?
            addressDict[kCity] = self.locality
            
            addressDict[kZIP] = self.postalCode
            addressDict[kCountry] = self.country
            addressDict[kCountryCode] = self.ISOcountryCode
            addressDict[kPlaceId] = self.placeId
            
            let lat = self.latitude.doubleValue
            let lng = self.longitude.doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict as [String : AnyObject]?)
            
            return (placemark as CLPlacemark)
            
        }
    }
}
