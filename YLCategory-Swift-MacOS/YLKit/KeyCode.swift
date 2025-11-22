//
//  KeyCode.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit
import Carbon

// MARK: - 修饰键判断的相关方法

/// 修饰键掩码
public let MODIFIER_MASK: NSEvent.ModifierFlags = [.shift, .control, .option, .command]

/// 判断是否是快捷键的修饰键
public func isModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    let allowedCombinations: [NSEvent.ModifierFlags] = [
        .shift,
        .option,
        .command,
        .control,
        [.shift, .control],
        [.shift, .control, .option],
        [.shift, .control, .option, .command],
        [.shift, .control, .command],
        [.shift, .option],
        [.shift, .option, .command],
        [.shift, .command],
        [.control, .option],
        [.control, .option, .command],
        [.control, .command],
        [.option, .command],
    ]
    for combo in allowedCombinations {
        if ModifierFlagsEqual(flags, combo) {
            return true
        }
    }
    return false
}

/// 是否是Contorl修饰键
public func IsControlModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.control.rawValue
}

/// 是否是Shift修饰键
public func IsShiftModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.shift.rawValue
}

/// 是否是Command修饰键
public func IsCommandModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.command.rawValue
}

/// 是否是Option修饰键
public func IsOptionModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.option.rawValue
}

/// 2个修饰键是否相同
public func ModifierFlagsEqual(_ flags: NSEvent.ModifierFlags, _ anotherFlags: NSEvent.ModifierFlags) -> Bool {
    (MODIFIER_MASK.rawValue & flags.rawValue) != 0 &&
    (MODIFIER_MASK.rawValue & anotherFlags.rawValue) != 0 &&
    (MODIFIER_MASK.rawValue & flags.rawValue) == (MODIFIER_MASK.rawValue & anotherFlags.rawValue)
}

/// 一个修饰键是否包含另一个修饰键
public func ModifierFlagsContain(_ flags: NSEvent.ModifierFlags, _ containedFlags: NSEvent.ModifierFlags) -> Bool {
    flags.rawValue & containedFlags.rawValue == containedFlags.rawValue
}


// MARK: - 修饰键根据按键值判断

public func IsControlKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Control || keyCode == kVK_RightControl }
public func IsShiftKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Shift || keyCode == kVK_RightShift }
public func IsCommandKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Command || keyCode == kVK_RightCommand }
public func IsOptionKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Option || keyCode == kVK_RightOption }

// MARK: - CGEventFlags 和 NSEventModifierFlags 转换

/// 将 CGEventFlags 转成 NSEventModifierFlags
public func NSEventModifierFlagsFromCGEventFlags(_ cgFlags: CGEventFlags) -> NSEvent.ModifierFlags {
    var nsFlags: NSEvent.ModifierFlags = []
    if cgFlags.contains(.maskShift) {
        nsFlags.insert(.shift)
    }
    if cgFlags.contains(.maskControl) {
        nsFlags.insert(.control)
    }
    if cgFlags.contains(.maskAlternate) {
        nsFlags.insert(.option)
    }
    if cgFlags.contains(.maskCommand) {
        nsFlags.insert(.command)
    }
    return nsFlags
}

/// 比较 CGEventFlags 和 NSEventModifierFlags 是否相同
public func CGEventFlagsEqualToModifierFlags(_ cgFlags: CGEventFlags, _ nsFlags: NSEvent.ModifierFlags) -> Bool { NSEventModifierFlagsFromCGEventFlags(cgFlags) == nsFlags }

/// 事件的修饰键 == nsFlags
public func CGEventMatchesModifierFlags(_ event: CGEvent, _ nsFlags: NSEvent.ModifierFlags) -> Bool { CGEventFlagsEqualToModifierFlags(event.flags, nsFlags) }
