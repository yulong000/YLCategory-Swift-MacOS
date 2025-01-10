//
//  NSWindow+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSWindow {
    static func clearBackground() -> NSWindow {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView, .miniaturizable, .closable],
            backing: .buffered,
            defer: true
        )
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isMovableByWindowBackground = true
        return window
    }
}
