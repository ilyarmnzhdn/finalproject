//
//  UserProfileController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/25/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {
    
    let cellId = "cellId"
    var posts = [Post]()
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = appBackgroundColor

        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        setupLogOutButton()
        
        fetchUser()
        
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid  else { return }
        let ref = FIRDatabase.database().reference().child("posts").child(uid)
        //perhaps later on we'll implement some pagination of data
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let user = self.user else { return }
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            
            self.collectionView?.reloadData()
        }) { (err) in
                print("Failed to fetch ordered posts:", err.localizedDescription)
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        present(alertController, animated: true, completion: nil)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try FIRAuth.auth()?.signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to Sign Out:", signOutErr.localizedDescription)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cansel", style: .cancel, handler: nil))
        
    }
    
    var user: User?
    
    fileprivate func fetchUser(){
        
        let uid = userId ?? (FIRAuth.auth()?.currentUser?.uid ?? "")
        
        FIRDatabase.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            
            self.fetchOrderedPosts()
        }
    }
}

