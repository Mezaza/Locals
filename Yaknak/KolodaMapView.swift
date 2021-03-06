//
//  KolodaMapView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Kingfisher


  public class KolodaMapView: UIView {
  
  @IBOutlet weak var userPic: UIImageView!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var duration: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var likes: UILabel!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var mapView: GMSMapView!
  public var routePolyline: GMSPolyline!
  

  override public func draw(_ rect: CGRect) {
    userPic.layer.cornerRadius = self.userPic.frame.size.width / 2
    userPic.clipsToBounds = true
  }
  
   func update(progress: CGFloat, direction: SwipeResultDirection) {
    
    switch direction {
    case .right:
      alpha = progress / 100
      break
    case .left:
      if alpha > 0.0 {
        alpha = 0
      }
      break
    default:
      alpha = 1
    }
  }
  
  
  
   func setCameraPosition(atLocation currentLocation: CLLocation) {
    mapView.camera = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
  }
  
  
  func drawMapDetails(for tipData: TipData) {
    
    guard let tip = tipData.tip, let urlString = tip.userPicUrl else {return}
    
    let url = URL(string: urlString)
    
    let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100))
    userPic.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
      
      print("\(receivedSize)/\(totalSize)")
      
    }, completionHandler: { (image, error, cacheType, imageUrl) in
      
      guard let tipLikes = tip.likes else {return}
      
      self.likes.text = "\(tipLikes)"
      if tipLikes == 1 {
        self.likesLabel.text = "like"
      }
      else {
        self.likesLabel.text = "likes"
      }
      
      self.drawMap(for: tipData)
      
    })
  }
  
  
  func drawMap(for tipData: TipData) {
    
    mapView.clear()
    
    guard let minutes = tipData.minutes, let position = tipData.markerPosition, let tip = tipData.tip, let category = tip.category, let route = tipData.route else {return}
    
    duration.text = "\(minutes)"
    
    if minutes == 1 {
      durationLabel.text = "min"
    }
    else {
      durationLabel.text = "mins"
    }
    
    let marker = GMSMarker(position: position)
    marker.title = Constants.Notifications.InfoWindow
    guard let image = UIImage(named: category + "-marker") else {return}
    self.drawRoute(with: category, route: route)
    marker.icon = image
    marker.map = mapView
  }
  
  
   func drawRoute(with category: String, route: String) {
    
  //  let route = geoTask.overviewPolyline["points"] as! String
    let path: GMSPath = GMSPath(fromEncodedPath: route)!
    routePolyline = GMSPolyline(path: path)
    routePolyline.strokeColor = UIColor.routeColor(with: category)
    routePolyline.strokeWidth = 10.0
    routePolyline.geodesic = true
    routePolyline.map = mapView
  }

}
