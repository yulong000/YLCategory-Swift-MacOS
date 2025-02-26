//
//  YLShortcutManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/1/4.
//

import Foundation
import AppKit
import Carbon
import AudioToolbox

// MARK: - 快捷键管理
public class YLShortcutManager {
    
    /// 单例
    public static let shared = YLShortcutManager()
    /// 全局配置
    public let config = YLShortcutConfig()
    
    private init() {
        
        // 注册快捷键回调
        var hotKeyPressedSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetEventDispatcherTarget(), YLCarbonEventCallBack, 1, &hotKeyPressedSpec, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        if status != noErr {
            print("InstallEventHandler Error")
        }
        
        if optionModifierInvalidInCurrentSystem() {
            // 监听辅助功能权限
            monitorAccessibilityPermissionDidChanged()
            // 监听错误提示音播放
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(systemBeepNotification), name: NSNotification.Name(rawValue:"com.apple.systemBeep"), object: nil)
        }
    }
    
    deinit {
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        
        if let timer = timer {
            timer.cancel()
            self.timer = nil
        }
        
        if optionModifierInvalidInCurrentSystem() {
            unregisterKeyDownSource()
            DistributedNotificationCenter.default().removeObserver(self)
        }
    }
    
    // MARK: - 注册
    
    /// 注册快捷键
    /// - Parameters:
    ///   - shortcut: 快捷键
    ///   - handler: 回调
    /// - Returns: 是否注册成功
    @discardableResult
    public func register(_ shortcut: YLShortcut, action handler: @escaping () -> Void) -> Bool {
        if let hotkey = YLHotKey(shortcut: shortcut) {
            hotkey.action = handler
            hotKeys[shortcut] = hotkey
            return true
        }
        // 注册失败，检查是否是因为含有Option键
        let flags = shortcut.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard flags == .option || flags == [.option, .shift], optionModifierInvalidInCurrentSystem() else { return false }
        if accessibilityIsEnabled() {
            // 辅助功能权限已打开
            guard registerKeyDownSource() else { return false }
            let hotKey = YLHotKey(optionShortcut: shortcut)
            hotKey.action = handler
            hotKeys[shortcut] = hotKey
            return true
        }
        // 辅助功能未开启
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLShortcutManager.localize("Kind tips")
        alert.informativeText = YLShortcutManager.localize("Accessibility Tips")
        alert.addButton(withTitle: YLShortcutManager.localize("To Authorize"))
        alert.addButton(withTitle: YLShortcutManager.localize("Cancel"))
        if alert.runModal() == .alertFirstButtonReturn {
            requestAccessibilityPermission()
        }
        return false
    }
    
    /// 快捷键是否已注册
    public func isRegisterd(_ shortcut: YLShortcut) -> Bool {
        hotKeys.keys.contains { $0 == shortcut }
    }
    
    // MARK: - 取消注册
    
    // 取消注册快捷键
    public func unregister(_ shortcut: YLShortcut) {
        for obj in hotKeys.keys {
            if obj == shortcut {
                hotKeys.removeValue(forKey: obj)
            }
        }
        ignoreHotKeys.removeAll { $0 == shortcut }
    }
    
    // 取消注册所有快捷键
    public func unregisterAllShortcuts() {
        hotKeys.removeAll()
        ignoreHotKeys.removeAll()
    }
    
    
    // MARK: - 暂停和恢复
    
    /// 暂停监听某个快捷键
    public func pauseMonitor(_ shortcut: YLShortcut) {
        let isIgnore = ignoreHotKeys.contains { $0 == shortcut }
        if !isIgnore {
            ignoreHotKeys.append(shortcut)
        }
    }
    
    /// 恢复监听某个快捷键
    public func continueMonitor(_ shortcut: YLShortcut) {
        ignoreHotKeys.removeAll { $0 == shortcut }
    }
    
    /// 暂停监听多个快捷键
    public func pauseMonitor(_ shortcuts: [YLShortcut]) {
        for shortcut in shortcuts {
            pauseMonitor(shortcut)
        }
    }
    
    /// 恢复监听多个快捷键
    public func continueMonitor(_ shortcuts: [YLShortcut]) {
        for shortcut in shortcuts {
            continueMonitor(shortcut)
        }
    }
    
    /// 恢复监听所有快捷键
    public func continueMonitorAllShortcuts() {
        ignoreHotKeys.removeAll()
    }
    
    // MARK: - 有效性判断
    
    public func valid(_ shortcut: YLShortcut) -> Bool {
        let keyCode = Int(shortcut.keyCode)
        let modifiers = shortcut.modifierFlags
        
        let functionKeys: Set<Int> = [kVK_F1, kVK_F2, kVK_F3, kVK_F4, kVK_F5, kVK_F6, kVK_F7, kVK_F8, kVK_F9, kVK_F10, kVK_F11, kVK_F12, kVK_F13, kVK_F14, kVK_F15, kVK_F16, kVK_F17, kVK_F18, kVK_F19, kVK_F20]
        if functionKeys.contains(keyCode) {
            return true
        }
        let hasModifierFlags: Bool = modifiers.rawValue > 0
        if !hasModifierFlags {
            // 没有修饰键
            return false
        }
        let includesCommand = modifiers.contains(.command)
        let includesControl = modifiers.contains(.control)
        let includesOption = modifiers.contains(.option)
        if includesCommand || includesControl || includesOption {
            return true
        }
        return false
    }
    
    // MARK: 是否被App的菜单栏占用
    public func alreadyTaken(_ shortcut: YLShortcut, inMenu menu: NSMenu?) -> Bool {
        guard let menu = menu else { return false }
        let keyEquivalent = shortcut.keyCodeStringForKeyEquivalent
        let flags = shortcut.modifierFlags
        for item in menu.items {
            if let submenu = item.submenu, alreadyTaken(shortcut, inMenu: submenu) { return true }
            var equalFlags = item.keyEquivalentModifierMask.intersection([.control, .shift, .command, .option, .function]) == flags
            let equalHotkeyLowercase = item.keyEquivalent.lowercased() == keyEquivalent
            
            if equalHotkeyLowercase && item.keyEquivalent != keyEquivalent {
                equalFlags = item.keyEquivalentModifierMask.union(.shift).intersection([.control, .shift, .command, .option, .function]) == flags
            }
            if equalFlags && equalHotkeyLowercase {
                return true
            }
        }
        return false
    }
    
    // MARK: 是否被系统和app的菜单栏占用
    public func alreadyTakenBySystem(_ shortcut: YLShortcut) -> Bool {
        var unmanagedGlobalHotkeys: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&unmanagedGlobalHotkeys) == noErr,
              let globalHotkeys = unmanagedGlobalHotkeys?.takeRetainedValue() as? [CFDictionary] else {
            return alreadyTaken(shortcut, inMenu: NSApp.mainMenu)
        }
        for hotKeyInfo in globalHotkeys {
            let hotkeyDict = hotKeyInfo as? [AnyHashable: Any]
            let keyCode = (hotkeyDict?[kHISymbolicHotKeyCode] as? NSNumber)?.intValue ?? -1
            let modifierFlags = (hotkeyDict?[kHISymbolicHotKeyModifiers] as? NSNumber)?.uintValue ?? 0
            let isEnable = (hotkeyDict?[kHISymbolicHotKeyEnabled] as? NSNumber)?.boolValue ?? false
            if isEnable, keyCode == shortcut.keyCode, modifierFlags == shortcut.carbonFlags {
                return true
            }
        }
        return alreadyTaken(shortcut, inMenu: NSApp.mainMenu)
    }
    
    // MARK: - Option 修饰键判断
    
    /// 含有option的快捷键在该系统版本下是否失效
    public func optionModifierInvalidInCurrentSystem() -> Bool {
        if #available(macOS 15.3, *) { return false }
        if #available(macOS 15.0, *) { return true }
        return false
    }
    
    /// 单个快捷键是否包含Option修饰键，且可以正常使用
    public func validWithOptionModifier(_ shortcut: YLShortcut) -> Bool {
        if optionModifierInvalidInCurrentSystem() {
            let modifierFlags = shortcut.modifierFlags
            let deviceIndependentFlags = modifierFlags.intersection(.deviceIndependentFlagsMask)
            if deviceIndependentFlags == .option || deviceIndependentFlags == [.option, .shift] {
                // Option + keyCode 或者 Option + shift + keyCode
                if shortcut.keyCode != kVK_Space && !accessibilityIsEnabled() {
                    return false
                }
            }
        }
        return true
    }
    
    /// 多个快捷键是否包含Option修饰键，且可以正常使用
    public func validWithOptionModifier(_ shortcuts: [YLShortcut]) -> Bool {
        var valid = true
        for shortcut in shortcuts {
            if validWithOptionModifier(shortcut) == false {
                valid = false
                break
            }
        }
        return valid
    }
    
    /// 弹窗提醒，因Option无法使用，需授权辅助功能权限，点击授权，会退出app并打开授权页面，点击清空，会回调
    public func showAuthAccessibilityOrClearAlertForOptionModifier(clear handler: () -> Void) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLShortcutManager.localize("Kind tips")
        alert.informativeText = YLShortcutManager.localize("Option Modifier Tips")
        alert.addButton(withTitle: YLShortcutManager.localize("Auth Accessibility"))
        alert.addButton(withTitle: YLShortcutManager.localize("Clear Option Shortcuts"))
        if alert.runModal() == .alertFirstButtonReturn {
            // 关闭app，打开辅助功能权限
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSApp.terminate(nil)
            }
            requestAccessibilityPermission()
        } else {
            // 清空 Option + 快捷键回调
            handler()
        }
    }
    
    /// 判断是否开启了辅助功能权限
    public func accessibilityIsEnabled() -> Bool {
        if AXIsProcessTrusted() == false {
            return false
        }
        // 如果是把辅助功能权限删掉了，而不是把开关关闭了，此时AXIsProcessTrusted()获取到的仍然是true，所以需要再加一步判断
        let tap = CGEvent.tapCreate(tap: .cghidEventTap, place: .tailAppendEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue), callback: YLKeyDownEventCallBack, userInfo: nil)
        return tap != nil
    }
    
    /// 请求辅助功能权限
    func requestAccessibilityPermission() {
        // 模拟鼠标抬起，请求辅助功能权限
        if let eventRef = CGEvent(source: nil) {
            let point = eventRef.location
            if let mouseEventRef = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) {
                mouseEventRef.post(tap: .cghidEventTap)
            }
        }
        // 打开辅助功能权限请求页面
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        NSWorkspace.shared.open(URL(string: url)!)
    }

    // MARK: - 本地化
    
    static func localize(_ key: String) -> String { Bundle(for: YLShortcutManager.self).localizedString(forKey: key, value: "", table: "YLShortcutManager") }
    
    // MARK: - private
    
    /// 事件回调
    private var eventHandler: EventHandlerRef?
    /// 存放所有的快捷键
    private var hotKeys: [YLShortcut: YLHotKey] = [:]
    /// 暂时忽略的快捷键
    private var ignoreHotKeys: [YLShortcut] = []
    
    /// macos 15 处理Option快捷键
    private var runloopSource: CFRunLoopSource?
    private var tap: CFMachPort?
    
    /// 监听辅助功能权限
    private var timer: DispatchSourceTimer?
    
    // MARK: - 监听辅助功能权限变化
    
    private func monitorAccessibilityPermissionDidChanged() {
        if optionModifierInvalidInCurrentSystem() {
            guard timer == nil else { return }
            let queue = DispatchQueue.global(qos: .default)
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .seconds(1))
            timer?.setEventHandler(handler: { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if !self.accessibilityIsEnabled() {
                        self.unregisterKeyDownSource()
                    } else {
                        self.registerKeyDownSource()
                    }
                }
            })
            timer?.resume()
        }
    }
    
    @discardableResult
    fileprivate func registerKeyDownSource() -> Bool {
        guard runloopSource == nil else { return true }
        tap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue), callback: YLKeyDownEventCallBack, userInfo: Unmanaged.passUnretained(self).toOpaque())
        guard let tap = tap else { return false }
        runloopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let runloopSource = runloopSource else { return false }
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runloopSource, .commonModes)
        return true
    }
    
    fileprivate func unregisterKeyDownSource() {
        if let runloopSource = runloopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runloopSource, .commonModes)
            self.runloopSource = nil
        }
        self.tap = nil
    }
    
    // MARK: - 警告音
    
    @objc private func systemBeepNotification() {
        if volumeChanged {
            setSystemVolume(volumeValue)
            volumeChanged = false
        }
    }
    
    // MARK: - 事件回调
    
    fileprivate func handleEvent(_ event: EventRef) {
        guard GetEventClass(event) == kEventClassKeyboard else { return }
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size(ofValue: hotKeyID), nil, &hotKeyID)
        guard status == noErr, hotKeyID.signature == YLHotKeySignature else { return }
        hotKeys.forEach { shortcut, hotKey in
            let isIgnore = ignoreHotKeys.contains { $0 == shortcut }
            guard !isIgnore, hotKeyID.id == hotKey.carbonID else { return }
            DispatchQueue.main.async {
                hotKey.action?()
            }
        }
    }
    
    fileprivate func handleOptionFlags(flags: CGEventFlags, keyCode: CGKeyCode) -> Bool {
        var valid = false
        hotKeys.forEach { shortcut, hotKey in
            guard keyCode == shortcut.keyCode else { return }
            if YLModifierFlagsEqual(cgFlags: flags, nsFlags: shortcut.modifierFlags) {
                let isIgnore = ignoreHotKeys.contains { $0 == shortcut }
                guard !isIgnore, let action = hotKey.action else { return }
                // 关闭提示音
                if !volumeChanged {
                    volumeValue = getSystemVolume()
                    if volumeValue > 0 {
                        setSystemVolume(0)
                        volumeChanged = true
                    }
                }
                valid = true
                DispatchQueue.main.async {
                    action()
                }
            }
        }
        return valid
    }
}

