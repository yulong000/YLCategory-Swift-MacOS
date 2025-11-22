//
//  Event.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit
import Carbon

/// 模拟键盘按下&抬起
public func Press(key: CGKeyCode, flags: CGEventFlags? = nil) {
    var modiferFlags = flags ?? []
    // 上下左右键，在某些环境中，需要添加Fn才能被识别为物理按键
    if key == kVK_LeftArrow || key == kVK_RightArrow || key == kVK_UpArrow || key == kVK_DownArrow {
        if !modiferFlags.contains(.maskSecondaryFn) {
            modiferFlags.insert(.maskSecondaryFn)
        }
    }
    if let down = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true) {
        down.flags = modiferFlags
        down.post(tap: .cgSessionEventTap)
    }
    
    if let up = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false) {
        up.flags = modiferFlags
        up.post(tap: .cgSessionEventTap)
    }
}
