//
//  NSColor+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSColor {
    
    // MARK: - 创建亮色｜暗色模式下的颜色
    convenience init(light: NSColor, dark: NSColor?) {
        if #available(macOS 10.15, *) {
            self.init(name: nil, dynamicProvider: { appearance in
                if appearance.bestMatch(from: [.darkAqua, .vibrantDark]) == .darkAqua ||
                    appearance.bestMatch(from: [.darkAqua, .vibrantDark]) == .vibrantDark {
                    return dark ?? light
                }
                return light
            })
        } else {
            self.init(cgColor: light.cgColor)!
        }
    }
    
    // MARK: 传入一个16进制字符串，创建一个color
    convenience init?(hexString: String) {
        // 去除 # 前缀并验证格式
        var hex = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString
        guard !hex.isEmpty, hex.range(of: "^[0-9a-fA-F]{3,8}$", options: .regularExpression) != nil else {
            assert(false, "Invalid hex string format")
            return nil
        }
        
        // 将 3、4 位扩展为 6、8 位
        if hex.count == 3 || hex.count == 4 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        
        // 提取 RGBA 分量
        let components = Array(hex)
        var r = "FF", g = "FF", b = "FF", a = "FF"
        
        switch components.count {
        case 6:
            r = String(components[0...1])
            g = String(components[2...3])
            b = String(components[4...5])
        case 8:
            r = String(components[0...1])
            g = String(components[2...3])
            b = String(components[4...5])
            a = String(components[6...7])
        default:
            assert(false, "Invalid hex string format")
            return nil
        }
        
        // 转换为浮点颜色值
        let red = CGFloat(Int(r, radix: 16) ?? 0) / 255.0
        let green = CGFloat(Int(g, radix: 16) ?? 0) / 255.0
        let blue = CGFloat(Int(b, radix: 16) ?? 0) / 255.0
        let alpha = CGFloat(Int(a, radix: 16) ?? 255) / 255.0
        
        // 使用便利构造函数初始化 NSColor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - 返回带有透明度的颜色
    var alpha: (CGFloat) -> NSColor { { alpha in self.withAlphaComponent(alpha) } }
    
    // MARK: - 获取十六进制字符串
    var hexString: String {
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        let a = Int(round(alphaComponent * 255))
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
    
    // MARK: 转成16进制字符串 #FFFFFFAA
    var hexStringWithAlpha: String {
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        let a = Int(round(alphaComponent * 255))
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
    
    // MARK: 转成16进制字符串 #FFFFFF
    var hexStringWithoutAlpha: String {
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
