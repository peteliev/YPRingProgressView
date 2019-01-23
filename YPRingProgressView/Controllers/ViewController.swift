//
//  ViewController.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/20/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa

final public class ViewController: NSViewController {
    
    @IBOutlet weak var progressSlider: NSSlider!
    @IBOutlet weak var ringWidthSlider: NSSlider!
    @IBOutlet weak var ringProgressView: YPRingProgressView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // setup background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        // setup ringProgressView
        ringProgressView.progress = CGFloat(progressSlider.floatValue)
        ringProgressView.ringWidth = CGFloat(ringWidthSlider.floatValue)
    }

    @IBAction func progressSliderDidChangeValue(_ slider: NSSlider) {
        ringProgressView.progress = CGFloat(slider.floatValue)
    }
    
    @IBAction func ringWidthSliderDidChangeValue(_ slider: NSSlider) {
        ringProgressView.ringWidth = CGFloat(slider.floatValue)
    }
}
