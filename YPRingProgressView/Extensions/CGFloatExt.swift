//
//  CGFloatExt.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/23/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Foundation

let π = CGFloat(Double.pi)

public extension CGFloat {

    public func degreesToRadians() -> CGFloat {
        return π * self / 180.0
    }

    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / π
    }
}
