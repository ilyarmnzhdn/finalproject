//
//  LikedPostController+Extention.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/14/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

extension LikedPostController : UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
        //return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LikedPostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
