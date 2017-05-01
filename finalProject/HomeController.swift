//
//  HomeController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = appBackgroundColor
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
    }
}
