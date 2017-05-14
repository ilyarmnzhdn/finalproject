//
//  HomePostCell.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            print(post?.imageUrl ?? "")
            guard let imageUrl = post?.imageUrl else { return }
            
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "com_like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "com_like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            photoImageView.loadImage(urlString: imageUrl)
            
            usernameLabel.text = post?.user.username
            
            guard let profileImgUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.loadImage(urlString: profileImgUrl)
            
            guard let returnAt = post?.returnDate else { return }
            guard let borrowedAt = post?.borrowedDate else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            
            guard let lendTo = post?.lendTo else { return }
            guard let borrowedFrom = post?.borrowedFrom else { return }
            
            var receiver = ""
            if lendTo == "" {
                receiver = borrowedFrom
                print("borrowedFrom: \(receiver)")
                
                let attributedText = NSMutableAttributedString(string: "Borrowed at:", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: " \(dateFormatter.string(from: borrowedAt))", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.green]))
                attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 4)]))
                attributedText.append(NSAttributedString(string: "Return at:", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]))
                attributedText.append(NSAttributedString(string: " \(dateFormatter.string(from: returnAt))", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.red]))
                
                dateLabel.attributedText = attributedText
                
                FIRDatabase.fetchUserWithUID(uid: receiver, completion: { (user) in
                    self.receiverLabel.text = "Borrowed from: \(user.username)"
                    let receiverImgUrl = user.profileImageUrl
                    self.receiverImage.loadImage(urlString: receiverImgUrl)
                })
            } else {
                receiver = lendTo
                print("lendTo: \(receiver)")
                
                let attributedText = NSMutableAttributedString(string: "Lent at:", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "    \(dateFormatter.string(from: borrowedAt))", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.green]))
                attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 4)]))
                attributedText.append(NSAttributedString(string: "Return at:", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]))
                attributedText.append(NSAttributedString(string: " \(dateFormatter.string(from: returnAt))", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.red]))
                
                dateLabel.attributedText = attributedText
                
                FIRDatabase.fetchUserWithUID(uid: receiver, completion: { (user) in
                    self.receiverLabel.text = "Lend to: \(user.username)"
                    let receiverImgUrl = user.profileImageUrl
                    self.receiverImage.loadImage(urlString: receiverImgUrl)
                })
            }
            
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        
        guard let post = self.post else { return }
        
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.gray]))
        
        captionLabel.attributedText = attributedText
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
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "com_like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    lazy var returnDateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var receiverView: UIView = {
        let view = UIView()
        view.backgroundColor = navBarBackgroudColor
        view.alpha = 0.6
        return view
    }()
    
    lazy var receiverLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var receiverImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    func handleComment() {
        print("Trying to comment that post")
        guard let post = post else { return }
        
        delegate?.didTapComment(post: post)
    }
    
    func handleLike() {
        print("Like")
        delegate?.didLike(for: self)
    }
    
//    lazy var sendMessageButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
//        return button
//    }()
//    
//    lazy var bookmarkButton: UIButton = {
//        let button = UIButton(type: .system)
//        //button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
//        return button
//    }()
//    
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Borrowed at:"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = appBackgroundColor
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        addSubview(returnDateView)
        addSubview(receiverView)
        
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        returnDateView.anchor(top: userProfileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.frame.size.width * 0.6, height: 48)
        returnDateView.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        receiverView.anchor(top: nil, left: photoImageView.leftAnchor, bottom: photoImageView.bottomAnchor, right: photoImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 56)
        //self.frame.size.width * 0.45
        //self.frame.size.height * 0.08
        returnDateView.addSubview(dateLabel)
        dateLabel.anchor(top: returnDateView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 8, paddingRight: 16, width: returnDateView.frame.size.width * 0.9, height: returnDateView.frame.size.height)
        dateLabel.centerXAnchor.constraint(equalTo: returnDateView.centerXAnchor).isActive = true
        
        //receiverView
        receiverView.addSubview(receiverLabel)
        receiverView.addSubview(receiverImage)
        receiverLabel.anchor(top: receiverView.topAnchor, left: receiverView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: receiverView.frame.size.width * 0.7, height: 40)
        receiverImage.anchor(top: receiverView.topAnchor, left: nil, bottom: nil, right: receiverView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 40, height: 40)
        
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 80, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
