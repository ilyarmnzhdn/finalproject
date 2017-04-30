//
//  PhotoSelecterController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/29/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var images = [UIImage]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = backgroundColor
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        
        //fetch photos
        
        fetchPhotos()
    }
    
    fileprivate func fetchPhotos() {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 10
        //fetch new images
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        allPhotos.enumerateObjects({ (asset, count, stop) in
            print(asset)
            
            let imageManager = PHImageManager.default()
            let targetSize = CGSize(width: 350, height: 350)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                
                if let image = image {
                    self.images.append(image)
                    
                    // Show first image in header cell
                    if self.selectedImage == nil {
                        self.selectedImage = image
                    }
                }
                
                if count == allPhotos.count - 1 {
                    self.collectionView?.reloadData()
                }
            })
        })
        
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cansel", style: .plain, target: self, action: #selector(handleCansel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    func handleCansel() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleNext() {
        print("Next pressed: ")
    }
}

