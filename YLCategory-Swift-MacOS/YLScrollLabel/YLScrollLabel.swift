//
//  YLScrollLabel.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/3/3.
//

import Cocoa

open class YLScrollLabel: NSView, CAAnimationDelegate {
    
    /// 文本内容
    open var stringValue: String? {
        set {
            textLayer.string = newValue ?? ""
            guard let stringValue = newValue else {
                textSize = .zero
                originFrame = .zero
                scrollOriginFrame = .zero
                canScroll = false
                animationDuration = 0
                textLayer.removeAllAnimations()
                needsLayout = true
                return
            }
            let maxSize: NSSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let attrs: [NSAttributedString.Key: Any] = [.font : textLayer.font as! NSFont]
            textSize = stringValue.boundingRect(with: maxSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attrs).size
            textSize = NSSize(width: ceil(textSize.width), height: ceil(textSize.height))
            needsLayout = true
        }
        get {
            return textLayer.string as? String
        }
    }
    
    /// 字体
    open var font: NSFont {
        set {
            textLayer.font = newValue
            textLayer.fontSize = newValue.pointSize
            stringValue = stringValue
        }
        get {
            return textLayer.font as! NSFont
        }
    }
    
    /// 文字颜色
    open var textColor: NSColor? {
        set {
            textLayer.foregroundColor = newValue?.cgColor
        }
        get {
            guard let cgColor = textLayer.foregroundColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
    }

    /// 显示模式
    open var lineBreakMode: NSLineBreakMode {
        set {
            switch newValue {
            case .byTruncatingHead:     textLayer.truncationMode = .start
            case .byTruncatingTail:     textLayer.truncationMode = .end
            case .byTruncatingMiddle:   textLayer.truncationMode = .middle
            default: break
            }
        }
        get {
            switch textLayer.truncationMode {
            case .start:    return .byTruncatingHead
            case .end:      return .byTruncatingTail
            case .middle:   return .byTruncatingMiddle
            default: break
            }
            return .byTruncatingMiddle
        }
    }
    // 是否开启滚动
    open var isScrollEnable = true
    // 滚动速度 (数值越大，滚动越快)
    open var speed: UInt = 40 {
        didSet {
            if speed == 0 {
                speed = 40
            }
            needsLayout = true
        }
    }
    
    // 点击回调
    open var clickHandler: ((YLScrollLabel) -> Void)?
    
    @discardableResult
    open func sizeToFit() -> NSSize {
        frame.size = textSize
        needsLayout = true
        return textSize
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        wantsLayer = true
        layer?.addSublayer(textLayer)
        layer?.masksToBounds = true
    }
    
    open override func layout() {
        super.layout()
        
        guard let _ = stringValue else {
            textLayer.frame = .zero
            trackingAreas.forEach { removeTrackingArea($0) }
            return
        }

        let width = bounds.size.width
        let height = bounds.size.height
        let y: CGFloat = (height - textSize.height) / 2
        textLayer.frame = NSRect(x: 0, y: y, width: width, height: textSize.height)
        
        scrollOriginFrame = NSRect(x: 0, y: y, width: textSize.width, height: textSize.height)
        originFrame = textLayer.frame
        
        canScroll = textSize.width > width
        animationDuration = (textSize.width - width) / CGFloat(speed)
        
        // 监听鼠标划入｜划出
        addMouseTrackingArea()
    }
    
    // MARK: - 鼠标手势
    
    private(set) var textSize: NSSize = .zero       // 文字的高度
    private var canScroll = false                   // 是否可以滚动
    private var animationDuration: CGFloat = 0.0    // 动画需要的时长
    private var scrollOriginFrame: NSRect = .zero   // 滚动时，最初的frame
    private var originFrame: NSRect = .zero         // 静止时的frame
    
    private func addMouseTrackingArea() {
        trackingAreas.forEach { removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self)
        addTrackingArea(trackingArea)
    }
    
    open override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if !canScroll || !isScrollEnable { return }
        textLayer.frame = scrollOriginFrame
        textLayer.removeAllAnimations()
        textLayer.add(createScrollAnimation(), forKey: "scroll")
    }

    open override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        if !canScroll || !isScrollEnable { return }
        textLayer.frame = originFrame
        textLayer.removeAllAnimations()
    }
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        clickHandler?(self)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {
            textLayer.frame = originFrame
            textLayer.removeAllAnimations()
            return
        }
        if let scrollAnimation = textLayer.animation(forKey: "scroll"),
           scrollAnimation == anim {
            // 正向滚动结束，添加方向滚动
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.textLayer.add(self.createReverseScrollAnimation(), forKey: "reverseScroll")
            }
            return
        }
        if let reverseScrollAnimation = textLayer.animation(forKey: "reverseScroll"),
           reverseScrollAnimation == anim {
            // 反向滚动结束，添加正向滚动
            textLayer.removeAllAnimations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.textLayer.add(self.createScrollAnimation(), forKey: "scroll")
            }
        }
    }
    
    private func createScrollAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = animationDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.toValue = bounds.width - textLayer.bounds.width
        animation.delegate = self
        return animation
    }
    private func createReverseScrollAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = animationDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.toValue = 0
        animation.delegate = self
        return animation
    }
    
    private lazy var textLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.truncationMode = .middle
        layer.isWrapped = false
        layer.font = NSFont.systemFont(ofSize: 13)
        layer.fontSize = 13
        layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
        return layer
    }()
}
