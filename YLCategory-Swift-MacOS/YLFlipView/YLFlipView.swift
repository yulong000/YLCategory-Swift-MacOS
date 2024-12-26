//
//  YLFlipView.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

class YLFlipView: NSView {
    
    override var isFlipped: Bool { true }
    
    private var _tag: Int = 0
    override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }
}
