//
//  NSImageView+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSImageView {
    // MARK: 图片按比例缩放，填充最短边，裁剪并显示中间部分
    func aspectFill() {
        guard let image = image else { return }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let width = frame.size.width
        let height = frame.size.height
        
        guard imageWidth > 0, imageHeight > 0, width > 0, height > 0 else { return }
        
        var rect = NSRect.zero
        
        if imageWidth / imageHeight > width / height {
            // 图片比较宽，需要左右裁切
            rect.size.height = imageHeight
            rect.size.width = width / height * imageHeight
        } else {
            // 上下裁切
            rect.size.width = imageWidth
            rect.size.height = height / width * imageWidth
        }
        
        rect.origin.x = (imageWidth - rect.size.width) / 2
        rect.origin.y = (imageHeight - rect.size.height) / 2
        
        let resultImage = NSImage(size: frame.size)
        
        DispatchQueue.global().async {
            resultImage.lockFocus()
            image.draw(in: NSRect(x: 0, y: 0, width: width, height: height), from: rect, operation: .copy, fraction: 1.0, respectFlipped: true, hints: nil)
            resultImage.unlockFocus()
            
            DispatchQueue.main.async {
                self.image = resultImage
            }
        }
    }
}
