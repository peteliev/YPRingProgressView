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
        static let ringRectInset: CGFloat = 30
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
        setupRingForegroundMaskLayer()
        
        [backgroundLayer, ringBackgroundLayer, ringForegroundLayer]
            .forEach { rootLayer.addSublayer($0) }
       
        ringForegroundLayer.addSublayer(ringGradientLayer)
        ringForegroundLayer.mask = ringForegroundMaskLayer
    
        updateColors()
        updateLayers()
        updateProgressValue()
    }
    
    // MARK: - Private Properties
    private let rootLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let ringBackgroundLayer = CAShapeLayer()
    private let ringGradientLayer = CALayer()
    
    private let ringForegroundLayer = CALayer()
    private let ringForegroundMaskLayer = CAShapeLayer()
    
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
    
    func setupRingGradientLayer() {
        ringGradientLayer.frame = bounds
        ringGradientLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        ringGradientLayer.contentsGravity = .center
        
        let disabledKeypathes = basicDisabledKeypathes + ["contents"]
        ringGradientLayer.disableActions(for: disabledKeypathes)
    }
    
    func setupRingForegroundLayer() {
        ringForegroundLayer.frame = bounds
        ringForegroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        ringForegroundLayer.disableActions(for: basicDisabledKeypathes)
    }
    
    func setupRingForegroundMaskLayer() {
        ringForegroundMaskLayer.frame = bounds
        ringForegroundMaskLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        ringForegroundMaskLayer.lineCap = .round
        ringForegroundMaskLayer.lineJoin = .round
        ringForegroundMaskLayer.fillColor = NSColor.clear.cgColor
        ringForegroundMaskLayer.strokeColor = NSColor.black.cgColor
        
        ringForegroundMaskLayer.disableActions(for: basicDisabledKeypathes)
        ringForegroundMaskLayer.actions = ["lineWidth": CABasicAnimation(), "path": CABasicAnimation()]
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
        ringForegroundMaskLayer.path = ringPath.cgPath
        ringBackgroundLayer.lineWidth = ringWidth
        ringForegroundMaskLayer.lineWidth = ringWidth
        
        CATransaction.commit()
    }
    
    func updateRingGradientImage() {
        let square = buildSquare(from: bounds)
        let radius = square.width / 2
        
        let gradientImage = buildGradientImage(from: ringStartColor, endColor: ringEndColor, radius: radius)
        ringGradientLayer.contents = gradientImage
    }
    
    func updateProgressValue() {
        let angle = 360 - (360 * progress)
        ringForegroundMaskLayer.strokeEnd = progress
        ringGradientLayer.transform = CATransform3DMakeRotation(angle.degreesToRadians(), 0.0, 0.0, 1.0)
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
        let square = buildSquare(from: rect)
        return square.insetBy(dx: inset, dy: inset)
    }
    
    func buildSquare(from rect: NSRect) -> NSRect {
        let minSide = min(bounds.width, bounds.height)
        let origin = NSPoint(x: (bounds.width - minSide) / 2, y: (bounds.height - minSide) / 2)
        return NSRect(origin: origin, size: NSSize(width: minSide, height: minSide))
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
