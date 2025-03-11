//
//  Macro.swift
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2024/12/3.
//

// MARK: - 颜色

import Cocoa
import Carbon
import SystemConfiguration

// MARK: - 颜色

public let WhiteColor: NSColor = .white
public let BlackColor: NSColor = .black
public let ClearColor: NSColor = .clear
public let GrayColor: NSColor = .gray
public let DarkGrayColor: NSColor = .darkGray
public let LightGrayColor: NSColor = .lightGray
public let RedColor: NSColor = .red
public let GreenColor: NSColor = .green
public let OrangeColor: NSColor = .orange
public let YellowColor: NSColor = .yellow
public let BlueColor: NSColor = .blue
public let SystemBlueColor: NSColor = .systemBlue
public let ControlAccentColor: NSColor = .controlAccentColor
public var RandomColor: NSColor { NSColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0) }

public func RGBA(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: CGFloat) -> NSColor { NSColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a) }
public func RGB(_ rgb: UInt8) -> NSColor { NSColor(red: CGFloat(rgb) / 255.0, green: CGFloat(rgb) / 255.0, blue: CGFloat(rgb) / 255.0, alpha: 1) }
public func Hex(_ hexValue: UInt) -> NSColor {
    NSColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hexValue & 0x0000FF) / 255.0,
            alpha: 1.0)
}

public func BlackColorAlpha(_ a: CGFloat) -> NSColor { NSColor(white: 0, alpha: a) }
public func WhiteColorAlpha(_ a: CGFloat) -> NSColor { NSColor(white: 1, alpha: a) }
public func WhiteColor(_ white: CGFloat, alpha: CGFloat) -> NSColor { NSColor(white: white, alpha: alpha) }

// MARK: - 屏幕

public var kScreenScale: CGFloat { NSScreen.main?.backingScaleFactor ?? 0.0 }
public var kScreenWidth: CGFloat { NSScreen.main?.frame.size.width ?? 0.0 }
public var kScreenHeight: CGFloat { NSScreen.main?.frame.size.height ?? 0.0 }
public var kStatusBarHeight: CGFloat { NSApp.mainMenu?.menuBarHeight ?? 0.0 }

// MARK: - 字体

public func Font(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size) }
public func BoldFont(_ size: CGFloat) -> NSFont { .boldSystemFont(ofSize: size) }
public func MediumFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .medium) }
public func ThinFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .thin) }

// MARK: - app相关信息

// app是沙盒
public let kAppIsSanbox: Bool = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
// app是暗黑模式
public var kAppIsDarkTheme: Bool { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
// 系统是暗黑模式
public var kSystemIsDarkTheme: Bool {
    let info = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
    if let style = info?["AppleInterfaceStyle"] as? String {
        return style.caseInsensitiveCompare("dark") == .orderedSame
    }
    return false
}
// Document 路径
public var kDocumentPath: String { NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "" }
// Cache 路径
public var kCachePath: String { NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? "" }
// app内文件的路径
public func BundlePath(_ fileName: String) -> String? { Bundle.main.path(forResource: fileName, ofType: nil) }

// app版本号
public let kAPP_Version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
// app build number
public let kAPP_Build_Number: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
// app的本地化名字
public let kApp_Name: String = {
    let localizedInfo = Bundle.main.localizedInfoDictionary ?? [:]
    let info = Bundle.main.infoDictionary ?? [:]
    return  localizedInfo["CFBundleDisplayName"] as? String ??
            info["CFBundleDisplayName"] as? String ??
            localizedInfo["CFBundleName"] as? String ??
            info["CFBundleName"] as? String ?? ""
}()
// 当前app的bundle ID
public let kBundle_Id: String = Bundle.main.bundleIdentifier ?? ""
// 当前系统版本号
public let kSystem_OS_Version = {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}()
// 当前登录的用户名, 未登录用户时，返回nil
public let GUIUserName: String? = {
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, nil, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    return userName
}()

// MARK: - 修饰键判断的相关方法

// 修饰键掩码
public let MODIFIER_MASK: NSEvent.ModifierFlags = [.shift, .control, .option, .command]

// 判断是否是快捷键的修饰键
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

// 是否是Contorl修饰键
public func IsControlModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.control.rawValue
}

// 是否是Shift修饰键
public func IsShiftModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.shift.rawValue
}

// 是否是Command修饰键
public func IsCommandModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.command.rawValue
}

// 是否是Option修饰键
public func IsOptionModifierFlags(_ flags: NSEvent.ModifierFlags) -> Bool {
    MODIFIER_MASK.rawValue & flags.rawValue == NSEvent.ModifierFlags.option.rawValue
}

// 2个修饰键是否相同
public func ModifierFlagsEqual(_ flags: NSEvent.ModifierFlags, _ anotherFlags: NSEvent.ModifierFlags) -> Bool {
    (MODIFIER_MASK.rawValue & flags.rawValue) != 0 &&
    (MODIFIER_MASK.rawValue & anotherFlags.rawValue) != 0 &&
    (MODIFIER_MASK.rawValue & flags.rawValue) == (MODIFIER_MASK.rawValue & anotherFlags.rawValue)
}

// 一个修饰键是否包含另一个修饰键
public func ModifierFlagsContain(_ flags: NSEvent.ModifierFlags, _ containedFlags: NSEvent.ModifierFlags) -> Bool {
    flags.rawValue & containedFlags.rawValue == containedFlags.rawValue
}


// MARK: - 修饰键根据按键值判断

public func IsControlKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Control || keyCode == kVK_RightControl }
public func IsShiftKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Shift || keyCode == kVK_RightShift }
public func IsCommandKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Command || keyCode == kVK_RightCommand }
public func IsOptionKeyCode(_ keyCode: CGKeyCode) -> Bool { keyCode == kVK_Option || keyCode == kVK_RightOption }

// MARK: - CGEventFlags 和 NSEventModifierFlags 转换

// 将 CGEventFlags 转成 NSEventModifierFlags
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

// 比较 CGEventFlags 和 NSEventModifierFlags 是否相同
public func CGEventFlagsEqualToModifierFlags(_ cgFlags: CGEventFlags, _ nsFlags: NSEvent.ModifierFlags) -> Bool { NSEventModifierFlagsFromCGEventFlags(cgFlags) == nsFlags }

// 事件的修饰键 == nsFlags
public func CGEventMatchesModifierFlags(_ event: CGEvent, _ nsFlags: NSEvent.ModifierFlags) -> Bool { CGEventFlagsEqualToModifierFlags(event.flags, nsFlags) }

// MARK: - 坐标系相关

// 将屏幕坐标系上的点(左上角为(0,0), 向下为正）,转换为视图坐标系上的点（左下角为(0,0), 向上为正）
public func ConvertToBottomLeftCoordinateSystem(_ topLeftCoordinateSystemPoint: NSPoint) -> NSPoint {
    var coordinatedH = 0.0
    for screen in NSScreen.screens {
        if CGPointEqualToPoint(screen.frame.origin, .zero) {
            coordinatedH = screen.frame.size.height
            break
        }
    }
    return NSPoint(x: topLeftCoordinateSystemPoint.x, y: coordinatedH - topLeftCoordinateSystemPoint.y)
}
