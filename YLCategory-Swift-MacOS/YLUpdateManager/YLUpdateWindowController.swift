//
//  YLUpdateWindowController.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import Foundation

class YLUpdateWindowController: NSWindowController {
    
    var vc = YLUpdateViewController()
    
    override init(window: NSWindow?) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 300), styleMask: [.titled, .fullSizeContentView, .miniaturizable, .closable], backing: .buffered, defer: true)
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isOpaque = false
        window.isMovableByWindowBackground = true
        window.contentViewController = vc
        super.init(window: window)
        window.center()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 显示新版本
    func showNew(version: String, info: String) {
        window?.title = YLUpdateManager.localize("New version found") + ": " + version
        vc.info = info
    }
}
