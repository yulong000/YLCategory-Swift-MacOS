//
//  CoordinateSystem.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// 将屏幕坐标系上的点(左上角为(0,0), 向下为正）,转换为视图坐标系上的点（左下角为(0,0), 向上为正）
public func ConvertToBottomLeftCoordinateSystem(_ topLeftCoordinateSystemPoint: NSPoint) -> NSPoint {
    var coordinatedH = 0.0
    for screen in NSScreen.screens {
        if CGPointEqualToPoint(screen.frame.origin, .zero) {
            coordinatedH = screen.frame.size.height
            break
        }
    }
    return NSPoint(x: topLeftCoordinateSystemPoint.x, y: coordinatedH - topLeftCoordinateSystemPoint.y)
}

/// 将屏幕坐标系上的rect(左上角为(0,0), 向下为正）,转换为视图坐标系上的点（左下角为(0,0), 向上为正）
public func ConvertToBottomLeftCoordinateSystem(_ topLeftCoordinateSystemRect: NSRect) -> NSRect {
    // 用主屏做参考（WindowServer 也是以主屏为基准）
    guard let mainScreen = NSScreen.main else {
        return topLeftCoordinateSystemRect
    }
    
    let flippedY = mainScreen.frame.maxY - topLeftCoordinateSystemRect.origin.y - topLeftCoordinateSystemRect.size.height
    return NSRect(
        x: topLeftCoordinateSystemRect.origin.x,
        y: flippedY,
        width: topLeftCoordinateSystemRect.size.width,
        height: topLeftCoordinateSystemRect.size.height
    )
}
