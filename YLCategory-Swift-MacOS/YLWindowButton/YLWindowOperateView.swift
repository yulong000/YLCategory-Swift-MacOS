//
//  YLWindowOperateView.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/27.
//

import Foundation
import AppKit

open class YLWindowOperateView: NSView {
    
    // 点击按钮回调
    open var operateHandler: ((YLWindowButtonType) -> Void)?
    // 所有的按钮
    open var buttonTypes: [YLWindowButtonType]? {
        didSet {
            addBtns()
        }
    }
    // 获取对应类型的按钮
    open func button(withType buttonType: YLWindowButtonType) -> YLWindowButton? {
        subviews.compactMap { $0 as? YLWindowButton }.first { $0.buttonType == buttonType }
    }
    
    // MARK: - 构造方法
    
    convenience public init(buttonTypes: [YLWindowButtonType]) {
        self.init()
        self.buttonTypes = buttonTypes
        addBtns()
    }
    
    private func addBtns() {
        subviews.forEach { $0.removeFromSuperview() }
        guard let buttonTypes = buttonTypes else { return }
        for type in buttonTypes {
            if type == .exitFullScreen { continue }
            let btn = YLWindowButton(buttonType: type)
            btn.ignoreMouseHover = true
            btn.target = self
            btn.action = #selector(opreateButtonClicked(_:))
            addSubview(btn)
        }
        var frame = self.frame
        frame.size.width = CGFloat(buttonTypes.count) * (buttonWH + 7.5) - 7.5
        frame.size.height = 15
        self.frame = frame
    }
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if let window = window, window.styleMask.contains(.fullScreen) {
                // 窗口是全屏模式,需要将全屏按钮改为退出全屏按钮
                guard let fullScreenBtn = button(withType: .fullScreen) else  { return }
                fullScreenBtn.buttonType = .exitFullScreen
            }
        }
    }
    
    open override var isFlipped: Bool { true }
    
    private let buttonWH = 13.0
    open override func layout() {
        super.layout()
        var left = 0.0
        let height = bounds.size.height
        var buttonFrame = NSMakeRect(0, (height - buttonWH) / 2, buttonWH, buttonWH)
        for subview in subviews where subview.isKind(of: YLWindowButton.self) {
            buttonFrame.origin.x = left
            subview.frame = buttonFrame
            left = buttonFrame.maxX + 7.5
        }
    }
    
    // MARK: - 点击
    
    @objc private func opreateButtonClicked(_ btn: YLWindowButton) {
        switch btn.buttonType {
        case .close:
            window?.performClose(btn)
        case .mini:
            window?.performMiniaturize(btn)
        case .fullScreen:
            window?.toggleFullScreen(btn)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                btn.buttonType = .exitFullScreen
            }
        case .exitFullScreen:
            window?.toggleFullScreen(btn)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                btn.buttonType = .fullScreen
            }
        }
        for btn in subviews where btn.isKind(of: YLWindowButton.self) {
            (btn as! YLWindowButton).isHover = false
        }
        operateHandler?(btn.buttonType)
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self)
        addTrackingArea(trackingArea)
    }
    
    open override func mouseEntered(with event: NSEvent) {
        for btn in subviews where btn.isKind(of: YLWindowButton.self) {
            (btn as! YLWindowButton).isHover = true
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        for btn in subviews where btn.isKind(of: YLWindowButton.self) {
            (btn as! YLWindowButton).isHover = false
        }
    }
}
