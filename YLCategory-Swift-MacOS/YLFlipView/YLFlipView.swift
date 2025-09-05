//
//  YLFlipView.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation
import AppKit

open class YLFlipView: NSView {
    
    public override var isFlipped: Bool { true }
    
    // MARK: - 设置tag
    
    private var _tag: Int = 0
    public override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
    
    // MARK: - 设置平滑圆角
 
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawSmoothCorner()
    }
}
