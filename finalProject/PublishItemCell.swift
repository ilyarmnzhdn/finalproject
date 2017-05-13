//
//  PublishItemCell.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/12/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class PublishItemCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            guard let userImageUrl = user?.profileImageUrl else {
                print("error")
                return }
            photoImageView.loadImage(urlString: userImageUrl)
            
            nameLabel.text = user?.username
        }
    }

    lazy var photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 160 / 2
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor

        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 4
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
    }
    
    func setupViews() {
        addSubview(photoImageView)
        addSubview(nameLabel)
        
        photoImageView.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 160, height: 160)
        nameLabel.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: self.frame.width, height: 40)
        nameLabel.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
