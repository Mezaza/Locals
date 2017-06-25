//
//  MainCollectionViewDataSource.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/06/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import Kingfisher

protocol PickerDelegate: class {
    func openPicker()
}

class MainCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    var friends: [MyUser]!
    var tips: [Tip]!
    var user: MyUser!
    weak var delegate: PickerDelegate?
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
        return 1
        }
        else {
        return tips.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseMainCollectionViewCellIdentifier, for: indexPath)
        return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseGridViewCellIdentifier, for: indexPath) as! ProfileGridCell
            cell.imageView.backgroundColor = UIColor.tertiaryColor()
            cell.imageView.tag = 15
            if let urlString = self.tips[indexPath.row].tipImageUrl {
            let url = URL(string: urlString)
            let processor = ResizingImageProcessor(referenceSize: CGSize(width: 250, height: 250), mode: .aspectFill)
            cell.imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                print("\(indexPath.row): \(receivedSize)/\(totalSize)")
                
            }) { (image, error, cacheType, imageUrl) in
                
                print("\(indexPath.row): \(cacheType)")
            }
            }
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 1 {
            var reusableView: UICollectionReusableView? = nil
            
            if kind == UICollectionElementKindSectionHeader {
                let profileView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseProfileViewIdentifier, for: indexPath) as! ProfileContainerView
                
                profileView.userProfileImage.delegate = self
                let url = URL(string: self.user.photoUrl)
                
                profileView.userProfileImage.kf.indicatorType = .activity
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 500, height: 500), mode: .aspectFill)
                profileView.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    print("\(receivedSize)/\(totalSize)")
                }) { (image, error, cacheType, imageUrl) in
                    
                    profileView.userProfileImage.layer.cornerRadius = profileView.userProfileImage.frame.size.width / 2
                    if (image == nil) {
                        profileView.userProfileImage.image = UIImage(named: Constants.Images.ProfilePlaceHolder)
                    }
                    
                    profileView.nameLabel.text = self.user.name
                    
                    if let likes = self.user.totalLikes {
                        profileView.likes.text = "\(likes)"
                        
                        if (likes == 1) {
                            profileView.likesLabel.text = "Like"
                        }
                        else {
                            profileView.likesLabel.text = "Likes"
                        }
                    }
                    
                    if let tips = self.user.totalTips {
                        profileView.tips.text = "\(tips)"
                        
                        if (tips == 1) {
                            profileView.tipsLabel.text = "Tip"
                        }
                        else {
                            profileView.tipsLabel.text = "Tips"
                        }
                    }
                    
                }
                
                profileView.addBottomBorder(color: UIColor.tertiaryColor(), width: 1.0)
                profileView.addTopBorder(color: UIColor.tertiaryColor(), width: 1.0)
                
                reusableView = profileView
                
            }
            return reusableView!
        }
        return UICollectionReusableView()
        
    }
    
}



extension MainCollectionViewDataSource: ZoomImageDelegate {
    
    func didTapEdit() {
        print("Edit tapped...")
        delegate?.openPicker()
    }
}
