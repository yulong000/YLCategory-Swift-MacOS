//
//  YLPermissionWindowController.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation
import AppKit

class YLPermissionWindowController: NSWindowController {
    
    /// 点击关闭按钮回调
    var closeHandler: (() -> Void)?
    
    /// 控制器
    private(set) var permissionVc = YLPermissionViewController()
    
    override init(window: NSWindow?) {
        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .fullSizeContentView, .closable, .miniaturizable], backing: .buffered, defer: true)
        window.titlebarAppearsTransparent = true
        window.title = String(format: YLPermissionManager.localize("Permission Title"), YLPermissionManager.appName)
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isOpaque = false
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.contentViewController = permissionVc
        super.init(window: window)
        window.delegate = self
        window.center()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YLPermissionWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        closeHandler?()
    }
}
