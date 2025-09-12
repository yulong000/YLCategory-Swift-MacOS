//
//  NSView+SmoothCorner.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/9/5.
//

import AppKit
import ObjectiveC.runtime

fileprivate var NSViewSmoothCornerMaskLayerKey: UInt8 = 0
fileprivate var NSViewSmoothCornerBorderLayerKey: UInt8 = 0
fileprivate var NSViewSmoothCornerMaskCornerKey: UInt8 = 0

public extension NSView {
    
    /// 设置平滑圆角
    func setSmoothCorner(_ value: CGFloat) {
        setSmoothCorner(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
    }

    /// 分别设置4个角的半径
    func setSmoothCorner(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomRight: CGFloat = 0, bottomLeft: CGFloat = 0) {
        if topLeft > 0 || topRight > 0 || bottomRight > 0 || bottomLeft > 0 {
            NSView.smoothCornerSwizzleViewWillDraw()
            wantsLayer = true
            smoothCornerMaskCorner = NSViewMaskCorner(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
            if smoothCornerMaskLayer == nil {
                smoothCornerMaskLayer = CAShapeLayer()
            }
        } else {
            smoothCornerMaskCorner = nil
            smoothCornerMaskLayer = nil
            layer?.mask = nil
        }
        needsLayout = true
    }

    /// 设置圆角边框颜色和宽度
    func setSmoothCornerBorder(color: NSColor, width: CGFloat = 1) {
        if width > 0 {
            NSView.smoothCornerSwizzleViewWillDraw()
            wantsLayer = true
            if smoothCornerBorderLayer == nil {
                smoothCornerBorderLayer = CAShapeLayer()
            }
            smoothCornerBorderLayer?.lineWidth = width * 2
            smoothCornerBorderLayer?.strokeColor = color.cgColor
        } else {
            smoothCornerMaskLayer?.removeFromSuperlayer()
            smoothCornerMaskLayer = nil
        }
        needsLayout = true
    }

    /// 绘制平滑圆角及边框
    private func drawSmoothCornerAndBorder() {
        guard let layer = self.layer,
              let maskLayer = self.smoothCornerMaskLayer,
              let maskCorner = self.smoothCornerMaskCorner else { return }
        // 圆角
        maskLayer.frame = layer.bounds
        let bezierPath = NSViewCornerBezierPath(rect: maskLayer.bounds, corner: maskCorner)
        if #available(macOS 14.0, *) {
            maskLayer.path = bezierPath.cgPath
        } else {
            maskLayer.path = bezierPath.getCGPath()
        }
        layer.mask = maskLayer
        
        // 边框
        if let borderLayer = smoothCornerBorderLayer {
            borderLayer.frame = layer.bounds
            borderLayer.fillColor = .clear
            borderLayer.path = maskLayer.path
            layer.insertSublayer(borderLayer, at: 0)
        }
    }
    
    // MARK: - 增加的属性
    
    private var smoothCornerMaskLayer: CAShapeLayer? {
        get { objc_getAssociatedObject(self, &NSViewSmoothCornerMaskLayerKey) as? CAShapeLayer }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerMaskLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var smoothCornerMaskCorner: NSViewMaskCorner? {
        get { objc_getAssociatedObject(self, &NSViewSmoothCornerMaskCornerKey) as? NSViewMaskCorner }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerMaskCornerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var smoothCornerBorderLayer: CAShapeLayer? {
        get { objc_getAssociatedObject(self, &NSViewSmoothCornerBorderLayerKey) as? CAShapeLayer }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerBorderLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Method Swizzling
    
    /// 可以保证替换方法只执行一次
    private static var smoothCornerViewWillDrawDidSwizzle = false
    // 交换 layout()
    private static func smoothCornerSwizzleViewWillDraw() {
        guard !smoothCornerViewWillDrawDidSwizzle else { return }
        if let originalMethod = class_getInstanceMethod(NSView.self, #selector(viewWillDraw)),
           let swizzledMethod = class_getInstanceMethod(NSView.self, #selector(smoothCorner_viewWillDraw)) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
            smoothCornerViewWillDrawDidSwizzle = true
        }
    }
    
    @objc private func smoothCorner_viewWillDraw() {
        smoothCorner_viewWillDraw()
        drawSmoothCornerAndBorder()
    }

}


// MARK: - 四个角的半径

public struct NSViewMaskCorner {
    
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomRight: CGFloat
    var bottomLeft: CGFloat
    
    init(_ value: CGFloat) {
        topLeft = value
        topRight = value
        bottomLeft = value
        bottomRight = value
    }
    
    init(topLeft: CGFloat = 0,
                topRight: CGFloat = 0,
                bottomRight: CGFloat = 0,
                bottomLeft: CGFloat = 0) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
}

// MARK: - 裁剪的曲线

open class NSViewCornerBezierPath: NSBezierPath {
    
    // 系数
    private let coeff: CGFloat = 1.28195
    
    convenience init(rect: NSRect, corner: NSViewMaskCorner) {
        self.init()
        
        var last = NSPoint(x: rect.width, y: rect.origin.y)
        move(to: NSPoint(x: rect.origin.x + corner.topLeft * coeff, y: last.y))
        
        // top
        
        line(to: NSPoint(x: last.x - corner.topRight * coeff, y: last.y))
        
        // top right c1
        last = NSPoint(x: last.x - corner.topRight * coeff, y: last.y)
        curve(to: NSPoint(x: last.x + corner.topRight * 0.77037, y: last.y + corner.topRight * 0.13357),
              controlPoint1: NSPoint(x: last.x + corner.topRight * 0.44576, y: last.y),
              controlPoint2: NSPoint(x: last.x + corner.topRight * 0.6074, y: last.y + corner.topRight * 0.04641))
        
        // top right c2
        last = NSPoint(x: last.x + corner.topRight * 0.77037, y: last.y + corner.topRight * 0.13357)
        curve(to: NSPoint(x: last.x + corner.topRight * 0.37801, y: last.y + corner.topRight * 0.37801),
              controlPoint1: NSPoint(x: last.x + corner.topRight * 0.16296, y: last.y + corner.topRight * 0.08715),
              controlPoint2: NSPoint(x: last.x + corner.topRight * 0.290086, y: last.y + corner.topRight * 0.2150))
        
        // top right c3
        last = NSPoint(x: last.x + corner.topRight * 0.37801, y: last.y + corner.topRight * 0.37801)
        curve(to: NSPoint(x: last.x + corner.topRight * 0.13357, y: last.y + corner.topRight * 0.77037),
              controlPoint1: NSPoint(x: last.x + corner.topRight * 0.08715, y: last.y + corner.topRight * 0.16296),
              controlPoint2: NSPoint(x: last.x + corner.topRight * 0.13357, y: last.y + corner.topRight * 0.32461))
        
        // right
        
        last = NSPoint(x: rect.size.width, y: rect.size.height)
        line(to: NSPoint(x: last.x, y: last.y - corner.bottomRight * coeff))
        
        // bottom right c1
        last = NSPoint(x: last.x, y: last.y - corner.bottomRight * coeff)
        curve(to: NSPoint(x: last.x - corner.bottomRight * 0.13357, y: last.y + corner.bottomRight * 0.77037),
              controlPoint1: NSPoint(x: last.x, y: last.y + corner.bottomRight * 0.44576),
              controlPoint2: NSPoint(x: last.x - corner.bottomRight * 0.04641, y: last.y + corner.bottomRight * 0.6074))
        
        // bottom right c2
        last = NSPoint(x: last.x - corner.bottomRight * 0.13357, y: last.y + corner.bottomRight * 0.77037)
        curve(to: NSPoint(x: last.x - corner.bottomRight * 0.37801, y: last.y + corner.bottomRight * 0.37801),
              controlPoint1: NSPoint(x: last.x - corner.bottomRight * 0.08715, y: last.y + corner.bottomRight * 0.16296),
              controlPoint2: NSPoint(x: last.x - corner.bottomRight * 0.21505, y: last.y + corner.bottomRight * 0.290086))
        
        // bottom right c3
        last = NSPoint(x: last.x - corner.bottomRight * 0.37801, y: last.y + corner.bottomRight * 0.37801)
        curve(to: NSPoint(x: last.x - corner.bottomRight * 0.77037, y: last.y + corner.bottomRight * 0.13357),
              controlPoint1: NSPoint(x: last.x - corner.bottomRight * 0.16296, y: last.y + corner.bottomRight * 0.08715),
              controlPoint2: NSPoint(x: last.x - corner.bottomRight * 0.32461, y: last.y + corner.bottomRight * 0.13357))
        
        // bottom
        
        last = NSPoint(x: rect.origin.x, y: rect.height)
        line(to: NSPoint(x: last.x + corner.bottomLeft * coeff, y: last.y))
        
        // bottom left c1
        last = NSPoint(x: last.x + corner.bottomLeft * coeff, y: last.y)
        curve(to: NSPoint(x: last.x - corner.bottomLeft * 0.77037, y: last.y - corner.bottomLeft * 0.13357),
              controlPoint1: NSPoint(x: last.x - corner.bottomLeft * 0.44576, y: last.y),
              controlPoint2: NSPoint(x: last.x - corner.bottomLeft * 0.6074, y: last.y - corner.bottomLeft * 0.04641))
        
        // bottom left c2
        last = NSPoint(x: last.x - corner.bottomLeft * 0.77037, y: last.y - corner.bottomLeft * 0.13357)
        curve(to: NSPoint(x: last.x - corner.bottomLeft * 0.37801, y: last.y - corner.bottomLeft * 0.37801),
              controlPoint1: NSPoint(x: last.x - corner.bottomLeft * 0.16296, y: last.y - corner.bottomLeft * 0.08715),
              controlPoint2: NSPoint(x: last.x - corner.bottomLeft * 0.290086, y: last.y - corner.bottomLeft * 0.2150))
        
        // bottom left c3
        last = NSPoint(x: last.x - corner.bottomLeft * 0.37801, y: last.y - corner.bottomLeft * 0.37801)
        curve(to: NSPoint(x: last.x - corner.bottomLeft * 0.13357, y: last.y - corner.bottomLeft * 0.77037),
              controlPoint1: NSPoint(x: last.x - corner.bottomLeft * 0.08715, y: last.y - corner.bottomLeft * 0.16296),
              controlPoint2: NSPoint(x: last.x - corner.bottomLeft * 0.13357, y: last.y - corner.bottomLeft * 0.32461))
        
        // left
        
        line(to: NSPoint(x: rect.origin.x, y: rect.origin.y + corner.topLeft * coeff))
        
        // top left c1
        last = NSPoint(x: rect.origin.x, y: rect.origin.y + corner.topLeft * coeff)
        curve(to: NSPoint(x: last.x + corner.topLeft * 0.13357, y: last.y - corner.topLeft * 0.77037),
              controlPoint1: NSPoint(x: last.x, y: last.y - corner.topLeft * 0.44576),
              controlPoint2: NSPoint(x: last.x + corner.topLeft * 0.04641, y: last.y - corner.topLeft * 0.6074))
        
        // top left c2
        last = NSPoint(x: last.x + corner.topLeft * 0.13357, y: last.y - corner.topLeft * 0.77037)
        curve(to: NSPoint(x: last.x + corner.topLeft * 0.37801, y: last.y - corner.topLeft * 0.37801),
              controlPoint1: NSPoint(x: last.x + corner.topLeft * 0.08715, y: last.y - corner.topLeft * 0.16296),
              controlPoint2: NSPoint(x: last.x + corner.topLeft * 0.21505, y: last.y - corner.topLeft * 0.290086))
        
        // top left c3
        last = NSPoint(x: last.x + corner.topLeft * 0.37801, y: last.y - corner.topLeft * 0.37801)
        curve(to: NSPoint(x: last.x + corner.topLeft * 0.77037, y: last.y - corner.topLeft * 0.13357),
              controlPoint1: NSPoint(x: last.x + corner.topLeft * 0.16296, y: last.y - corner.topLeft * 0.08715),
              controlPoint2: NSPoint(x: last.x + corner.topLeft * 0.32461, y: last.y - corner.topLeft * 0.13357))
        
        close()
    }
    
    func getCGPath() -> CGPath {
        let path = CGMutablePath()
        var points = [NSPoint](repeating: .zero, count: 3)
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2],
                              control1: points[0],
                              control2: points[1])
            case .closePath:
                path.closeSubpath()
            default:
                break
            }
        }
        return path
    }

}
