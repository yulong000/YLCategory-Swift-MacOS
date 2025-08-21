//
//  NSView+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/21.
//

import Foundation
import AppKit

public extension NSView {
    
    // MARK: 设置背景色
    var backgroundColor: NSColor? {
        get {
            guard let cgColor = layer?.backgroundColor else { return nil}
            return NSColor(cgColor: cgColor)
        }
        set {
            if let bgColor = newValue {
                wantsLayer = true
                layer?.backgroundColor = bgColor.cgColor
            } else {
                wantsLayer = false
                layer?.backgroundColor = nil
            }
        }
    }
    
    // MARK: - 移除所有子控件
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: 移除某一类子控件
    func removeSubviews(ofClass classRemove: AnyClass?) {
        guard let classRemove = classRemove else { return }
        for subview in subviews where subview.isKind(of: classRemove) {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: 添加一组子控件
    func addSubviews(from array: [NSView]) {
        array.forEach { addSubview($0) }
    }
    
    // MARK: - 监听鼠标的划入｜划出
    
    @discardableResult
    func addMouseTrackingArea(rect: NSRect, owner: AnyObject) -> NSTrackingArea {
        let trackingArea = NSTrackingArea(rect: rect, options: [.activeAlways, .mouseEnteredAndExited], owner: owner)
        addTrackingArea(trackingArea)
        return trackingArea
    }
    
    // MARK: 监听鼠标的划入｜划出整个区域
    @discardableResult
    func addMouseTracking() -> NSTrackingArea {
        return addMouseTrackingArea(rect: bounds, owner: self)
    }
    
    // MARK: 移除所有的跟踪区域
    func removeAllTrackingAreas() {
        trackingAreas.forEach { removeTrackingArea($0) }
    }
    
    // MARK: - 设置边框
    func setBorder(color: NSColor, width: CGFloat) {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
    }
    
    // MARK: 设置边框颜色
    func setBorderColor(_ borderColor: NSColor) {
        wantsLayer = true
        layer?.borderColor = borderColor.cgColor
    }
    
    // MARK: 设置边框宽度
    func setBorderWidth(_ borderWidth: CGFloat) {
        wantsLayer = true
        layer?.borderWidth = borderWidth
    }
    
    // MARK: 设置圆角
    func setCornerRadius(_ cornerRadius: CGFloat) {
        clipsToBounds = true
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = cornerRadius
    }
    
    // MARK: 设置边框和圆角
    func setBorder(color: NSColor, width: CGFloat, cornerRadius: CGFloat) {
        setBorder(color: color, width: width)
        setCornerRadius(cornerRadius)
    }
    
    // MARK: 设置指定位置的圆角
    func setCornerRadius(_ cornerRadius: CGFloat, mask: CACornerMask) {
        clipsToBounds = true
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.maskedCorners = mask
        layer?.cornerRadius = cornerRadius
    }
    
    // MARK: - 截图
    var thumbImage: NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil}
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
    
    // MARK: - 获取视图控制器
    var vc: NSViewController? { window?.contentViewController }
    
    // MARK: 获取窗口控制器
    var wc: NSWindowController? { window?.windowController }
    
    // MARK: 获取所在屏幕
    var screen: NSScreen? { window?.screen }
    
    // MARK: - 创建制定背景色的视图
    class func view(withColor backgroundColor: NSColor) -> Self {
        let view = Self.init()
        view.wantsLayer = true
        view.layer?.backgroundColor = backgroundColor.cgColor
        return view
    }
}
