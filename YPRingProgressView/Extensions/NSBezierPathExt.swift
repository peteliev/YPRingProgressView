//
//  NSBezierPathExt.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/21/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa

// MARK: - NSBezierPath + CGPath
public extension NSBezierPath {
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for index in 0 ..< elementCount {
            let type = element(at: index, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo: path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                                                          control1: CGPoint(x: points[0].x, y: points[0].y),
                                                          control2: CGPoint(x: points[1].x, y: points[1].y))
            case .closePath: path.closeSubpath()
            }
        }
        return path
    }
}


// MARK: - NSBezierPath + ringPath
public extension NSBezierPath {
    
    class func ringPath(from rect: NSRect, with ringWidth: CGFloat) -> NSBezierPath {
        let inset = ringWidth / 2
        let rectWithInset = rect.insetBy(dx: inset, dy: inset)
        
        let radius = rectWithInset.width / 2
        let center = CGPoint(x: rectWithInset.midX, y: rectWithInset.midY)
        
        let ringPath = NSBezierPath()
        ringPath.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: -270, clockwise: true)
        return ringPath
    }
}
