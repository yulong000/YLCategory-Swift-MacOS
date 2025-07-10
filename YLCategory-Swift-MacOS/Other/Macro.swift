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
import AVFoundation
import UniformTypeIdentifiers

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

public func RandomColor() -> NSColor { NSColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0) }
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
// Library 路径
public var kLibraryPath: String { NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last ?? "" }
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
public var GUIUserName: String? {
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, nil, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    return userName
}
// app的owner account ID, 从app store下载的一般是0，其他方式安装的是501，也有可能是其他值
public let OwnerAccountID: Int? = {
    guard let path = Bundle.main.executablePath,
          let attr = try? FileManager.default.attributesOfItem(atPath: path),
          let accountID = attr[.ownerAccountID] as? Int else {
        return nil
    }
    return accountID
}()

// 重启app
public func RestartApp() {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = ["-n", Bundle.main.bundlePath]
    task.launch()
    NSApp.terminate(nil)
}

// 打开链接
@discardableResult
public func OpenUrl(_ path: String) -> Bool {
    YLLog("Open url: \(path)")
    if let url = URL(string: path) {
        return NSWorkspace.shared.open(url)
    }
    return false
}

// 执行命令
@discardableResult
public func ExecuteCMD(_ cmd: String, argus: [String]? = nil) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", cmd] + (argus ?? [])
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    do {
        try process.run()
    } catch {
        YLLog("❌ cmd '/bin/bash -c \(cmd)' 发生错误: \(error)")
        return nil
    }
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if process.terminationStatus != 0 {
        YLLog("❌ cmd '/bin/bash -c \(cmd)' 执行失败: \(errorOutput)")
        return nil
    }
    YLLog("✅ cmd '/bin/bash -c \(cmd)' 执行成功:\n\(output)")
    return output
}

// 执行自定义命令
@discardableResult
public func ExecuteCustomCMD(_ url: String, argus: [String]) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: url)
    process.arguments = argus
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    do {
        try process.run()
    } catch {
        YLLog("❌ custom cmd '\(([url] + argus).joined(separator: " "))' 发生错误: \(error)")
        return nil
    }
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if process.terminationStatus != 0 {
        YLLog("❌ custom cmd '\(([url] + argus).joined(separator: " "))' 执行失败: \(errorOutput)")
        return nil
    }
    YLLog("✅ custom cmd '\(([url] + argus).joined(separator: " "))' 执行成功:\n\(output)")
    return output
}

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


// MARK: - 系统警告音音量

// 提示音音量
private var beepVolumeValue: Float?
private let kAudioServicesPropertySystemAlertVolume: AudioServicesPropertyID = OSType("ssvl".utf8.reduce(0) { ($0 << 8) | FourCharCode($1)})

// MARK: 添加监听系统警告音的通知，可以提前修改警告音音量到最小，并在收到通知后，恢复警告音音量，以实现静音效果
public func RegisterSystemBeepNotification(_ observer: Any, selector: Selector) {
    DistributedNotificationCenter.default().addObserver(observer, selector: selector, name: NSNotification.Name(rawValue:"com.apple.systemBeep"), object: nil)
}

// MARK: 移除监听系统警告音的通知
public func UnregisterSystemBeepNotification(_ observer: Any) {
    DistributedNotificationCenter.default().removeObserver(observer, name: NSNotification.Name(rawValue:"com.apple.systemBeep"), object: nil)
}

// MARK: 获取当前警告音的音量
public func GetSystemBeepVolume() -> Float {
    var volume: Float = 0
    var volSize = UInt32(MemoryLayout.size(ofValue: volume))
    let err = AudioServicesGetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, &volSize, &volume)
    if err != noErr {
        print("Error getting alert volume: \(err)")
        return .nan
    }
    return volume
}
// MARK: 设置警告音音量，并保存当前的值
public func SetSystemBeepVolume(_ volume: Float32) {
    beepVolumeValue = GetSystemBeepVolume()
    var v = volume
    AudioServicesSetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, UInt32(MemoryLayout.size(ofValue: volume)), &v)
}
// MARK: 恢复原来的警告音音量
public func RecoverSystemBeepVolume() {
    if let beepVolumeValue = beepVolumeValue {
        SetSystemBeepVolume(beepVolumeValue)
    }
}

// MARK: - app 相关

// MARK: app是否安装
public func AppIsInstalled(_ bundleId: String) -> Bool {
    guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else { return false }
    return FileManager.default.fileExists(atPath: appUrl.path)
}
// MARK: app是否在运行
public func AppIsRunning(_ bundleId: String) -> Bool {
    !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
}
// MARK: 根据名字打开app
public func RunAppWithName(_ name: String, delay second: TimeInterval = 0, success handler: (() -> Void)? = nil) {
    for runningApp in NSWorkspace.shared.runningApplications {
        if let appName = runningApp.localizedName, name == appName {
            if second > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    handler?()
                }
            } else {
                handler?()
            }
            return
        }
    }
    if NSWorkspace.shared.launchApplication(name) {
        if second > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                handler?()
            }
        } else {
            handler?()
        }
    }
}
// MARK: 根据 bundle id 打开app
public func RunAppWithBundleID(_ bundleID: String, arguments: [String]? = nil, activates: Bool = true, completion handler: ((Bool) -> Void)? = nil) {
    if !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty {
        // 已经在运行
        handler?(true)
        return
    }
    if #available(macOS 11.0, *) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            handler?(false)
            return
        }
        let config = NSWorkspace.OpenConfiguration()
        config.activates = activates
        config.arguments = arguments ?? []
        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { app, error in
            if let _ = app, error == nil {
                handler?(true)
            } else {
                handler?(false)
            }
        }
    } else {
        let success = NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleID, options: activates ? .default : .withoutActivation, additionalEventParamDescriptor: nil, launchIdentifier: nil)
        handler?(success)
    }
}

