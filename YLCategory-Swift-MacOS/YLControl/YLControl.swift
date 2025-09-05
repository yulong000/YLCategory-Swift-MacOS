//
//  YLControl.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation
import AppKit

open class YLControl: NSControl {
    
    // 自定义NSControl时，为了响应点击事件，需要实现下面的方法
    
    open override func mouseDown(with event: NSEvent) {
        if isEnabled {
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }
    
    open override func mouseUp(with event: NSEvent) {
        if isEnabled, let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }
        super.mouseUp(with: event)
    }
    
    open override var acceptsFirstResponder: Bool { true }
    open override func becomeFirstResponder() -> Bool { true }
    open override var isFlipped: Bool { true }
    
    // MARK: - 设置平滑圆角
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawSmoothCorner()
    }
}
