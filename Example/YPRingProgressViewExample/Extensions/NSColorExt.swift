//
//  NSColorExt.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/21/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa

public extension NSColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }
}
