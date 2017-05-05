//
//  FirebaseUtils.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/1/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import Firebase

extension FIRDatabase {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts: ", err.localizedDescription)
        }
    }
}

extension FIRAuth {
    static var currentUid: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
}
