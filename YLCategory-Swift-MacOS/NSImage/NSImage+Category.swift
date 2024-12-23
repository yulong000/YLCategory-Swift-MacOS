//
//  NSImage+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation

public extension NSImage {
    
    // MARK: 更改图片的颜色
    func render(color: NSColor) -> NSImage? {
        guard let img = copy() as? NSImage else { return nil }
        img.lockFocus()
        color.setFill()
        let rect = NSRect(origin: .zero, size: size)
        rect.fill(using: .sourceAtop)
        img.unlockFocus()
        return img
    }
    
    // MARK: 更改图片的大小
    func resize(_ size: NSSize) -> NSImage {
        let originSize = self.size
        if originSize.width == 0 || originSize.height == 0 || size.width == 0 || size.height == 0 {
            return NSImage(size: size)
        }
        let factor = NSScreen.main?.backingScaleFactor ?? 1.0
        let rect = NSRect(x: 0, y: 0, width: size.width * factor, height: size.height * factor)
        guard let tiffData = tiffRepresentation,
              let source = CGImageSourceCreateWithData(tiffData as CFData, nil),
              let imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return NSImage(size: size)
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                      width: Int(rect.width),
                                      height: Int(rect.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else { return NSImage(size: size) }
        context.draw(imageRef, in: rect)
        guard let cgImage = context.makeImage() else { return NSImage(size: size) }
        return NSImage(cgImage: cgImage, size: size)
    }
}
