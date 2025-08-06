//
//  YLWindowButton.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/27.
//

import Foundation
import AppKit

@objc public enum YLWindowButtonType: UInt8 {
    case close
    case mini
    case fullScreen
    case exitFullScreen
}

open class YLWindowButton: NSControl {
    
    // 按钮类型
    open var buttonType: YLWindowButtonType = .close {
        didSet {
            isHover = false
            needsDisplay = true
        }
    }
    // 忽略鼠标划入
    open var ignoreMouseHover: Bool = false { didSet { updateTrackingAreas() } }
    // 是否是激活状态
    open var isActive: Bool = false { didSet { needsDisplay = true } }
    // 是否选中
    open var isHover: Bool = false { didSet { needsDisplay = true } }
    // 窗口全屏
    private(set) var isWindowFullScreen: Bool = false { didSet { needsDisplay = true } }
    
    
    // MARK: - 初始化
    
    convenience public init(buttonType: YLWindowButtonType) {
        self.init(frame: .zero)
        self.buttonType = buttonType
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        trackingAreas.forEach { removeTrackingArea($0) }
    }
    
    // MARK: - 通知
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(self)
        guard let window = window else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeActive), name: NSWindow.didBecomeKeyNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignActive), name: NSWindow.didResignKeyNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidFullScreen), name: NSWindow.didEnterFullScreenNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: window)
    }
    
    @objc private func windowDidBecomeActive(_ notification: Notification) {
        isActive = true
    }
    @objc private func windowDidResignActive(_ notification: Notification) {
        isActive = false
    }
    @objc private func windowDidFullScreen(_ notification: Notification) {
        isWindowFullScreen = true
        if buttonType == .mini {
            isEnabled = false
        }
    }
    @objc private func windowDidExitFullScreen(_ notification: Notification) {
        isWindowFullScreen = false
        if buttonType == .mini {
            isEnabled = true
        }
    }
    
    // MARK: - Mouse Tracking
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        guard !ignoreMouseHover else { return }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self)
        addTrackingArea(trackingArea)
    }
    
    open override func mouseDown(with event: NSEvent) {
        if isEnabled {
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }
    open override func mouseUp(with event: NSEvent) {
        if isEnabled, let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }
        super.mouseUp(with: event)
    }
    
    open override func mouseEntered(with event: NSEvent) {
        if let superView = superview, superView.isKind(of: YLWindowOperateView.self) {
            super.mouseEntered(with: event)
        } else {
            isHover = true
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        if let superView = superview, superView.isKind(of: YLWindowOperateView.self) {
            super.mouseExited(with: event)
        } else {
            isHover = false
        }
    }
    
    open override var acceptsFirstResponder: Bool { true }
    open override func becomeFirstResponder() -> Bool { true }
    
    
    // MARK: - 绘制内容
    
    private var RGBA:(CGFloat, CGFloat, CGFloat, CGFloat) -> NSColor  = { r, g, b, a in
        NSColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        var bgGradient: NSGradient?
        var strokeColor: NSColor?
        var symbolColor: NSColor?
        
        switch buttonType {
        case .close:
            bgGradient = NSGradient(starting: RGBA(255, 95, 86, 1), ending: RGBA(255, 99, 91, 1))
            strokeColor = RGBA(226, 62, 55, 1)
            symbolColor = RGBA(77, 0, 0, 1)
            
        case .mini:
            bgGradient = NSGradient(starting: RGBA(255, 189, 46, 1), ending: RGBA(255, 197, 47, 1))
            strokeColor = RGBA(223, 157, 24, 1)
            symbolColor = RGBA(153, 88, 1, 1)
            
        case .fullScreen, .exitFullScreen:
            bgGradient = NSGradient(starting: RGBA(39, 201, 63, 1), ending: RGBA(39, 208, 65, 1))
            strokeColor = RGBA(46, 176, 60, 1)
            symbolColor = RGBA(1, 100, 0, 1)
        }
        
        if !isActive && !isHover {
            bgGradient = NSGradient(starting: RGBA(79, 83, 79, 1), ending: RGBA(75, 79, 75, 1))
            strokeColor = RGBA(65, 65, 65, 1)
        }
        
        if buttonType == .mini && isWindowFullScreen {
            bgGradient = NSGradient(starting: RGBA(94, 98, 94, 1), ending: RGBA(90, 94, 90, 1))
            strokeColor = RGBA(80, 80, 80, 1)
        }
        
        let path = NSBezierPath()
        path.appendOval(in: NSRect(x: 0.5, y: 0.5, width: width - 1, height: height - 1))
        bgGradient?.draw(in: path, relativeCenterPosition: .zero)
        strokeColor?.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        
        if buttonType == .mini && isWindowFullScreen {
            return
        }
        
        if isHover {
            switch buttonType {
            case .close:
                let path = NSBezierPath()
                path.move(to: NSPoint(x: width * 0.3, y: height * 0.3))
                path.line(to: NSPoint(x: width * 0.7, y: height * 0.7))
                path.move(to: NSPoint(x: width * 0.7, y: height * 0.3))
                path.line(to: NSPoint(x: width * 0.3, y: height * 0.7))
                path.lineWidth = 1
                symbolColor?.setStroke()
                path.stroke()
                
            case .mini:
                NSGraphicsContext.current?.shouldAntialias = false
                let path = NSBezierPath()
                path.move(to: NSPoint(x: width * 0.2, y: height * 0.5))
                path.line(to: NSPoint(x: width * 0.8, y: height * 0.5))
                path.lineWidth = 2
                symbolColor?.setStroke()
                path.stroke()
                NSGraphicsContext.current?.shouldAntialias = true
                
            case .fullScreen:
                let path = NSBezierPath()
                path.move(to: NSPoint(x: width * 0.25, y: height * 0.75))
                path.line(to: NSPoint(x: width * 0.25, y: height / 3))
                path.line(to: NSPoint(x: width * 2 / 3, y: height * 0.75))
                path.close()
                symbolColor?.setFill()
                path.fill()
                
                path.move(to: NSPoint(x: width * 0.75, y: height * 0.25))
                path.line(to: NSPoint(x: width * 0.75, y: height * 2 / 3))
                path.line(to: NSPoint(x: width / 3, y: height * 0.25))
                path.close()
                symbolColor?.setFill()
                path.fill()
                
            case .exitFullScreen:
                let path = NSBezierPath()
                path.move(to: NSPoint(x: width * 0.1, y: height * 0.52))
                path.line(to: NSPoint(x: width * 0.48, y: height * 0.52))
                path.line(to: NSPoint(x: width * 0.48, y: height * 0.9))
                path.close()
                symbolColor?.setFill()
                path.fill()
                
                path.move(to: NSPoint(x: width * 0.9, y: height * 0.48))
                path.line(to: NSPoint(x: width * 0.52, y: height * 0.48))
                path.line(to: NSPoint(x: width * 0.52, y: height * 0.1))
                path.close()
                symbolColor?.setFill()
                path.fill()
            }
        }
    }
}
