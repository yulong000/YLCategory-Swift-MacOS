//
//  YLTipButton.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/12/20.
//

import AppKit

open class YLTipButton: NSButton {
    
    /// 全局控制，是否显示提示信息
    public static var showTip: Bool = true
    /// 单独控制，是否显示提示信息
    open var isShowTip: Bool?
    
    /// 提示信息
    private var tip: String?
    private var alternateTip: String?
    /// 是否调整 state == .on时的图片
    private var adjustAlternateImage: Bool = true
    /// 显示信息的窗口
    private var tipWindow: YLTipWindow?
    
    /// 创建一个只有图片和提示信息的button，鼠标滑入，立即显示；鼠标滑出，立即消失
    /// - Parameters:
    ///   - image: 图片
    ///   - tooltip: 提示信息
    ///   - alternateImage: state == .on时的图片
    ///   - alternateTooltip: state == .on时的提示信息
    public convenience init(image: NSImage, tooltip: String?, alternateImage: NSImage? = nil, alternateTooltip: String? = nil, adjustAlternateImage: Bool = true) {
        self.init()
        contentTintColor = .secondaryLabelColor
        self.image = image
        self.alternateImage = alternateImage
        self.imageScaling = .scaleProportionallyUpOrDown
        self.isBordered = false
        self.tip = tooltip
        self.alternateTip = alternateTooltip
        self.adjustAlternateImage = adjustAlternateImage
        if alternateImage != nil || alternateTooltip != nil {
            setButtonType(.toggle)
            state = .off
        } else {
            setButtonType(.momentaryPushIn)
        }
    }
    
    deinit { hideTip() }
    
    // MARK: - 显示｜隐藏 tip
    
    // MARK: 需要显示的tip
    private var currentTip: String? {
        let isOn = state == .on && (alternateImage != nil || alternateTip != nil)
        return isOn ? alternateTip : tip
    }
    
    // MARK: 显示tip
    private func showTip() {
        contentTintColor = adjustAlternateImage ? .controlAccentColor : nil
        let show = isShowTip ?? YLTipButton.showTip
        guard show, let tipStr = currentTip else { return }
        if tipWindow == nil {
            tipWindow = YLTipWindow()
            tipWindow?.tip = tipStr
        }
        tipWindow?.showWith(self)
    }
    
    // MARK: 隐藏tip
    private func hideTip() {
        contentTintColor = adjustAlternateImage ? .secondaryLabelColor : nil
        tipWindow?.hide()
        tipWindow = nil
    }
    
    // MARK: -
    
    open override var isHidden: Bool { didSet { hideTip() } }
    open override var state: NSControl.StateValue {
        didSet {
            if let tipWindow = tipWindow {
                tipWindow.tip = currentTip ?? ""
            }
            contentTintColor =  adjustAlternateImage ? .controlAccentColor : nil
        }
    }
    
    open override var acceptsFirstResponder: Bool { true }
    open override func becomeFirstResponder() -> Bool {
        showTip()
        return super.becomeFirstResponder()
    }
    open override func resignFirstResponder() -> Bool {
        hideTip()
        return super.resignFirstResponder()
    }
    
    open override func accessibilityLabel() -> String? { currentTip }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        hideTip()
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self)
        addTrackingArea(trackingArea)
        hideTip()
    }
    
    open override func mouseEntered(with event: NSEvent) { showTip() }
    open override func mouseExited(with event: NSEvent) { hideTip() }
    open override func mouseCancelled(with event: NSEvent) { hideTip() }
}

fileprivate class YLTipWindow: NSWindow {
    
    /// 提示信息
    var tip: String = "" {
        didSet {
            titleLabel.stringValue = tip
            titleLabel.sizeToFit()
            effectView.frame = NSMakeRect(0, 0, titleLabel.frame.size.width + 6, titleLabel.frame.size.height + 6)
            titleLabel.setFrameOrigin(NSMakePoint(3, 3))
            setContentSize(effectView.frame.size)
        }
    }
    
    // MARK: - initialize
    
    init() {
        super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        isReleasedWhenClosed = false
        ignoresMouseEvents = true
        contentView = effectView
    }
    
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    
    // MARK: - functions
    
    func showWith(_ fromView: NSView) {
        guard let window = fromView.window, let screen = window.screen else { return }
        let rect = fromView.convert(fromView.bounds, to: window.contentView)
        let x = window.convertPoint(fromScreen: NSEvent.mouseLocation).x
        let y = rect.maxY + frame.size.height + 8
        var p = NSMakePoint(x, y)
        p = window.contentView?.convert(p, from: nil) ?? p
        p.x += window.frame.origin.x
        p.y += window.frame.origin.y
        p.x = min(p.x, screen.frame.maxX - 5 - frame.size.width)
        p.x = max(5 + screen.frame.minX, p.x)
        setFrameOrigin(p)
        window.addChildWindow(self, ordered: .above)
    }
    
    func hide() {
        parent?.removeChildWindow(self)
        close()
    }
    
    // MARK: - UI
    
    lazy var titleLabel: NSTextField = {
        let title = NSTextField(labelWithString: "")
        title.font = NSFont.systemFont(ofSize: 11)
        title.alignment = .center
        return title
    }()
    
    lazy var effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        effectView.material = .toolTip
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.masksToBounds = true
        effectView.layer?.cornerRadius = 2
        effectView.layer?.borderColor = NSColor.systemGray.cgColor
        effectView.layer?.borderWidth = 1
        effectView.addSubview(titleLabel)
        return effectView
    }()
}

