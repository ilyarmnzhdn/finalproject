//
//  UserSearchController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/2/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {
    
    var users = [User]()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter user's name"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return sb
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = appBackgroundColor
        
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.anchor(top: navBar.topAnchor, left: navBar.leftAnchor, bottom: navBar.bottomAnchor, right: navBar.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
        
        fetchUsers()
    }
    
    fileprivate func fetchUsers() {
        let ref = FIRDatabase.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String : Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let userDictionary = value as? [String : Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch users for search:", err.localizedDescription)
        }
    }
}
