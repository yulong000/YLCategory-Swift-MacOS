//
//  NSControl+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation

fileprivate var NSControlClickedHandlerKey = false

public extension NSControl {
    // MARK: 点击回调
    var clickedHandler: ((NSControl) -> Void)? {
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
}
