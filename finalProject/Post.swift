//
//  Post.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/30/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

struct Post {
    
    var id: String?
    
    let user: User
    let imageUrl: String
    let caption: String
    let lendTo: String
    let borrowedFrom: String
    let creationDate: Date
    let borrowedDate: Date
    let returnDate: Date
    
    var hasLiked = false
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.lendTo = dictionary["lendTo"] as? String ?? ""
        self.borrowedFrom = dictionary["borrowedFrom"] as? String ?? ""
        
        let timeForCreationDate = dictionary["creationDate"] as? Double ?? 0 //need to change to creationDate
        self.creationDate = Date(timeIntervalSince1970: timeForCreationDate)
        
        let timeForBorrowedDate = dictionary["borrowedAt"] as? Double ?? 0
        self.borrowedDate = Date(timeIntervalSince1970: timeForBorrowedDate)
        
        let timeForReturnDate = dictionary["returnAt"] as? Double ?? 0
        self.returnDate = Date(timeIntervalSince1970: timeForReturnDate) 
    }
}
