//
//  HomeController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, HomePostCellDelegate {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Observer for notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: ShareItemController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = appBackgroundColor
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItem()
        
        fetchAllPosts()
    }
    
    func handleUpdateFeed() {
        handleRefresh()
    }
    
    func handleRefresh() {
        posts.removeAll()
        
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        
        fetchPosts()
        fetchFollowingUsersIds()
    }
    
    fileprivate func fetchFollowingUsersIds() {
        guard let uid = FIRAuth.currentUid else { return }
        FIRDatabase.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let usersIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            usersIdsDictionary.forEach({ (key, value) in
                FIRDatabase.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following user uid's: ", err.localizedDescription)
        }
    }
    
    func setupNavigationItem() {
        
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.tintColor = .white
        navBar.barTintColor = topBarBackgroundColor
        navBar.barStyle = .blackOpaque
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "lendify-logo").withRenderingMode(.alwaysOriginal))
    }
    
    func handleCamera() {
        print("Showing camera")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    fileprivate func fetchPosts() {
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
                
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
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
    
    func didTapComment(post: Post) {
        print("Message coming from HomeController")
        print(post.caption)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
    
        guard let postId = post.id else { return }
        guard let uid = FIRAuth.currentUid else { return }
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        FIRDatabase.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("Failed to like post", err.localizedDescription)
                return
            }
            
            print("Successfully liked post")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            // Update just one cell in collection view
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
}
