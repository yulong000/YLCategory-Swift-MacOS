//
//  YLControl.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

open class YLControl: NSControl {
    
    // 自定义NSControl时，为了响应点击事件，需要实现下面的方法
    
    override public func mouseDown(with event: NSEvent) {
        if isEnabled {
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }
    
    override public func mouseUp(with event: NSEvent) {
        if isEnabled, let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }
        super.mouseUp(with: event)
    }
    
    public override var acceptsFirstResponder: Bool { true }
    public override func becomeFirstResponder() -> Bool { true }
    public override var isFlipped: Bool { true }
}
