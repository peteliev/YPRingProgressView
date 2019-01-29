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
        static let numberOfSpectrumColours: Int = 360
    }
    
    // MARK: - Public Properties
    @IBInspectable public var progress: CGFloat = 0 {
        didSet { updateProgress() }
    }
    @IBInspectable public var ringWidth: CGFloat = 20 {
        didSet { updateRingWidth(animated: true) }
    }
    
    @IBInspectable public var ringShadowEnabled: Bool = false {
        didSet { updateRingShadow(animated: true) }
    }
    @IBInspectable public var ringShadowColor: NSColor = .black {
        didSet { updateRingShadow(animated: true) }
    }
    @IBInspectable public var ringShadowOpacity: CGFloat = 0.5 {
        didSet { updateRingShadow(animated: true) }
    }
    
    @IBInspectable public var ringStartColor: NSColor = .red {
        didSet { updateRingGradientImage() }
    }
    @IBInspectable public var ringEndColor: NSColor = .blue {
        didSet { updateRingGradientImage() }
    }
    @IBInspectable public var ringBackgroundColor: NSColor = .white {
        didSet { updateRingBackgroundColor() }
    }
    @IBInspectable public var backgroundColor: NSColor = .clear {
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
        setupRingDotLayer()
        
        [backgroundLayer, ringBackgroundLayer, ringForegroundLayer]
            .forEach { rootLayer.addSublayer($0) }
       
        ringForegroundLayer.mask = ringForegroundMaskLayer
        ringForegroundLayer.addSublayer(ringGradientLayer)
        ringGradientLayer.addSublayer(ringDotLayer)
    
        updateLayers()
        updateProgress()
        updateAppearance()
    }
    
    // MARK: - Private Properties
    private let rootLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let ringBackgroundLayer = CAShapeLayer()
    private let ringGradientLayer = CALayer()
    
    private let ringDotLayer = CALayer()
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
    
    func setupRingDotLayer() {
        ringDotLayer.shadowRadius = 5.0
        ringDotLayer.shadowOffset = NSSize(width: -5, height: 0)
        
        ringDotLayer.disableActions(for: basicDisabledKeypathes)
        ringDotLayer.actions = ["frame": CABasicAnimation(), "cornerRadius": CABasicAnimation(),
                                "bounds": CABasicAnimation(), "position": CABasicAnimation()]
    }
}


// MARK: - Update Methods
private extension YPRingProgressView {
    
    func updateProgress() {
        ringForegroundMaskLayer.strokeEnd = progress

        let angle = 360.0 - (360.0 * progress)
        ringGradientLayer.transform = CATransform3DMakeRotation(angle.degreesToRadians(), 0.0, 0.0, 1.0)
    }
    
    func updateLayers() {
        updateRingWidth()
        updateRingGradientImage()
    }
    
    func updateRingGradientImage() {
        let spectrumColors = buildSpectrumColors(from: ringStartColor, endColor: ringEndColor)
        let square = buildSquare(from: bounds)
        let radius = square.width / 2
        
        let gradientImage = buildGradientImage(from: spectrumColors, radius: radius)
        ringGradientLayer.contents = gradientImage
    }
    
    func updateRingWidth(animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        
        let ringPath = buildRingPath(from: bounds, with: ringWidth)
        ringBackgroundLayer.path = ringPath.cgPath
        ringBackgroundLayer.lineWidth = ringWidth
        ringForegroundMaskLayer.path = ringPath.cgPath
        ringForegroundMaskLayer.lineWidth = ringWidth
        
        updateDotLayer()
        CATransaction.commit()
    }
    
    func updateRingShadow(animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        
        let shadowOpacity = min(max(Float(ringShadowOpacity), 0.0), 1.0)
        ringDotLayer.shadowOpacity = ringShadowEnabled ? shadowOpacity : 0.0
        ringDotLayer.shadowColor = ringShadowColor.cgColor
        
        CATransaction.commit()
    }
    
    func updateDotLayer() {
        let spectrumColors = buildSpectrumColors(from: ringStartColor, endColor: ringEndColor)
        let numberOfColours = spectrumColors.count
        let ringRect = buildRingRect(from: bounds)
        let ringDimension = ringRect.width
        let ringWidthWithInset = ringWidth + ringWidth / 10
        
        let containsDot = 2 * CGFloat.pi * ringDimension / ringWidthWithInset
        let colorIndex = Int((CGFloat(numberOfColours) / containsDot) * (containsDot - 0.5))
        let closestColor = spectrumColors[colorIndex]
        
        ringDotLayer.backgroundColor = closestColor.cgColor
        ringDotLayer.cornerRadius = ringWidthWithInset / 2
        ringDotLayer.frame = CGRect(x: ringRect.origin.x + (ringDimension - ringWidthWithInset) / 2,
                                    y: ringRect.origin.y + ringDimension - ringWidthWithInset + (ringWidthWithInset - ringWidth) / 2,
                                    width: ringWidthWithInset, height: ringWidthWithInset)
    }
    
    func updateAppearance() {
        updateBackgroundColor()
        updateRingBackgroundColor()
        
        updateRingShadow()
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
    
    func buildGradientImage(from spectrumColors: [NSColor], radius: CGFloat) -> NSImage {
        let numberOfColours = spectrumColors.count
        
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
    
    func buildSpectrumColors(from startColor: NSColor, endColor: NSColor) -> [NSColor] {
        var spectrumColors = [NSColor]()
        var (fromRed, fromGreen, fromBlue) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        var (toRed, toGreen, toBlue) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        
        startColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: nil)
        endColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: nil)
        
        let numberOfColours = Configuration.numberOfSpectrumColours
        let dRed = (toRed - fromRed) / CGFloat(numberOfColours - 1)
        let dGreen = (toGreen - fromGreen) / CGFloat(numberOfColours - 1)
        let dBlue = (toBlue - fromBlue) / CGFloat(numberOfColours - 1)
        
        for n in 0..<numberOfColours {
            spectrumColors.append(NSColor(red: fromRed + CGFloat(n) * dRed,
                                          green: fromGreen + CGFloat(n) * dGreen,
                                          blue: fromBlue + CGFloat(n) * dBlue, alpha: 1.0))
        }
        
        return spectrumColors
    }
}


// MARK: - Retina Support
public extension YPRingProgressView {
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()

        if let scaleFactor = window?.backingScaleFactor, scaleFactor > 0 {
            [rootLayer, backgroundLayer, ringBackgroundLayer, ringGradientLayer, ringDotLayer, ringForegroundLayer, ringForegroundMaskLayer]
                .forEach { $0.contentsScale = scaleFactor }
        }
    }
}
