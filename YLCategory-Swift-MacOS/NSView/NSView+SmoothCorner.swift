//
//  NSView+SmoothCorner.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/9/5.
//

import AppKit

fileprivate var NSViewSmoothCornerMaskLayerKey: UInt8 = 0
fileprivate var NSViewSmoothCornerMaskCornerKey: UInt8 = 0
fileprivate var NSViewSmoothCornerBorderColorKey: UInt8 = 0
fileprivate var NSViewSmoothCornerBorderWidthKey: UInt8 = 0

public extension NSView {
    /// 设置平滑圆角
    func setSmoothCorner(_ value: CGFloat) {
        if value > 0 {
            smoothCornerMaskCorner = NSViewMaskCorner(value)
            smoothCornerMaskLayer = CAShapeLayer()
            wantsLayer = true
        } else {
            smoothCornerMaskCorner = nil
            smoothCornerMaskLayer = nil
            layer?.mask = nil
        }
        needsDisplay = true
    }

    /// 分别设置4个角的半径
    func setSmoothCorner(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomRight: CGFloat = 0, bottomLeft: CGFloat = 0) {
        if topLeft > 0 || topRight > 0 || bottomRight > 0 || bottomLeft > 0 {
            smoothCornerMaskCorner = NSViewMaskCorner(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
            smoothCornerMaskLayer = CAShapeLayer()
            wantsLayer = true
        } else {
            smoothCornerMaskCorner = nil
            smoothCornerMaskLayer = nil
            layer?.mask = nil
        }
        needsDisplay = true
    }

    /// 设置圆角边框颜色和宽度
    func setSmoothCornerBorder(color: NSColor, width: CGFloat = 1) {
        smoothCornerBorderColor = color
        smoothCornerBorderWidth = width
        needsDisplay = true
    }

    /// 在 draw(_:) 中调用，绘制平滑圆角及边框 ，在 layout() 中调用，只会绘制平滑圆角
    func drawSmoothCorner() {
        guard let layer = self.layer,
              let maskLayer = self.smoothCornerMaskLayer,
              let maskCorner = self.smoothCornerMaskCorner else { return }
        maskLayer.frame = layer.bounds
        let bezierPath = NSViewCornerBezierPath(rect: maskLayer.bounds, corner: maskCorner)
        if #available(macOS 14.0, *) {
            maskLayer.path = bezierPath.cgPath
        } else {
            maskLayer.path = bezierPath.getCGPath()
        }
        layer.mask = maskLayer
        
        // 绘制边框
        if let borderColor = smoothCornerBorderColor, let borderWidth = smoothCornerBorderWidth {
            bezierPath.lineWidth = borderWidth
            borderColor.setStroke()
            bezierPath.stroke()
        }
    }
    
    // MARK: - 增加的属性
    
