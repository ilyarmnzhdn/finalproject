//
//  HomePostCell.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            print(post?.imageUrl ?? "")
            guard let imageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: imageUrl)
        }
    }
    
    lazy var photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(photoImageView)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: frame.width, height: 40)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
