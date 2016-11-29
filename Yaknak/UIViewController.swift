//
//  UIViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 27/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

extension UIViewController {

func topMostViewController() -> UIViewController {
    // Handling Modal views
    if let presentedViewController = self.presentedViewController {
        return presentedViewController.topMostViewController()
    }
        // Handling UIViewController's added as subviews to some other views.
    else {
        for view in self.view.subviews
        {
            // Key property which most of us are unaware of / rarely use.
            if let subViewController = view.next {
                if subViewController is UIViewController {
                    let viewController = subViewController as! UIViewController
                    return viewController.topMostViewController()
                }
            }
        }
        return self
    }
}

}
