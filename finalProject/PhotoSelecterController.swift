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
    var assets = [PHAsset]()
    
    var header: PhotoSelectorHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = appBackgroundColor        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        
        //fetch photos
        
        fetchPhotos()
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        //fetch new images
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in
                print(asset)
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        // Show first image in header cell
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            })
        }
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCansel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    func handleCansel() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleNext() {
        let shareItemController = ShareItemController()
        shareItemController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(shareItemController, animated: true)
    }
    
}

