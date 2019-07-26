//
//  Color.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/4/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

let ctaRed = UIColor(red: 255, green: 59, blue: 61)
let ctaBlue = UIColor(red: 13, green: 174, blue: 230)
let ctaBrown = UIColor(red: 162, green: 99, blue: 81)
let ctaGreen = UIColor(red: 25, green: 178, blue: 54)
let ctaOrange = UIColor(red: 254, green: 122, blue: 56)
let ctaPink = UIColor(red: 248, green: 130, blue: 165)
let ctaPurple = UIColor(red: 134, green: 76, blue: 188)
let ctaYellow = UIColor(red: 245, green: 201, blue: 4)

let notBlack = UIColor(red: 60, green: 60, blue: 60)
let alertRed = UIColor(red: 238, green: 80, blue: 83)
let alertYellow = UIColor(red: 236, green: 203, blue: 61)
let goodGreen = UIColor(red: 133, green: 217, blue: 117)
let infoBlue = UIColor(red: 118, green: 150, blue: 255)

