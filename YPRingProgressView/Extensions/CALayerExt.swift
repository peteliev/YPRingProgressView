//
//  CALayerExt.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/22/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa

public extension CALayer {
    
    func disableActions(for keyPathes: [String]) {
        actions = Dictionary(uniqueKeysWithValues: keyPathes.map { ($0, NSNull()) })
    }
}
