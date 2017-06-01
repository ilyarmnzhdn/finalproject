//
//  LikedPostController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/13/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import Foundation
import Firebase

class LikedPostController: UICollectionViewController {
    
    let cellId = "cellId"
    var likes = ""
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.tintColor = .white
        navBar.barTintColor = topBarBackgroundColor
        navBar.barStyle = .blackOpaque
        
        navigationItem.title = "Likes"
        
        collectionView?.backgroundColor = appBackgroundColor
        
        collectionView?.register(LikedPostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        fetchLikedPosts()
    }
    
    fileprivate func fetchLikedPosts() {
        guard let uid = FIRAuth.currentUid else { return }
        
        FIRDatabase.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = FIRDatabase.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = FIRAuth.currentUid else { return }
                FIRDatabase.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        self.posts.append(post)
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                    
                    self.collectionView?.reloadData()
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post", err.localizedDescription)
                })
            })
            
        }) { (err) in
            print("Fail to fetch post", err.localizedDescription)
        }
    }
}
