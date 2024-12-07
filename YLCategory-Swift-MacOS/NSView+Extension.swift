//
//  Extension.swift
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2024/12/3.
//

import Cocoa

extension NSView {
    
    /// x值
    public var x: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    /// y值
    public var y: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    
    /// 宽度
    public var width: CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    
    /// 高度
    public var height: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    
    /// 大小
    public var size: NSSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    
    /// 坐标原点
    public var origin: NSPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin
        }
    }
    
    /// 中心点
    public var center: NSPoint {
        set {
            var frame = self.frame
            frame.origin = NSMakePoint(newValue.x - self.frame.size.width / 2, newValue.y - self.frame.size.height / 2)
            self.frame = frame
        }
        get {
            return NSMakePoint(NSMidX(self.frame), NSMidY(self.frame))
        }
    }
    
    /// 中心点 x 值
    public var centerX: CGFloat {
        set {
            let centerY = self.center.y;
            self.center = NSMakePoint(newValue, centerY)
        }
        get {
            return NSMidX(self.frame)
        }
    }
    
    /// 中心点 y 值
    public var centerY: CGFloat {
        set {
            let centerX = self.center.x;
            self.center = NSMakePoint(centerX, newValue)
        }
        get {
            return NSMidY(self.frame)
        }
    }
    
    /// 最大 x 值
    public var maxX: CGFloat {
        return NSMaxX(self.frame)
    }
    
    /// 最大 y 值
    public var maxY: CGFloat {
        return NSMaxY(self.frame)
    }
    
    /// 顶部
    public var top: CGFloat {
        set {
            self.y = newValue
        }
        get {
            return self.y
        }
    }
    
    /// 左侧
    public var left: CGFloat {
        set {
            self.x = newValue
        }
        get {
            return self.x
        }
    }
    
    /// 底部
    public var bottom: CGFloat {
        set {
            self.y = newValue - self.height
        }
        get {
            return self.y + self.height
        }
    }
    
    /// 右侧
    public var right: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.width
            self.frame = frame
        }
        get {
            return self.maxX
        }
    }
    
    /// 自己的中心点
    public var centerPoint: NSPoint {
        return NSMakePoint(self.width / 2, self.height / 2)
    }
    
    /// 设置x值
    @discardableResult
    public func x(is value: CGFloat) -> NSView {
        self.x = value
        return self
    }
    
    /// 设置y值
    @discardableResult
    public func y(is value: CGFloat) -> NSView {
        self.y = value
        return self
    }
    
    /// 设置宽度
    @discardableResult
    public func width(is value: CGFloat) -> NSView {
        self.width = value
        return self
    }
    
    /// 设置高度
    @discardableResult
    public func height(is value: CGFloat) -> NSView {
        self.height = value
        return self
    }
    
    /// 设置顶部位置
    @discardableResult
    public func top(is value: CGFloat) -> NSView {
        self.top = value
        return self
    }
    
    /// 设置左侧位置
    @discardableResult
    public func left(is value: CGFloat) -> NSView {
        self.left = value
        return self
    }
    
    /// 设置底部位置
    @discardableResult
    public func bottom(is value: CGFloat) -> NSView {
        self.bottom = value
        return self
    }
    
    /// 设置右侧位置
    @discardableResult
    public func right(is value: CGFloat) -> NSView {
        self.right = value
        return self
    }
    
    /// 设置中心位置x
    @discardableResult
    public func centerX(is value: CGFloat) -> NSView {
        self.centerX = value
        return self
    }
    
    /// 设置中心位置y
    @discardableResult
    public func centerY(is value: CGFloat) -> NSView {
        self.centerY = value
        return self
    }
    
    /// 设置origin
    @discardableResult
    public func origin(is x: CGFloat, _ y: CGFloat) -> NSView {
        self.origin = NSMakePoint(x, y)
        return self
    }
    
    /// 设置大小
    @discardableResult
    public func size(is width: CGFloat, _ height: CGFloat) -> NSView {
        self.size = NSMakeSize(width, height)
        return self
    }
    
    /// 设置中心位置
    @discardableResult
    public func center(is x: CGFloat, _ y: CGFloat) -> NSView {
        self.center = NSMakePoint(x, y)
        return self
    }
    
    /// 设置frame
    @discardableResult
    public func frame(is x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSView {
        self.frame = NSMakeRect(x, y, w, h)
        return self
    }
    
    /// 设置偏移量，x会增加
    @discardableResult
    public func offsetX(is value: CGFloat) -> NSView {
        self.x += value
        return self
    }
    
    /// 设置偏移量，y会增加
    @discardableResult
    public func offsetY(is value: CGFloat) -> NSView {
        self.y += value
        return self
    }
    
    /// 设置x等于另一个view
    @discardableResult
    public func x(equalTo view: NSView) -> NSView {
        self.x = view.x
        return self
    }
    
    /// 设置y等于另一个view
    @discardableResult
    public func y(equalTo view: NSView) -> NSView {
        self.y = view.y
        return self
    }
    
    /// 设置origin等于另一个view
    @discardableResult
    public func origin(equalTo view: NSView) -> NSView {
        self.origin = view.origin
        return self
    }
    
    /// 设置顶部等于另一个view
    @discardableResult
    public func top(equalTo view: NSView) -> NSView {
        self.top = view.top
        return self
    }
    
    /// 设置左侧等于另一个view
    @discardableResult
    public func left(equalTo view: NSView) -> NSView {
        self.left = view.left
        return self
    }
    
    /// 设置底部等于另一个view
    @discardableResult
    public func bottom(equalTo view: NSView) -> NSView {
        self.bottom = view.bottom
        return self
    }
    
    /// 设置右侧等于另一个view
    @discardableResult
    public func right(equalTo view: NSView) -> NSView {
        self.right = view.right
        return self
    }
    
    /// 设置宽度等于另一个view
    @discardableResult
    public func width(equalTo view: NSView) -> NSView {
        self.width = view.width
        return self
    }
    
    /// 设置高度等于另一个view
    @discardableResult
    public func height(equalTo view: NSView) -> NSView {
        self.height = view.height
        return self
    }
    
    /// 设置大小等于另一个view
    @discardableResult
    public func size(equalTo view: NSView) -> NSView {
        self.size = view.size
        return self
    }
    
    /// 设置中心位置x等于另一个view
    @discardableResult
    public func centerX(equalTo view: NSView) -> NSView {
        self.centerX = view.centerX
        return self
    }
    
    /// 设置中心位置y等于另一个view
    @discardableResult
    public func centerY(equalTo view: NSView) -> NSView {
        self.centerY = view.centerY
        return self
    }
    
    /// 设置中心位置等于另一个view
    @discardableResult
    public func center(equalTo view: NSView) -> NSView {
        self.center = view.center
        return self
    }
    
    /// 设置x等于另一个view的x，并增加偏移量
    @discardableResult
    public func x(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.x = view.x + offset
        return self
    }
    
    /// 设置y等于另一个view的y，并增加偏移量
    @discardableResult
    public func y(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.y = view.y + offset
        return self
    }
    
    /// 设置顶部对齐另一个view的顶部增加偏移量
    @discardableResult
    public func top(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.top = view.top + offset
        return self
    }
    
    /// 设置左侧对齐另一个view的左侧，并增加偏移量
    @discardableResult
    public func left(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.left = view.left + offset
        return self
    }
    
    /// 设置底部对齐另一个view的底部，并增加偏移量
    @discardableResult
    public func bottom(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.bottom = view.bottom + offset
        return self
    }
    
    /// 设置右侧对齐另一个view的右侧，并增加偏移量
    @discardableResult
    public func right(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.right = view.right + offset
        return self
    }
    
    /// 设置中心位置x对齐另一个view的中心位置x，并增加偏移量
    @discardableResult
    public func centerX(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.centerX = view.centerX + offset
        return self
    }
    
    /// 设置中心位置y对齐另一个view的中心位置y，并增加偏移量
    @discardableResult
    public func centerY(equalTo view: NSView, offset: CGFloat) -> NSView {
        self.centerY = view.centerY + offset
        return self
    }
    
    /// 设置右侧对齐父视图右侧
    @discardableResult
    public func rightEqualToSuper() -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.right = superview.width
        return self
    }
    
    /// 设置底部对齐父视图底部
    @discardableResult
    public func bottomEqualToSuper() -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.bottom = superview.height
        return self
    }
    
    /// 设置居中
    @discardableResult
    public func centerEqualToSuper() -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.center = superview.centerPoint
        return self
    }
    
    /// 设置水平居中
    @discardableResult
    public func centerXEqualToSuper() -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.centerX = superview.width / 2
        return self
    }
    
    /// 设置垂直居中
    @discardableResult
    public func centerYEqualToSuper() -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.centerY = superview.height / 2
        return self
    }
    
    /// 设置顶部与父视图底部的间距space
    @discardableResult
    public func top(spaceToSuper value: CGFloat) -> NSView {
        self.top = value
        return self
    }
    
    /// 设置左侧与父视图底部的间距space
    @discardableResult
    public func left(spaceToSuper value: CGFloat) -> NSView {
        self.x = value
        return self
    }
    
    /// 设置底部与父视图底部的间距space
    @discardableResult
    public func bottom(spaceToSuper value: CGFloat) -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.bottom = superview.height - value
        return self
    }
    
    /// 设置右侧与父视图右侧的间距space
    @discardableResult
    public func right(spaceToSuper value: CGFloat) -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        self.right = superview.width - value
        return self
    }
    
    /// 设置顶部与另一个view的底部的间距
    @discardableResult
    public func top(spaceTo view: NSView, _ value: CGFloat) -> NSView {
        self.top = view.bottom + value
        return self
    }
    
    /// 设置左侧与另一个view的右侧的间距
    @discardableResult
    public func left(spaceTo view: NSView, _ value: CGFloat) -> NSView {
        self.left = view.right + value
        return self
    }
    
    /// 设置底部与另一个view的顶部的间距
    @discardableResult
    public func bottom(spaceTo view: NSView, _ value: CGFloat) -> NSView {
        self.bottom = view.top - value
        return self
    }
    
    /// 设置右侧与另一个view的左侧的间距
    @discardableResult
    public func right(spaceTo view: NSView, _ value: CGFloat) -> NSView {
        self.right = view.left - value
        return self
    }
    
    /// 设置在父视图中上下左右的间距
    @discardableResult
    public func edgeToSuper(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> NSView {
        guard let superview = superview else {
            assert(false, "Superview must not be nil")
            return self
        }
        var frame = NSZeroRect
        frame.size = NSMakeSize(superview.width - left - right, superview.height - top - bottom)
        frame.origin.x = left
        frame.origin.y = top
        self.frame = frame
        return self
    }
}

