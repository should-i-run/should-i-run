//
//  ColorHelper.swift
//  Should I Run
//
//  Created by LM on 7/22/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import Foundation
import UIKit


// Global methods and variables
func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    let color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
    return color
}

// Background color of view controllers
let globalBackgroundColor: UIColor = colorize(0x222222, alpha: 1.0)
let globalNavigationBarColor: UIColor = colorize(0x222222, alpha: 1.0)
let globalTintColor: UIColor = UIColor.whiteColor()
let globalBarStyle: UIBarStyle = UIBarStyle.BlackTranslucent
