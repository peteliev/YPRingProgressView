//
//  CGFloatExt.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/23/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Foundation

public extension CGFloat {

    func degreesToRadians() -> CGFloat {
        return .pi * self / 180.0
    }

    func radiansToDegrees() -> CGFloat {
        return self * 180.0 / .pi
    }
}
