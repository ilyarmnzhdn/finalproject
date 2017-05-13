//
//  PublishItemController+Extention.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/12/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import Foundation

extension PublishItemController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = followersView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PublishItemCell

        cell.user = self.followers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return followers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: followersView.frame.height * 0.7, height: followersView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        return UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(didSelected)
        let borrowed = followers[indexPath.row]
        if borrowedTo == borrowed.uid {
            print("You already added this user")
            didSelected = false
            borrowedTo = ""
        } else {
            borrowedTo = borrowed.uid
            print(borrowedTo)
            didSelected = true
        }
    }
}
