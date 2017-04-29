//
//  PhotoSelecterController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/29/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

class PhotoSelectorController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .purple
        
        setupNavigationButtons()
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
