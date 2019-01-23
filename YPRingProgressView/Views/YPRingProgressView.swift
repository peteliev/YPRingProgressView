//
//  YPRingProgressView.swift
//  YPRingProgressView
//
//  Created by Zhenya Peteliev on 1/20/19.
//  Copyright © 2019 Zhenya Peteliev. All rights reserved.
//

import Cocoa

@IBDesignable
final public class YPRingProgressView: NSView {
    
    private struct Configuration {
        static let ringRectInset: CGFloat = 0
    }
    
    // MARK: - Public Properties
    @IBInspectable public var progress: CGFloat = 0 {
        didSet { updateProgressValue() }
    }
    @IBInspectable public var ringWidth: CGFloat = 50 {
        didSet { updateRingWidth(animated: true) }
    }
    
    @IBInspectable public var ringStartColor: NSColor = .red {
        didSet { updateRingGradientImage() }
    }
    @IBInspectable public var ringEndColor: NSColor = .blue {
        didSet { updateRingGradientImage() }
    }
    @IBInspectable public var ringBackgroundColor: NSColor = NSColor(hex: 0x2F1315) {
        didSet { updateRingBackgroundColor() }
    }
    @IBInspectable public var backgroundColor: NSColor = .green {
        didSet { updateBackgroundColor() }
    }
    
    // MARK: - Initializers
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    func commonInit() {
        layer = rootLayer
        wantsLayer = true
        
        setupBackgroundLayer()
        setupRingGradientLayer()
        setupRingBackgroundLayer()
        setupRingForegroundLayer()
        
        
        [backgroundLayer, ringBackgroundLayer, ringGradientLayer].forEach { rootLayer.addSublayer($0) }
        ringGradientLayer.mask = ringForegroundLayer
    
        updateColors()
        updateLayers()
        updateProgressValue()
    }
    
    // MARK: - Private Properties
    private let rootLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let ringBackgroundLayer = CAShapeLayer()
    private let ringForegroundLayer = CAShapeLayer()
    private let ringGradientLayer = CALayer()
    
    // keypathes
    private let basicDisabledKeypathes = ["position", "frame", "bounds", "zPosition", "anchorPoint", "anchorPointZ", "contentsScale"]
}


// MARK: - NSView
public extension YPRingProgressView {
    
    override public var frame: NSRect {
        didSet { updateLayers() }
    }
}


// MARK: - Setup Methods
private extension YPRingProgressView {
    
    func setupBackgroundLayer() {
        backgroundLayer.frame = bounds
        backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        backgroundLayer.disableActions(for: basicDisabledKeypathes)
    }
    
    func setupRingBackgroundLayer() {
        ringBackgroundLayer.frame = bounds
        ringBackgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        ringBackgroundLayer.fillColor = NSColor.clear.cgColor
        
        ringBackgroundLayer.disableActions(for: basicDisabledKeypathes)
        ringBackgroundLayer.actions = ["lineWidth": CABasicAnimation(), "path": CABasicAnimation()]
    }
    
    func setupRingForegroundLayer() {
        ringForegroundLayer.frame = bounds
        ringForegroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        ringForegroundLayer.lineCap = .round
        ringForegroundLayer.lineJoin = .round
        ringForegroundLayer.fillColor = NSColor.clear.cgColor
        ringForegroundLayer.strokeColor = NSColor.black.cgColor
        
        ringForegroundLayer.disableActions(for: basicDisabledKeypathes)
        ringForegroundLayer.actions = ["lineWidth": CABasicAnimation(), "path": CABasicAnimation()]
    }
    
    func setupRingGradientLayer() {
        ringGradientLayer.frame = bounds
        ringGradientLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        ringGradientLayer.contentsGravity = .center
        
        let disabledKeypathes = basicDisabledKeypathes + ["contents"]
        ringGradientLayer.disableActions(for: disabledKeypathes)
    }
}


// MARK: - Update Methods
private extension YPRingProgressView {
    
