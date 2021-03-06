//
//  LoadingOverlay.swift
//  Yaknak
//
//  Created by Sascha Melcher on 04/02/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit

class LoadingOverlay {
    
    var overlayView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    static let shared = LoadingOverlay()
    
   private init() {
        self.overlayView = UIView()
        self.activityIndicator = UIActivityIndicatorView()
        
        overlayView.frame = CGRect(0, 0, UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        overlayView.backgroundColor = UIColor.white
        overlayView.clipsToBounds = true
        overlayView.layer.zPosition = 1
        
        activityIndicator.frame = CGRect(0, 0, 40, 40)
        activityIndicator.center = CGPoint(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
        activityIndicator.activityIndicatorViewStyle = .gray
      //  activityIndicator.color = UIColor.primaryColor()
        overlayView.addSubview(activityIndicator)
    }
    
    
    public func setSize(width: CGFloat, height: CGFloat) {
    
    overlayView.frame = CGRect(0, 0, width, height)
    }
    
    public func reCenterIndicator(view: UIView, navBarHeight: CGFloat) {
    activityIndicator.center = CGPoint(view.bounds.width / 2, view.bounds.height / 2 - navBarHeight)
    }
    
    public func showOverlay(view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