    private var smoothCornerMaskLayer: CAShapeLayer? {
        get { return objc_getAssociatedObject(self, &NSViewSmoothCornerMaskLayerKey) as? CAShapeLayer }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerMaskLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var smoothCornerMaskCorner: NSViewMaskCorner? {
        get { return objc_getAssociatedObject(self, &NSViewSmoothCornerMaskCornerKey) as? NSViewMaskCorner }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerMaskCornerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var smoothCornerBorderColor: NSColor? {
        get { return objc_getAssociatedObject(self, &NSViewSmoothCornerBorderColorKey) as? NSColor }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerBorderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var smoothCornerBorderWidth: CGFloat? {
        get { return (objc_getAssociatedObject(self, &NSViewSmoothCornerBorderWidthKey) as? NSNumber).map { CGFloat(truncating: $0) } }
        set { objc_setAssociatedObject(self, &NSViewSmoothCornerBorderWidthKey, newValue.map { NSNumber(value: Double($0)) }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
        
        let newCorner = adjust(mask: corner, with: rect)
        
        var last = NSPoint(x: rect.width, y: rect.origin.y)
        move(to: NSPoint(x: rect.origin.x + newCorner.topLeft * coeff, y: last.y))
        
        // top
        
        line(to: NSPoint(x: last.x - newCorner.topRight * coeff, y: last.y))
        
        // top right c1
        last = NSPoint(x: last.x - newCorner.topRight * coeff, y: last.y)
        curve(to: NSPoint(x: last.x + newCorner.topRight * 0.77037, y: last.y + newCorner.topRight * 0.13357),
              controlPoint1: NSPoint(x: last.x + newCorner.topRight * 0.44576, y: last.y),
              controlPoint2: NSPoint(x: last.x + newCorner.topRight * 0.6074, y: last.y + newCorner.topRight * 0.04641))
        
        // top right c2
        last = NSPoint(x: last.x + newCorner.topRight * 0.77037, y: last.y + newCorner.topRight * 0.13357)
        curve(to: NSPoint(x: last.x + newCorner.topRight * 0.37801, y: last.y + newCorner.topRight * 0.37801),
              controlPoint1: NSPoint(x: last.x + newCorner.topRight * 0.16296, y: last.y + newCorner.topRight * 0.08715),
              controlPoint2: NSPoint(x: last.x + newCorner.topRight * 0.290086, y: last.y + newCorner.topRight * 0.2150))
        
        // top right c3
        last = NSPoint(x: last.x + newCorner.topRight * 0.37801, y: last.y + newCorner.topRight * 0.37801)
        curve(to: NSPoint(x: last.x + newCorner.topRight * 0.13357, y: last.y + newCorner.topRight * 0.77037),
              controlPoint1: NSPoint(x: last.x + newCorner.topRight * 0.08715, y: last.y + newCorner.topRight * 0.16296),
              controlPoint2: NSPoint(x: last.x + newCorner.topRight * 0.13357, y: last.y + newCorner.topRight * 0.32461))
        
        // right
        
        last = NSPoint(x: rect.size.width, y: rect.size.height)
        line(to: NSPoint(x: last.x, y: last.y - newCorner.bottomRight * coeff))
        
        // bottom right c1
        last = NSPoint(x: last.x, y: last.y - newCorner.bottomRight * coeff)
        curve(to: NSPoint(x: last.x - newCorner.bottomRight * 0.13357, y: last.y + newCorner.bottomRight * 0.77037),
              controlPoint1: NSPoint(x: last.x, y: last.y + newCorner.bottomRight * 0.44576),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomRight * 0.04641, y: last.y + newCorner.bottomRight * 0.6074))
        
        // bottom right c2
        last = NSPoint(x: last.x - newCorner.bottomRight * 0.13357, y: last.y + newCorner.bottomRight * 0.77037)
        curve(to: NSPoint(x: last.x - newCorner.bottomRight * 0.37801, y: last.y + newCorner.bottomRight * 0.37801),
              controlPoint1: NSPoint(x: last.x - newCorner.bottomRight * 0.08715, y: last.y + newCorner.bottomRight * 0.16296),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomRight * 0.21505, y: last.y + newCorner.bottomRight * 0.290086))
        
        // bottom right c3
        last = NSPoint(x: last.x - newCorner.bottomRight * 0.37801, y: last.y + newCorner.bottomRight * 0.37801)
        curve(to: NSPoint(x: last.x - newCorner.bottomRight * 0.77037, y: last.y + newCorner.bottomRight * 0.13357),
              controlPoint1: NSPoint(x: last.x - newCorner.bottomRight * 0.16296, y: last.y + newCorner.bottomRight * 0.08715),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomRight * 0.32461, y: last.y + newCorner.bottomRight * 0.13357))
        
        // bottom
        
        last = NSPoint(x: rect.origin.x, y: rect.height)
        line(to: NSPoint(x: last.x + newCorner.bottomLeft * coeff, y: last.y))
        
        // bottom left c1
        last = NSPoint(x: last.x + newCorner.bottomLeft * coeff, y: last.y)
        curve(to: NSPoint(x: last.x - newCorner.bottomLeft * 0.77037, y: last.y - newCorner.bottomLeft * 0.13357),
              controlPoint1: NSPoint(x: last.x - newCorner.bottomLeft * 0.44576, y: last.y),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomLeft * 0.6074, y: last.y - newCorner.bottomLeft * 0.04641))
        
        // bottom left c2
        last = NSPoint(x: last.x - newCorner.bottomLeft * 0.77037, y: last.y - newCorner.bottomLeft * 0.13357)
        curve(to: NSPoint(x: last.x - newCorner.bottomLeft * 0.37801, y: last.y - newCorner.bottomLeft * 0.37801),
              controlPoint1: NSPoint(x: last.x - newCorner.bottomLeft * 0.16296, y: last.y - newCorner.bottomLeft * 0.08715),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomLeft * 0.290086, y: last.y - newCorner.bottomLeft * 0.2150))
        
        // bottom left c3
        last = NSPoint(x: last.x - newCorner.bottomLeft * 0.37801, y: last.y - newCorner.bottomLeft * 0.37801)
        curve(to: NSPoint(x: last.x - newCorner.bottomLeft * 0.13357, y: last.y - newCorner.bottomLeft * 0.77037),
              controlPoint1: NSPoint(x: last.x - newCorner.bottomLeft * 0.08715, y: last.y - newCorner.bottomLeft * 0.16296),
              controlPoint2: NSPoint(x: last.x - newCorner.bottomLeft * 0.13357, y: last.y - newCorner.bottomLeft * 0.32461))
        
        // left
        
        line(to: NSPoint(x: rect.origin.x, y: rect.origin.y + newCorner.topLeft * coeff))
        
        // top left c1
        last = NSPoint(x: rect.origin.x, y: rect.origin.y + newCorner.topLeft * coeff)
        curve(to: NSPoint(x: last.x + newCorner.topLeft * 0.13357, y: last.y - newCorner.topLeft * 0.77037),
              controlPoint1: NSPoint(x: last.x, y: last.y - newCorner.topLeft * 0.44576),
              controlPoint2: NSPoint(x: last.x + newCorner.topLeft * 0.04641, y: last.y - newCorner.topLeft * 0.6074))
        
        // top left c2
        last = NSPoint(x: last.x + newCorner.topLeft * 0.13357, y: last.y - newCorner.topLeft * 0.77037)
        curve(to: NSPoint(x: last.x + newCorner.topLeft * 0.37801, y: last.y - newCorner.topLeft * 0.37801),
              controlPoint1: NSPoint(x: last.x + newCorner.topLeft * 0.08715, y: last.y - newCorner.topLeft * 0.16296),
              controlPoint2: NSPoint(x: last.x + newCorner.topLeft * 0.21505, y: last.y - newCorner.topLeft * 0.290086))
        
        // top left c3
        last = NSPoint(x: last.x + newCorner.topLeft * 0.37801, y: last.y - newCorner.topLeft * 0.37801)
        curve(to: NSPoint(x: last.x + newCorner.topLeft * 0.77037, y: last.y - newCorner.topLeft * 0.13357),
              controlPoint1: NSPoint(x: last.x + newCorner.topLeft * 0.16296, y: last.y - newCorner.topLeft * 0.08715),
              controlPoint2: NSPoint(x: last.x + newCorner.topLeft * 0.32461, y: last.y - newCorner.topLeft * 0.13357))
        
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
    
    private func adjust(mask corner: NSViewMaskCorner, with rect: NSRect) -> NSViewMaskCorner {
        let w = CGFloat(rect.width)
        let h = CGFloat(rect.height)
        
        let topLeft = corner.topLeft * coeff
        let topRight = corner.topRight * coeff
        let bottomRight = corner.bottomRight * coeff
        let bottomLeft = corner.bottomLeft * coeff
        
        var shorter: CGFloat = 0
        var x: CGFloat = 0
        var newCorner = NSViewMaskCorner()
        
        // 右上
        shorter = min(w, h)
        x = topRight > shorter ? shorter : topRight
        newCorner.topRight = x / coeff
        
        // 右下
        shorter = min(w, h - x)
        x = bottomRight > shorter ? shorter : bottomRight
        newCorner.bottomRight = x / coeff
        
        // 左下
        shorter = min(w - x, h)
        x = bottomLeft > shorter ? shorter : bottomLeft
        newCorner.bottomLeft = x / coeff
        
        // 左上
        shorter = min(w - newCorner.topRight * coeff, h - x)
        x = topLeft > shorter ? shorter : topLeft
        newCorner.topLeft = x / coeff
        
        return newCorner
    }
}
