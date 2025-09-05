//
//  NSControl+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

fileprivate var NSControlClickedHandlerKey = false
fileprivate var IgnoresMouseEventsKey: Bool = false

fileprivate var SmoothCornerMaskLayerKey: UInt8 = 0
fileprivate var SmoothCornerMaskCornerKey: UInt8 = 0
fileprivate var SmoothCornerBorderColor: UInt8 = 0
fileprivate var SmoothCornerBorderWidth: UInt8 = 0

extension NSControl {
    
    // MARK: - 点击回调
    public var clickedHandler: ((NSControl) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &NSControlClickedHandlerKey) as? ((NSControl) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &NSControlClickedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            target = self
            action = #selector(controlClicked)
        }
    }
    
    @objc private func controlClicked() {
        clickedHandler?(self)
    }
    
    // MARK: - 忽略鼠标点击事件
    @IBInspectable
    open var ignoresMouseEvents: Bool {
        get { return objc_getAssociatedObject(self, &IgnoresMouseEventsKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &IgnoresMouseEventsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    open override func hitTest(_ point: NSPoint) -> NSView? {
        if ignoresMouseEvents {
            return nil
        }
        return super.hitTest(point)
    }
    
    // MARK: - 设置平滑圆角
    
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawSmoothCorner()
    }
}
