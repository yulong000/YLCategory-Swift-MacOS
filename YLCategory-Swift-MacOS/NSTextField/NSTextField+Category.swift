//
//  NSTextField+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

fileprivate var IgnoresMouseEventsKey: Bool = false

extension NSTextField {
    
    // MARK: 固定最大宽度，高度自适应
    @discardableResult
    public func sizeWith(maxWidth: CGFloat) -> NSSize {
        let size = sizeThatFits(NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return size
    }
    
    // MARK: 固定最大宽度，高度自适应
    @discardableResult
    public func sizeToFit(maxWidth: CGFloat) -> Self {
        let size = sizeThatFits(NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return self
    }
    
    // MARK: 忽略鼠标点击事件
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
}
