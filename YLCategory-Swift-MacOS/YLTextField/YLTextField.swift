//
//  YLTextField.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Cocoa

open class YLTextField: NSTextField {
    
    // 是否支持换行
    open var lineFeed = false {
        didSet {
            cell?.isScrollable = !lineFeed
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = YLTextFieldCell()
        self.isEditable = true
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cell = YLTextFieldCell()
        self.isEditable = true
    }
}


fileprivate class YLTextFieldCell : NSTextFieldCell {
    override init(textCell string: String) {
        super.init(textCell: string)
        self.isScrollable = true
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.isScrollable = true
    }
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect = super.drawingRect(forBounds: rect)
        let size = self.cellSize(forBounds: rect)
        if newRect.height > size.height {
            newRect.size.height = size.height
            newRect.origin.y += (rect.height - size.height) / 2
        }
        return newRect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let newRect = self.isScrollable ? self.drawingRect(forBounds: rect) : rect
        super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let newRect = self.isScrollable ? self.drawingRect(forBounds: rect) : rect
        super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event: event)
    }
}