// MARK: - 配置信息
public class YLShortcutConfig {
    /// 样式
    public var style: YLShortcutStyle = .system
    /// 字体大小
    public var titleFont: NSFont?
    /// 没有快捷键时显示的文字
    public var titleForEmpty: String = YLShortcutManager.localize("Set shortcut keys")
    /// 没有快捷键且编辑时显示的文字
    public var titleForEmptyAndEditing: String = YLShortcutManager.localize("Enter shortcut keys")
    
    convenience init(style: YLShortcutStyle? = .system, titleFont: NSFont? = nil, titleForEmpty: String? = nil, titleForEmptyAndEditing: String? = nil) {
        self.init()
        if let style = style { self.style = style }
        if let titleFont = titleFont { self.titleFont = titleFont }
        if let titleForEmpty = titleForEmpty { self.titleForEmpty = titleForEmpty }
        if let titleForEmptyAndEditing = titleForEmptyAndEditing { self.titleForEmptyAndEditing = titleForEmptyAndEditing }
    }
}

// MARK: - 样式
@objc public enum YLShortcutStyle: UInt8 {
    case system, light, dark
}

fileprivate var CarbonHotKeyID: UInt32 = 0
fileprivate let YLHotKeySignature: FourCharCode = OSType("YLHK".utf8.reduce(0) { ($0 << 8) | FourCharCode($1)})

