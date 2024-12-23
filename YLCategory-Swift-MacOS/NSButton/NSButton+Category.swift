//
//  NSButton+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation

public extension NSButton {
    
    // MARK: 创建 图片+回调 按钮
    convenience init(image: NSImage, handler: ((NSControl) -> Void)?) {
        self.init(image: image, target: nil, action: nil)
        self.isBordered = false
        self.clickedHandler = handler
    }
    
    // MARK: 创建 标题+回调 按钮
    convenience init(title: String, handler: ((NSControl) -> Void)?) {
        self.init(title: title, target: nil, action: nil)
        self.isBordered = false
        self.clickedHandler = handler
    }
    
    // MARK: 创建 标题+图片+回调 按钮
    convenience init(title: String, image: NSImage, handler: ((NSControl) -> Void)?) {
        self.init(title: title, image: image, target: nil, action: nil)
        self.isBordered = false
        self.clickedHandler = handler
    }
    
    // MARK: 创建 富文本标题+回调 按钮
    convenience init(title: String, font: NSFont?, titleColor: NSColor?, handler: ((NSControl) -> Void)?) {
        self.init(image: nil, imagePosition: .noImage, title: title, titleColor: titleColor, font: font, handler: handler)
    }
    
    // MARK: 创建 图片+富文本标题+回调 按钮
    convenience init(image: NSImage?,
                     imagePosition: NSButton.ImagePosition,
                     title: String?,
                     titleColor: NSColor?,
                     font: NSFont?,
                     handler: ((NSControl) -> Void)?) {
        self.init()
        self.isBordered = false
        if let title = title {
            var params: [NSAttributedString.Key : Any] = [:]
            if let font = font {
                params[NSAttributedString.Key.font] = font
            }
            if let titleColor = titleColor {
                params[NSAttributedString.Key.foregroundColor] = titleColor
            }
            if params.keys.count > 0 {
                self.attributedTitle = NSAttributedString(string: title, attributes: params)
            } else {
                self.title = title
            }
        }
        if let image = image {
            self.image = image
            self.imageScaling = .scaleProportionallyUpOrDown
            self.imagePosition = imagePosition
        }
        self.clickedHandler = handler
    }
}
