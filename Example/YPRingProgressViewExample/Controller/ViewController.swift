//
//  ViewController.swift
//  YPRingProgressViewExample
//
//  Created by Zhenya Peteliev on 1/29/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa
import YPRingProgressView

class ViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var ringProgressView: YPRingProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        ringProgressView.ringStartColor = NSColor(hex: 0x13547a)
        ringProgressView.ringEndColor = NSColor(hex: 0x80d0c7)
    }
    
    // MARK: - Actions
    @IBAction func progressSliderDidChangeValue(_ slider: NSSlider) {
        ringProgressView.progress = CGFloat(slider.floatValue)
    }
    
    @IBAction func ringWidthSliderDidChangeValue(_ slider: NSSlider) {
        ringProgressView.ringWidth = CGFloat(slider.floatValue)
    }

    @IBAction func ringShadowOpacitySliderDidChangeValue(_ slider: NSSlider) {
        ringProgressView.ringShadowOpacity = CGFloat(slider.floatValue)
    }

    @IBAction func ringShadowEnabled(_ button: NSButton) {
        ringProgressView.ringShadowEnabled = button.state == NSControl.StateValue.on
    }
    
    @IBAction func changeRingStartColor(_ colorWell: NSColorWell) {
        ringProgressView.ringStartColor = colorWell.color
    }
    
    @IBAction func changeRingEndColor(_ colorWell: NSColorWell) {
        ringProgressView.ringEndColor = colorWell.color
    }
    
    @IBAction func changeBackgroundColor(_ colorWell: NSColorWell) {
        ringProgressView.backgroundColor = colorWell.color
    }
    
    @IBAction func changeRingBackgroundColor(_ colorWell: NSColorWell) {
        ringProgressView.ringBackgroundColor = colorWell.color
    }
}
