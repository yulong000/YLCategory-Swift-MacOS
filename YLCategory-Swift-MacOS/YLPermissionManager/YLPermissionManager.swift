//
//  YLPermissionManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation
import AppKit

@objc public enum YLPermissionAuthType: UInt8 {
    case none
    case accessibility      // 辅助功能权限
    case fullDisk           // 完全磁盘权限
    case screenCapture      // 录屏权限
}

public class YLPermissionManager: NSObject {
    
    public static let shared = YLPermissionManager()
    private override init() {
        super.init()
        self.monitorAccessibilityPermissionDelete()
    }
    
    /// 是否所有权限都已授权
    public var allAuthPassed: Bool {
        var flag = true
        for model in authTypes {
            switch model.authType {
            case .accessibility:
                flag = flag && getPrivacyAccessibilityIsEnabled()
            case .screenCapture:
                flag = flag && getScreenCaptureIsEnabled()
            case .fullDisk:
                flag = flag && getFullDiskAccessIsEnabled()
            default:
                break
            }
            if flag == false { break }
        }
        return flag
    }
    /// 是否点击了跳过授权
    public var isSkipped: Bool { skipped }
    
    /// 点击了跳过授权
    public var skipHandler: (() -> Void)?
    /// 点击了退出
    public var quitHandler: (() -> Void)?
    /// 所有权限都已授权后的回调
    public var allAuthPassedHandler: (() -> Void)?
    
    /// 教学视频链接，不设置则不显示 观看权限设置教学>> 的按钮
    public var tutorialLink: String?
    
    // MARK: - 循环监听
    
