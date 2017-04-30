//
//  Post.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/30/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        
    }
}
