//
//  YLScrollLabel.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/3/3.
//

import AppKit

class YLScrollLabel: NSView {
    
    /// 文本内容
    var stringValue: String? = "" {
        didSet {
            showLabel.stringValue = stringValue ?? ""
            scrollLabel.stringValue = stringValue ?? ""
            needsLayout = true
        }
    }
    /// 文字颜色
    var textColor: NSColor? {
        didSet {
            showLabel.textColor = textColor
            scrollLabel.textColor = textColor
        }
    }
    /// 显示模式
    var lineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            showLabel.lineBreakMode = lineBreakMode
        }
    }
    // 是否开启滚动
    var isScrollEnable = true
    // 点击回调
    var clickHandler: ((YLScrollLabel) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        addSubview(scrollView)
    }
    
    override func layout() {
        super.layout()
        scrollLabel.sizeToFit()
        showLabel.sizeToFit()
        let width = bounds.size.width
        let height = bounds.size.height
        let textWidth = scrollLabel.bounds.size.width
        let textHeight = scrollLabel.bounds.size.height
        
        scrollView.frame = NSRect(x: 0, y: (height - textHeight) / 2, width: width, height: textHeight)
        showLabel.frame = NSRect(x: 0, y: 0, width: width, height: showLabel.bounds.size.height)
        
        canScroll = textWidth > width
        
        // 监听鼠标划入｜划出
        addMouseTrackingArea()
    }
    
    // MARK: - 鼠标手势
    
    private var canScroll = false       // 是否可以滚动
    private var timer: Timer?           // 定时器
    private var reverseScroll = false   // 反方向滚动
    
    private func addMouseTrackingArea() {
        trackingAreas.forEach { removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self)
        addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        if !canScroll || !isScrollEnable { return }
        if timer == nil {
            scrollView.documentView = scrollLabel
            timer = Timer(timeInterval: 0.02, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .default)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        if !canScroll || !isScrollEnable { return }
        timer?.invalidate()
        timer = nil
        scrollView.documentView = showLabel
        scrollView.contentView.scroll(to: .zero)
        reverseScroll = false
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        clickHandler?(self)
    }
    
    @objc func autoScroll() {
        var visibleRect = scrollView.documentVisibleRect
        if reverseScroll {
            visibleRect.origin.x -= 1
        } else {
            visibleRect.origin.x += 1
        }
        if NSMaxX(visibleRect) >= scrollLabel.bounds.size.width {
            reverseScroll = true
            timer?.fireDate = Date(timeIntervalSinceNow: 0.5)
        } else if visibleRect.origin.x == 0 {
            reverseScroll = false
            timer?.fireDate = Date(timeIntervalSinceNow: 0.5)
        }
        scrollView.contentView.scroll(to: visibleRect.origin)
    }
    
    // MARK: - UI
    
    private lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = showLabel
        scrollView.drawsBackground = false
        return scrollView
    }()
    private lazy var scrollLabel: NSTextField = {
        let textLabel = NSTextField(labelWithString: "")
        return textLabel
    }()
    private lazy var showLabel: NSTextField = {
        let textLabel = NSTextField(labelWithString: "")
        textLabel.lineBreakMode = .byTruncatingMiddle
        return textLabel
    }()
}

fileprivate class ScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) { }
}