    func updateLayers() {
        updateRingWidth()
        updateRingGradientImage()
    }
    
    func updateRingWidth(animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        
        let ringPath = buildRingPath(from: bounds, with: ringWidth)
        ringBackgroundLayer.path = ringPath.cgPath
        ringForegroundLayer.path = ringPath.cgPath
        ringBackgroundLayer.lineWidth = ringWidth
        ringForegroundLayer.lineWidth = ringWidth
        
        CATransaction.commit()
    }
    
    func updateRingGradientImage() {
        let ringRect = buildRingRect(from: bounds)
        let ringRadius = ringRect.width / 2
        
        let gradientImage = buildGradientImage(from: ringStartColor, endColor: ringEndColor, radius: ringRadius)
        ringGradientLayer.contents = gradientImage
    }
    
    func updateProgressValue() {
        ringForegroundLayer.strokeEnd = progress
    }
    
    func updateColors() {
        updateBackgroundColor()
        updateRingBackgroundColor()
        updateRingGradientImage()
    }
    
    func updateBackgroundColor() {
        backgroundLayer.backgroundColor = backgroundColor.cgColor
    }
    
    func updateRingBackgroundColor() {
        ringBackgroundLayer.strokeColor = ringBackgroundColor.cgColor
    }
}


// MARK: - Private
private extension YPRingProgressView {
    
    func buildRingPath(from rect: NSRect, with ringWidth: CGFloat) -> NSBezierPath {
        let ringRect = buildRingRect(from: rect)
        return NSBezierPath.ringPath(from: ringRect, with: ringWidth)
    }
    
    func buildRingRect(from rect: NSRect) -> NSRect {
        let inset = Configuration.ringRectInset
        let minSide = min(bounds.width, bounds.height)
        let origin = NSPoint(x: (bounds.width - minSide) / 2, y: (bounds.height - minSide) / 2)
        
        let ringRect = NSRect(origin: origin, size: NSSize(width: minSide, height: minSide))
        return ringRect.insetBy(dx: inset, dy: inset)
    }
    
    func buildGradientImage(from startColor: NSColor, endColor: NSColor, radius: CGFloat) -> NSImage {
        var spectrumColors = [NSColor]()
        var (fromRed, fromGreen, fromBlue) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        var (toRed, toGreen, toBlue) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        
        startColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: nil)
        endColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: nil)
        
        let numberOfColours = 360;
        let dRed = (toRed - fromRed) / CGFloat(numberOfColours - 1)
        let dGreen = (toGreen - fromGreen) / CGFloat(numberOfColours - 1)
        let dBlue = (toBlue - fromBlue) / CGFloat(numberOfColours - 1)
        
        for n in 0..<numberOfColours {
            spectrumColors.append(NSColor(red: fromRed + CGFloat(n) * dRed,
                                          green: fromGreen + CGFloat(n) * dGreen,
                                          blue: fromBlue + CGFloat(n) * dBlue, alpha: 1.0))
        }
        
        let diameter = radius * 2
        let center = NSPoint(x: radius, y: radius)
        let size = NSSize(width: diameter, height: diameter);
        
        let image = NSImage(size: size)
        image.lockFocus()
        
        (0..<numberOfColours).forEach { n in
            let color = spectrumColors[n]
            let startAngle = CGFloat(90 - n)
            let endAngle = CGFloat(90 - (n + 1))
            
            let bezierPath = NSBezierPath()
            bezierPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            bezierPath.line(to: center)
            bezierPath.close()
            
            color.set()
            bezierPath.fill()
            bezierPath.stroke()
        }
        
        image.unlockFocus()
        return image
    }
}


// MARK: - Retina Support
public extension YPRingProgressView {
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()

        if let scaleFactor = window?.backingScaleFactor, scaleFactor > 0 {
            [rootLayer, backgroundLayer, ringBackgroundLayer, ringForegroundLayer, ringGradientLayer]
                .forEach { $0.contentsScale = scaleFactor }
        }
    }
}
