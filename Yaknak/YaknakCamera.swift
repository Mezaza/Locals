//
//  Camera.swift
//  Yaknak
//
//  Created by Sascha Melcher on 31/07/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import AVFoundation

open class YaknakCamera: YaknakBasePermission, YaknakPermissionProtocol {
  open var identifier: String = "YaknakCamera"
  
  public init() {
    super.init(identifier: self.identifier)
  }
  
  public override init(configuration: YaknakConfiguration? = nil,  initialPopupData: YaknakPopupData? = nil, reEnablePopupData: YaknakPopupData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }
  
  open func status(completion: @escaping YaknakPermissionResponse) {
    switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
    case .notDetermined:
      return completion(.notDetermined)
    case .restricted, .denied:
      return completion(.denied)
    case .authorized:
      return completion(.authorized)
    }
  }
  
  open func askForPermission(completion: @escaping YaknakPermissionResponse) {
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (authorized) in
      if authorized {
        print("📷 permission authorized by user ✅")
        return completion(.authorized)
      }
      print("📷 permission denied by user ⛔️")
      return completion(.denied)
    }
  }
}
