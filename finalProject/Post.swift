//
//  Post.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/30/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

struct Post {
    
    let user: User
    let imageUrl: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
