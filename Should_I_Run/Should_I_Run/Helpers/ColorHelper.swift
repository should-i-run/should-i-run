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

let colors = [
  colorize(0x6FD57F),
  colorize(0x068F86),
  colorize(0xFCB03C),
  colorize(0xFC5B3F),
]
