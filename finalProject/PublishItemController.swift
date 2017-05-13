//
//  PublishItemController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/8/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class PublishItemController: UIViewController, TimeFrameDelegate {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    var followers = [User]()
    var filteredFollowers = [User]()
    var borrowedTo: String = ""
    var didSelected = false
    
    let cellId = "cellId"
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    let containerView = UIView()
    
    lazy var followersView: UICollectionView = {
        let layot = UICollectionViewFlowLayout()
        layot.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layot)
        return cv
    }()
    
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followersView.delegate = self
        followersView.dataSource = self
        followersView.register(PublishItemCell.self, forCellWithReuseIdentifier: cellId)
        followersView.backgroundColor = navBarBackgroudColor
        
        containerView.backgroundColor = appBackgroundColor
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height * 0.65)
        view.addSubview(followersView)
        followersView.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height * 0.35)
        
        setupViews()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .plain, target: self, action: #selector(handlePublish))
        
        fetchFollowingUsersIds()
    }
    
    fileprivate func fetchFollowingUsersIds() {
        guard let uid = FIRAuth.currentUid else { return }
        FIRDatabase.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let usersIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            usersIdsDictionary.forEach({ (key, value) in
                FIRDatabase.fetchUserWithUID(uid: key, completion: { (user) in
                    self.followers.append(user)
                    print(self.followers)
                    
                    self.followersView.reloadData()
                })
                
                self.followers.sort(by: { (u1, u2) -> Bool in
                    
                    return u1.username.compare(u2.username) == .orderedAscending
                    
                })
            })
            
            self.filteredFollowers = self.followers
            self.followersView.reloadData()
            
        }) { (err) in
            print("Failed to fetch following user uid's: ", err.localizedDescription)
        }
    }

    func handlePublish() {
        guard let caption = captionTV.text, caption.characters.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        guard let borrowAt = borrowTV.text, borrowAt.characters.count > 0 else { return }
        guard let returnAt = returnTV.text, returnAt.characters.count > 0 else { return }
        
        if didSelected != false {
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
            let filename = UUID().uuidString
            FIRStorage.storage().reference().child("posts").child(filename).put(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Fail to upload post image", err.localizedDescription)
                    return
                }
            
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
                self.saveToDataBaseWithImageUrl(imageUrl: imageUrl)
                }
        }
        
        print("You must select person")
    }
    
    fileprivate func saveToDataBaseWithImageUrl(imageUrl: String) {
        guard let uid = FIRAuth.currentUid else { return }
        guard let postImage = selectedImage else { return }
        guard let caption = captionTV.text else { return }
        guard let borrowDate = startDate else { return }
        guard let returnDate = endDate else { return }
        
        let newBorrow = borrowDate.timeIntervalSince1970
        let newReturn = returnDate.timeIntervalSince1970
        
        let userPostRef = FIRDatabase.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
            
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970, "borrowedAt": newBorrow, "returnAt": newReturn, "borrowedTo": borrowedTo] as [String: Any]
            
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err.localizedDescription)
                return
            }
            print("Successfully saved to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: ShareItemController.updateFeedNotificationName, object: nil)
        }
    
    }
    
    // VIEW
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        return iv
    }()
    
    // MARK: Add Caption with attributed string
    lazy var captionTV: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = true
        tv.layer.borderWidth = 1
        tv.layer.borderColor = textFieldBackgroundColor.cgColor
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.cornerRadius = 8
//        let attributedText = NSMutableAttributedString(string: "Enter caption...", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.gray])
//        tv.attributedText = attributedText
        return tv
    }()
    
    lazy var borrowedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "Borrowed at:"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var borrowTV: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.cornerRadius = 8
        tv.backgroundColor = textFieldBackgroundColor
        return tv
    }()
    
    lazy var returnAtLabel: UILabel = {
        let label = UILabel()
        label.text = "Return at:"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var returnTV: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.layer.cornerRadius = 8
        tv.backgroundColor = textFieldBackgroundColor
        return tv
    }()
    
    lazy var chooseTime: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Timeframe", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(handleChooseTimeframe), for: .touchUpInside)
        button.backgroundColor = topBarBackgroundColor
        return button
    }()
    
    lazy var borrowToLabel: UILabel = {
        let label = UILabel()
        label.text = "Item borrowed to:"
        label.textColor = topBarBackgroundColor
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        return label
    }()
    
    func handleChooseTimeframe() {
        print("Choose time")
        let timeframeController = TimeframeViewController()
        timeframeController.timeFrameDelegate = self
        present(timeframeController, animated: true, completion: nil)
    }
    
    func didSelectRange(range: GLCalendarDateRange) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyy"
        
        borrowTV.text = "\(dateFormatter.string(from: range.beginDate))"
        returnTV.text = "\(dateFormatter.string(from: range.endDate))"
        
        startDate = range.beginDate as Date
        endDate = range.endDate as Date
    }
    
    fileprivate func setupViews() {
        
        containerView.addSubview(imageView)
        containerView.addSubview(captionTV)
        
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 160, height: 160)
        
        captionTV.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        containerView.addSubview(borrowedAtLabel)
        containerView.addSubview(borrowTV)
        
        borrowedAtLabel.anchor(top: imageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: borrowTV.leftAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        borrowTV.anchor(top: imageView.bottomAnchor, left: borrowedAtLabel.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(returnAtLabel)
        containerView.addSubview(returnTV)
        
        returnAtLabel.anchor(top: borrowedAtLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: borrowedAtLabel.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: borrowedAtLabel.frame.width, height: 40)
        
        returnTV.anchor(top: borrowedAtLabel.bottomAnchor, left: borrowTV.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(chooseTime)
        chooseTime.anchor(top: returnTV.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 56)
        
        containerView.addSubview(borrowToLabel)
        borrowToLabel.anchor(top: chooseTime.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 0, height: 60)
        borrowToLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


