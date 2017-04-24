//
//  UIColor+extensions.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 4/24/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