// MARK: - 注册的快捷键
fileprivate class YLHotKey {
    private(set) var carbonID: UInt32
    var action: (() -> Void)?
    
    private var hotKeyRef: EventHotKeyRef?
    private init() {
        self.carbonID = 0
    }
    
    convenience init?(shortcut: YLShortcut) {
        self.init()
        CarbonHotKeyID += 1
        self.carbonID = CarbonHotKeyID
        
        let hotKeyID = EventHotKeyID(signature: YLHotKeySignature, id: carbonID)
        let status = RegisterEventHotKey(shortcut.carbonKeyCode, shortcut.carbonFlags, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        if status != noErr {
            return nil
        }
    }
    
    convenience init(optionShortcut shortcut: YLShortcut) {
        self.init()
        CarbonHotKeyID += 1
        self.carbonID = CarbonHotKeyID
    }
    
    deinit {
        if hotKeyRef != nil {
            UnregisterEventHotKey(hotKeyRef!)
            hotKeyRef = nil
        }
    }
}

// MARK: - NSEvent 和 CGEvent flags 转换、比较

fileprivate func NSEventModifierFlagsFrom(cgEventFlags: CGEventFlags) -> NSEvent.ModifierFlags {
    var nsFlags: NSEvent.ModifierFlags = []
    if cgEventFlags.contains(.maskShift) {
        nsFlags.insert(.shift)
    }
    if cgEventFlags.contains(.maskControl) {
        nsFlags.insert(.control)
    }
    if cgEventFlags.contains(.maskAlternate) {
        nsFlags.insert(.option)
    }
    if cgEventFlags.contains(.maskCommand) {
        nsFlags.insert(.command)
    }
    return nsFlags
}

fileprivate func YLModifierFlagsEqual(cgFlags: CGEventFlags, nsFlags: NSEvent.ModifierFlags) -> Bool {
    NSEventModifierFlagsFrom(cgEventFlags: cgFlags) == nsFlags
}

// MARK: - 获取和设置提示音的音量

// 提示音音量
fileprivate var volumeValue: Float = 0
// 是否更改了提示音音量
fileprivate var volumeChanged = false

fileprivate let kAudioServicesPropertySystemAlertVolume: AudioServicesPropertyID = OSType("ssvl".utf8.reduce(0) { ($0 << 8) | FourCharCode($1)})
fileprivate func getSystemVolume() -> Float {
    var volume: Float = 0
    var volSize = UInt32(MemoryLayout.size(ofValue: volume))
    let err = AudioServicesGetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, &volSize, &volume)
    if err != noErr {
        print("Error getting alert volume: \(err)")
        return .nan
    }
    return volume
}

fileprivate func setSystemVolume(_ volume: Float32) {
    var v = volume
    AudioServicesSetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, UInt32(MemoryLayout.size(ofValue: volume)), &v)
}


// MARK: - 回调事件

fileprivate func YLKeyDownEventCallBack(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
    let manager = Unmanaged<YLShortcutManager>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .keyDown:
        // 按下键盘
        let flags = CGEventFlags(rawValue: (event.flags.rawValue & ~(CGEventFlags.maskNonCoalesced.rawValue | 0x20)))
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        if flags.contains(.maskAlternate) {
            if manager.handleOptionFlags(flags: flags, keyCode: keyCode) {
                return nil
            }
        }
    case .tapDisabledByTimeout:
        // 超时
        manager.unregisterKeyDownSource()
    default: break
    }
    return Unmanaged.passUnretained(event)
}

fileprivate func YLCarbonEventCallBack(_ handler: EventHandlerCallRef?, event: EventRef?, context: UnsafeMutableRawPointer?) -> OSStatus {
    guard let context = context, let event = event else { return OSStatus(eventNotHandledErr) }
    let manager = Unmanaged<YLShortcutManager>.fromOpaque(context).takeUnretainedValue()
    manager.handleEvent(event)
    return noErr
}
