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
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .plain, target: self, action: #selector(handlePublish))
        
        setupViews()
    }
    
    func handlePublish() {
        guard let itemName = itemNameTW.text, itemName.characters.count > 0 else { return }
        guard let description = itemDescriptionTW.text, description.characters.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        guard let borrowAt = borrowTW.text, borrowAt.characters.count > 0 else { return }
        guard let returnAt = returnTW.text, returnAt.characters.count > 0 else { return }
        
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
    
    fileprivate func saveToDataBaseWithImageUrl(imageUrl: String) {
        guard let uid = FIRAuth.currentUid else { return }
        guard let postImage = selectedImage else { return }
        guard let itemName = itemNameTW.text else { return }
        guard let description = itemDescriptionTW.text else { return }
        guard let borrowAt = borrowTW.text else { return }
        guard let returnAt = returnTW.text else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy"
        // MARK: Fix this, Проблема в том, что в returnDate приходит nil
        guard let borrowDate = dateFormatter.date(from: borrowAt) else { return }
        guard let returnDate = dateFormatter.date(from: returnAt) else {
            print("fooo")
            return
        }
        
        let userPostRef = FIRDatabase.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "itemName": itemName, "description": description, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970, "borrowedAt": borrowDate, "returnAt": returnDate] as [String: Any]
        
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
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        return iv
    }()
    
    lazy var itemNameTW: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.boldSystemFont(ofSize: 14)
        tv.backgroundColor = .yellow
        tv.text = "Item name"
        return tv
    }()
    
    lazy var itemDescriptionTW: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .yellow
        tv.text = "Item description"
        return tv
    }()
    
    lazy var borrowedAtLabel: UILabel = {
        let label = UILabel()
        label.text = "Borrowed at:"
        label.backgroundColor = .purple
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var borrowTW: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .yellow
        return tv
    }()
    
    lazy var returnAtLabel: UILabel = {
        let label = UILabel()
        label.text = "Return at:"
        label.backgroundColor = .purple
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var returnTW: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .yellow
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
    
    func handleChooseTimeframe() {
        print("Choose time")
        let timeframeController = TimeframeViewController()
        timeframeController.timeFrameDelegate = self
        present(timeframeController, animated: true, completion: nil)
    }
    
    func didSelectRange(range: GLCalendarDateRange) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyy"
        
        borrowTW.text = "\(dateFormatter.string(from: range.beginDate))"
        returnTW.text = "\(dateFormatter.string(from: range.endDate))"
        
        startDate = range.beginDate
        endDate = range.endDate
    }
    
    fileprivate func setupViews() {
        
        let containerView = UIView()
        containerView.backgroundColor = .red
        view.addSubview(containerView)
        
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height / 1.7)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 160, height: 160)
        
        containerView.addSubview(itemNameTW)
        itemNameTW.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(itemDescriptionTW)
        itemDescriptionTW.anchor(top: itemNameTW.bottomAnchor, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        containerView.addSubview(borrowedAtLabel)
        containerView.addSubview(borrowTW)
        
        borrowedAtLabel.anchor(top: imageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: borrowTW.leftAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        borrowTW.anchor(top: imageView.bottomAnchor, left: borrowedAtLabel.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(returnAtLabel)
        containerView.addSubview(returnTW)
        
        returnAtLabel.anchor(top: borrowedAtLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: borrowedAtLabel.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: borrowedAtLabel.frame.width, height: 40)
        
        returnTW.anchor(top: borrowedAtLabel.bottomAnchor, left: borrowTW.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(chooseTime)
        chooseTime.anchor(top: returnTW.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 56)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