    /// 一次性监听所有权限，如果有权限未授权，则会显示授权窗口，当所有权限都授权时，则自动隐藏
    /// - Parameters:
    ///   - authTypes: 需要授权的权限
    ///   - repeatSeconds: * 3 为 定时监听的秒数（比如，传入5s，则15s内检测3次，3次都返回false，则弹出授权窗口），一旦某个权限有变化，就会更新显示；默认为0，表示不重复，授权完毕后，退出监测
    private var second = 0 // 记录过了多少秒
    private var retryCount = 0 // 如果获取到有权限未授权，重新获取，超过一定次数，则判断为未全部授权，防止系统问题引起的授权窗口弹出
    public func monitorPermissionAuth(_ authTypes: [YLPermissionModel], repeatSeconds: Int = 0) {
        self.authTypes = authTypes
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            if repeatSeconds <= 0 {
                // 不需要循环检测
                if self.allAuthPassed {
                    self.monitorTimer?.invalidate()
                    self.monitorTimer = nil
                    if self.permissionWC != nil {
                        self.passAuth()
                    }
                    return
                }
                // 有权限未授权，弹出授权窗口
                if self.permissionWC == nil {
                    self.permissionWC = YLPermissionWindowController()
                    self.permissionWC?.permissionVc.allAuthPassedHandler = {
                        // 已全部授权
                        self.monitorTimer?.invalidate()
                        self.monitorTimer = nil
                        self.passAuth()
                    }
                    self.permissionWC?.permissionVc.skipHandler = {
                        // 跳过
                        self.skipAuth()
                    }
                    self.permissionWC?.permissionVc.quitHandler = {
                        // 退出
                        self.quitHandler?()
                    }
                    self.permissionWC?.closeHandler = {
                        // 点击了关闭按钮
                        self.monitorTimer?.invalidate()
                        self.monitorTimer = nil
                        self.permissionWC = nil
                    }
                    self.permissionWC?.permissionVc.authTypes = authTypes
                } else {
                    self.permissionWC?.permissionVc.refreshAllAuthState()
                }
                self.permissionWC?.window?.orderFrontRegardless()
            } else {
                self.second += 1
                if self.second >= repeatSeconds {
                    // 达到了设置的间隔秒数
                    self.second = 0
                    if self.allAuthPassed == false {
                        self.retryCount += 1
                        if self.retryCount < 3 {
                            return
                        }
                        self.retryCount = 0
                        // 有权限未授权，弹出授权窗口
                        if self.permissionWC == nil {
                            self.permissionWC = YLPermissionWindowController()
                            self.permissionWC?.permissionVc.allAuthPassedHandler = {
                                // 已全部授权
                                self.passAuth()
                            }
                            self.permissionWC?.permissionVc.skipHandler = {
                                // 跳过
                                self.skipAuth()
                            }
                            self.permissionWC?.permissionVc.quitHandler = {
                                // 退出
                                self.quitHandler?()
                            }
                            self.permissionWC?.permissionVc.authTypes = authTypes
                        }
                        self.permissionWC?.window?.orderFrontRegardless()
                    } else {
                        // 都已授权
                        if self.permissionWC != nil {
                            self.passAuth()
                        }
                    }
                } else if self.permissionWC != nil {
                    // 如果授权窗口在，每秒刷新一次状态
                    self.permissionWC?.permissionVc.refreshAllAuthState()
                }
            }
        })
    }
    
    
    // MARK: - 一次性监听
    
    // MARK: 检查多个权限是否同时开启
    public func checkPermissionAuth(_ authTypes: [YLPermissionAuthType]) -> Bool {
        var flag = true
        for type in authTypes {
            switch type {
            case .accessibility:
                flag = flag && getPrivacyAccessibilityIsEnabled()
            case .screenCapture:
                flag = flag && getScreenCaptureIsEnabled()
            case .fullDisk:
                flag = flag && getFullDiskAccessIsEnabled()
            default:
                break
            }
            if flag == false { break }
        }
        return flag
    }
    
    // MARK: 显示授权窗口
    public func showPermissionAuth(_ authTypes: [YLPermissionModel]) {
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            if self.permissionWC == nil {
                self.permissionWC = YLPermissionWindowController()
                self.permissionWC?.permissionVc.allAuthPassedHandler = {
                    // 已全部授权
                    self.monitorTimer?.invalidate()
                    self.monitorTimer = nil
                    self.passAuth()
                }
                self.permissionWC?.permissionVc.skipHandler = {
                    // 跳过
                    self.skipAuth()
                }
                self.permissionWC?.permissionVc.quitHandler = {
                    // 退出
                    self.quitHandler?()
                }
                self.permissionWC?.closeHandler = {
                    // 点击了关闭按钮
                    self.monitorTimer?.invalidate()
                    self.monitorTimer = nil
                    self.permissionWC = nil
                }
                self.permissionWC?.permissionVc.authTypes = authTypes
            } else {
                self.permissionWC?.permissionVc.refreshAllAuthState()
            }
            self.permissionWC?.window?.orderFrontRegardless()
        })
    }
    
    // MARK: 检查某个权限是否开启，如果未开启，则弹出Alert，请求打开权限
    @discardableResult
    public func checkPermission(authType type:YLPermissionAuthType) -> Bool {
        var flag = true
        var selector: Selector?
        var tips: String = ""
        switch type {
        case .accessibility:
            flag = getPrivacyAccessibilityIsEnabled()
            tips = "Accessibility Tips"
            selector = #selector(openPrivacyAccessibilitySetting)
        case .screenCapture:
            flag = getScreenCaptureIsEnabled()
            tips = "ScreenCapture Tips"
            selector = #selector(openScreenCaptureSetting)
        case .fullDisk:
            flag = getFullDiskAccessIsEnabled()
            tips = "Full disk access Tips"
            selector = #selector(openFullDiskAccessSetting)
        default:
            break
        }
        if flag == false {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLPermissionManager.localize("Kind tips")
            alert.informativeText = String(format: YLPermissionManager.localize(tips), YLPermissionManager.appName)
            alert.addButton(withTitle: YLPermissionManager.localize("To Authorize"))
            alert.addButton(withTitle: YLPermissionManager.localize("Cancel"))
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let sel = selector, responds(to: sel)  {
                    perform(sel)
                }
            }
        }
        return flag
    }
    
    // MARK: 获取辅助功能权限是否打开
    public func getPrivacyAccessibilityIsEnabled() -> Bool { AXIsProcessTrusted() && canCreateEventTap }
    
    // MARK: 获取录屏权限是否打开
    public func getScreenCaptureIsEnabled() -> Bool {
        guard #available(macOS 10.15, *) else { return true }
        let currentPid = NSRunningApplication.current.processIdentifier
        // 获取当前屏幕上的窗口信息
        guard let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[CFString: Any]] else { return false }
        for dict in windowList {
            if let name = dict[kCGWindowName] as? String,
               !name.isEmpty,
               let pid = dict[kCGWindowOwnerPID] as? pid_t,
               pid != currentPid,
               let runningApp = NSRunningApplication(processIdentifier: pid),
               let execName = runningApp.executableURL?.lastPathComponent,
               execName != "Dock" {
                return true
            }
        }
        return false
    }
    
    // MARK: 获取完全磁盘权限是否打开
    public func getFullDiskAccessIsEnabled() -> Bool {
        if #available(macOS 10.14, *) {
            let isSandbox = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
            let userHomePath: String
            
            if isSandbox {
                guard let pw = getpwuid(getuid()), let homeDir = pw.pointee.pw_dir else {
                    fatalError("Failed to retrieve home directory in sandbox mode.")
                }
                userHomePath = String(cString: homeDir)
            } else {
                userHomePath = NSHomeDirectory()
            }
            
            let testFiles = [
                "\(userHomePath)/Library/Safari/CloudTabs.db",
                "\(userHomePath)/Library/Safari/Bookmarks.plist",
                "/Library/Application Support/com.apple.TCC/TCC.db",
                "/Library/Preferences/com.apple.TimeMachine.plist"
            ]
            
            for file in testFiles {
                let fd = open(file, O_RDONLY)
                if fd != -1 {
                    close(fd)
                    return true
                }
            }
            return false
        }
        return true
    }
    
    // MARK: 打开辅助功能权限设置窗口
    @objc public func openPrivacyAccessibilitySetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        NSWorkspace.shared.open(URL(string: url)!)
        // 模拟键盘事件，将app带入到权限列表
        guard let eventRef = CGEvent(source: nil) else { return }
        let point = eventRef.location
        guard let mouseEventRef = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else { return }
        mouseEventRef.post(tap: .cghidEventTap)
    }
    
    // MARK: 打开录屏权限设置窗口
    @objc public func openScreenCaptureSetting() {
        // 创建一个 1x1 的屏幕截图，检查屏幕录制权限
        let _ = CGWindowListCreateImage(CGRect(x: 0, y: 0, width: 1, height: 1), .optionOnScreenOnly, kCGNullWindowID, [])
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: 打开完全磁盘权限设置窗口
    @objc public func openFullDiskAccessSetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: - private
    
    private var permissionWC: YLPermissionWindowController?
    private var authTypes: [YLPermissionModel] = []
    private var monitorTimer: Timer? = nil
    private var skipped: Bool = false
    // 辅助功能相关
    private var accessibilityTimer: DispatchSourceTimer?
    private var canCreateEventTap = true
    
    // MARK: 通过授权
    private func passAuth() {
        permissionWC?.close()
        permissionWC = nil
        allAuthPassedHandler?()
    }
    // MARK: 跳过授权
    private func skipAuth() {
        permissionWC?.close()
        permissionWC = nil
        monitorTimer?.invalidate()
        monitorTimer = nil
        skipped = true
        skipHandler?()
    }
    
    // MARK: 监听辅助功能权限是否删除了
    private func monitorAccessibilityPermissionDelete() {
        guard accessibilityTimer == nil else { return }
        let queue = DispatchQueue.global(qos: .default)
        accessibilityTimer = DispatchSource.makeTimerSource(queue: queue)
        accessibilityTimer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .seconds(1))
        accessibilityTimer?.setEventHandler(handler: { [weak self] in
            guard let self = self else { return }
            if AXIsProcessTrusted() {
                if let tap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap, place: .tailAppendEventTap, options: .listenOnly, eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue), callback: {_,_,_,_ in return nil}, userInfo: nil) {
                    CGEvent.tapEnable(tap: tap, enable: false)
                    self.canCreateEventTap = true
                } else {
                    self.canCreateEventTap = false
                }
            }
        })
        accessibilityTimer?.resume()
    }
    
    // MARK: - 本地化相关
    
    static let bundle = Bundle(for: YLPermissionManager.self)
    static func localize(_ key: String) -> String { YLPermissionManager.bundle.localizedString(forKey: key, value: "", table: "YLPermissionManager") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    
    static func bundleImage(_ name: String) -> NSImage {
        var url = Bundle.main.url(forResource: "YLPermissionManager", withExtension: "bundle")
        if url == nil {
            url = Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathExtension("/YLCategory.framework")
            if url != nil {
                let bundle = Bundle(url: url!)
                url = bundle?.url(forResource: "YLPermissionManager", withExtension: "bundle")
            }
        }
        guard let url = url, let path = Bundle(url: url)?.bundlePath.appending("/\(name)") else { return NSImage() }
        return NSImage(contentsOfFile: path) ?? NSImage()
    }
}

