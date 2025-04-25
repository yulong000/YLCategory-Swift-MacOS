//
//  NSScreen+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSScreen {
    /// x值
    var x: CGFloat { frame.origin.x }
    /// y值
    var y: CGFloat { frame.origin.y }
    /// 宽度
    var width: CGFloat { frame.size.width }
    /// 高度
    var height: CGFloat { frame.size.height }
    /// 大小
    var size: NSSize { frame.size }
    /// 坐标原点
    var origin: NSPoint { frame.origin }
    /// 中心点
    var center: NSPoint { NSMakePoint(centerX, centerY) }
    /// 中心点 x 值
    var centerX: CGFloat { NSMidX(frame) }
    /// 中心点 y 值
    var centerY: CGFloat { NSMidY(frame) }
    /// 最大 x 值
    var maxX: CGFloat { NSMaxX(frame) }
    /// 最大 y 值
    var maxY: CGFloat { NSMaxY(frame) }
    /// 是否是 main screen
    var isMain: Bool { self == NSScreen.main }
    /// 是否是内置屏
    var isBuiltin: Bool {
        guard let displayID = displayID else { return false }
        return CGDisplayIsBuiltin(displayID) != 0
    }
    /// 显示器ID
    var displayID: CGDirectDisplayID? { deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID }
    /// 获取内置屏
    class var builtinScreen: NSScreen? {
        for screen in NSScreen.screens where screen.isBuiltin {
            return screen
        }
        return nil
    }
}
