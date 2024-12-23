//
//  NSTextField+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation

public extension NSTextField {
    
    // MARK: 固定最大宽度，高度自适应
    @discardableResult
    func sizeWith(maxWidth: CGFloat) -> NSSize {
        let size = sizeThatFits(NSMakeSize(width, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return size
    }
}
