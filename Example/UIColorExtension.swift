//
//  UIColorExtension.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/28/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    class func generateRandomColorHexString() -> String {
        var redLevel    = String(Int(arc4random_uniform(255)), radix: 16)
        var greenLevel  = String(Int(arc4random_uniform(255)), radix: 16)
        var blueLevel   = String(Int(arc4random_uniform(255)), radix: 16)
        
        redLevel = appendZeroToShortColor(color: redLevel)
        greenLevel = appendZeroToShortColor(color: greenLevel)
        blueLevel = appendZeroToShortColor(color: blueLevel)
        
        let color = String(format:"%@%@%@", redLevel, greenLevel, blueLevel)
        return color
    }
    
    private class func appendZeroToShortColor(color: String) -> String {
        if color.characters.count == 1 {
            return "0\(color)"
        }
        return color
    }
}
