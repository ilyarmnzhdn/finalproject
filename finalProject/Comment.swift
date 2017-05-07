//
//  Comment.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/7/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0 //need to change to creationDate
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