// MARK: - event 相关

// MARK: 模拟键盘按下&抬起
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


// MARK: - 文件类型

// MARK: url是否是文件夹
public func IsDirectory(_ url: URL) -> Bool {
    return IsDirectory(url.path)
}

// MARK: path是否是文件夹
public func IsDirectory(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        return isDir.boolValue
    }
    return false
}

// MARK: 判断文件的类型, 传入URL
@available(macOS, introduced: 10.3, obsoleted: 11.0, message: "请改用 File(_:isType:) 方法，支持基于 UTType 的类型判断")
public func File(_ url: URL, isType type: CFString) -> Bool {
    return File(url.path, isType: type)
}

// MARK: 判断文件的类型, 传入path, eg: File("/Users/xxx/test.zip", isType: kUTTypeArchive)
@available(macOS, introduced: 10.3, obsoleted: 11.0, message: "请改用 File(_:isType:) 方法，支持基于 UTType 的类型判断")
public func File(_ path: String, isType type: CFString) -> Bool {
    return File(path, isAnyOfTypes: [type])
}

// MARK: 判断文件是否符合任一指定类型
@available(macOS, introduced: 10.3, obsoleted: 11.0, message: "请改用 File(_:isAnyOfTypes:) 方法，支持基于 UTType 的类型判断")
public func File(_ path: String, isAnyOfTypes types: [CFString]) -> Bool {
    // 判断是否是目录
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else {
        return false
    }

    let ext = (path as NSString).pathExtension.lowercased()
    guard !ext.isEmpty else { return false }
    
    if #available(macOS 11.0, *) {
        if let utType = UTType(filenameExtension: ext) {
            for cfType in types {
                let targetType = UTType(importedAs: cfType as String)
                if utType.conforms(to: targetType) {
                    return true
                }
            }
            return false
        }
    }

    // 兼容旧系统
    if let cfUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() {
        for cfType in types {
            if UTTypeConformsTo(cfUTI, cfType) {
                return true
            }
        }
    }

    return false
}

// MARK: 判断文件的类型, 传入URL (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ url: URL, isType type: UTType) -> Bool {
    return File(url.path, isAnyOfTypes: [type])
}

// MARK: 判断文件的类型, 传入path (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ path: String, isType type: UTType) -> Bool {
    return File(path, isAnyOfTypes: [type])
}

// MARK: 判断文件是否符合任一指定类型 (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ path: String, isAnyOfTypes types: [UTType]) -> Bool {
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else {
        return false
    }

    let ext = (path as NSString).pathExtension.lowercased()
    guard !ext.isEmpty else { return false }
    
    guard let fileType = UTType(filenameExtension: ext) else {
        return false
    }

    for type in types {
        if fileType.conforms(to: type) {
            return true
        }
    }

    return false
}


// MARK: - app 环境

public enum AppEnvironment: String {
    case appStore       = "App store"       // App store 线上
    case testFlight     = "TestFlight"      // TestFlight 测试
    case developerID    = "Developer ID"    // 线下分发的Apple公证过的app
    case adHoc          = "Ad Hoc"          // 特定人群的测试版本
    case development    = "Development"     // 开发调试
    case other          = "Other"           // 未知版本或苹果审核
}

public let AppRunningEnvironment: AppEnvironment = {
    
    var environment: AppEnvironment = .other
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
    process.arguments = ["-dv", "--verbose=4", Bundle.main.bundlePath]
    
    let pipe = Pipe()
    // 输出内容在error里
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard process.terminationStatus == 0 else {
            YLLog("Get AppRunningEnvironment error: \(output)")
            return environment
        }
        
        let list = output.components(separatedBy: "\n").compactMap { $0.hasPrefix("Authority") ? $0 : nil }
        for str in list {
            guard let evn = str.components(separatedBy: "=").last else { continue }
            switch evn {
            case "Apple Mac OS Application Signing":                    environment = .appStore
            case "TestFlight Beta Distribution":                        environment = .testFlight
            case let id where id.hasPrefix("Developer ID Application"): environment = .developerID
            case let id where id.hasPrefix("Apple Distribution"):       environment = .adHoc
            case let id where id.hasPrefix("Apple Development"):        environment = .development
            default: break
            }
        }
    } catch {
        YLLog("Get AppRunningEnvironment error: \(error)")
    }
    YLLog("当前App的运行环境为：\(environment.rawValue)")
    return environment
}()
