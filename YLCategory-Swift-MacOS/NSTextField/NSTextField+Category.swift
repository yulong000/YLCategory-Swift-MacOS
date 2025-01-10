//
//  NSTextField+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSTextField {
    
    // MARK: 固定最大宽度，高度自适应
    @discardableResult
    func sizeWith(maxWidth: CGFloat) -> NSSize {
        let size = sizeThatFits(NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return size
    }
}
