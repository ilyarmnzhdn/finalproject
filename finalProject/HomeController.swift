//
//  HomeController.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class HomeController: UICollectionViewController, HomePostCellDelegate, UNUserNotificationCenterDelegate {
    
    let cellId = "cellId"
    var posts = [Post]()
    let currentDate = Date()
    
    func findOutOfDate(posts: [Post]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyy"
        
        for post in posts {
            if post.lendTo == "" && post.borrowedFrom != "" {
                let returnDate = post.returnDate

                if formatter.string(from: returnDate) == formatter.string(from: currentDate) {
                    guard var outOfDatePosts = UserDefaults.standard.value(forKey: "postsId") as? [String] else {
                        UserDefaults.standard.set([], forKey: "postsId")
                        UserDefaults.standard.synchronize()
                        return
                    }
                    
                    var isExist = false
                    for item in outOfDatePosts {
                        if post.id == item {
                            isExist = true
                        }
                    }
                    
                    if !isExist {
                        showNotification(post.caption)
                        outOfDatePosts.append(post.id!)
                        UserDefaults.standard.set(outOfDatePosts, forKey: "postsId")
                        UserDefaults.standard.synchronize()
                    }
                    
                    print("\n \n \n BANG!")
                }
            }
        }
    }
    
    func showNotification(_ caption: String) {
        let notification = UNMutableNotificationContent()
        
        notification.title = "You should return \(caption) to owner"
        notification.body = "Please, hurry up!"
        notification.sound = UNNotificationSound.default()
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "returnItem", content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        print("Notification being triggered")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.set([], forKey: "postsId")
//        UserDefaults.standard.synchronize()
        //Observer for notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: ShareItemController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = appBackgroundColor
        
        UNUserNotificationCenter.current().delegate = self
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItem()
        
        fetchAllPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
                    self.findOutOfDate(posts: self.posts)
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
