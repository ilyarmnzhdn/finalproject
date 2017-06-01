//
//  LikedPostCell.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/14/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

class LikedPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            let postImageUrl = post.imageUrl
            print(postImageUrl)
            postImageView.loadImage(urlString: postImageUrl)
            
            profileImageView.loadImage(urlString: post.user.profileImageUrl)
            
            let attributedText = NSMutableAttributedString(string: "\(post.user.username)", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " liked", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
            
            postLabel.attributedText = attributedText
            
        }
    }
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 4
        iv.layer.borderWidth = 1
        iv.layer.borderColor = navBarBackgroudColor.cgColor
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var postLabel: UILabel = {
        let label = UILabel()
        label.text = "post caption"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 1
        iv.layer.borderColor = navBarBackgroudColor.cgColor
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postLabel)
        addSubview(postImageView)
        addSubview(profileImageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        postLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: postImageView.leftAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        postLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        postImageView.anchor(top: topAnchor, left: postLabel.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 80, height: 80)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
