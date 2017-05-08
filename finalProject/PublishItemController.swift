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
        guard let itemName = itemNameTF.text, itemName.characters.count > 0 else { return }
        guard let description = itemDescriptionTF.text, description.characters.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        guard let borrowAt = borrowTV.text, borrowAt.characters.count > 0 else { return }
        guard let returnAt = returnTV.text, returnAt.characters.count > 0 else { return }
        
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
        guard let itemName = itemNameTF.text else { return }
        guard let description = itemDescriptionTF.text else { return }
        guard let borrowDate = startDate else { return }
        guard let returnDate = endDate else { return }
        
        let newBorrow = borrowDate.timeIntervalSince1970
        let newReturn = returnDate.timeIntervalSince1970
        
        let userPostRef = FIRDatabase.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "itemName": itemName, "description": description, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970, "borrowedAt": newBorrow, "returnAt": newReturn] as [String: Any]
        
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
    
    lazy var itemNameTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Item name..."
        textField.borderStyle = .roundedRect
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        textField.backgroundColor = textFieldBackgroundColor
        return textField
    }()
    
    lazy var itemDescriptionTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Item description..."
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = textFieldBackgroundColor
        return textField
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
        
        let containerView = UIView()
        containerView.backgroundColor = appBackgroundColor
        view.addSubview(containerView)
        
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.frame.height / 1.7)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 160, height: 160)
        
        containerView.addSubview(itemNameTF)
        itemNameTF.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
        
        containerView.addSubview(itemDescriptionTF)
        itemDescriptionTF.anchor(top: itemNameTF.bottomAnchor, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


