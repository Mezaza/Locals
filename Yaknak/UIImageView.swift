//
//  UIImageView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 14/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithUrlString(urlString: String, placeholder: UIImage?) {
        
        self.image = placeholder
        
        // check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        //  otherwise fire off a new download
        
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async() {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
                
                
            }
            
        }).resume()
        
        
    }
    
    
    func loadTipImage(urlString: String, placeholder: UIImage?, completionHandler: @escaping (Bool) -> ()) {
        
        self.image = placeholder
        
        // check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            completionHandler(true)
            return
        }
        
        //  otherwise fire off a new download
        
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async() {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                    completionHandler(true)
                }
                
                
            }
            
        }).resume()
        
    }
    
}
