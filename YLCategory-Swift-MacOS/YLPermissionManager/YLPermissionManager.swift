//
//  YLPermissionManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation

public enum YLPermissionAuthType {
    case none
    case accessibility      // 辅助功能权限
    case fullDisk           // 完全磁盘权限
    case screenCapture      // 录屏权限
}

public class YLPermissionManager: NSObject {
    
    static let shared = YLPermissionManager()
    private override init() {}
    
    /// 是否所有权限都已授权
    var allAuthPassed: Bool {
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
    var isSkipped: Bool { skipped }
    
    /// 点击了跳过授权
    var skipHandler: (() -> Void)?
    /// 点击了退出
    var quitHandler: (() -> Void)?
    /// 所有权限都已授权后的回调
    var allAuthPassedHandler: (() -> Void)?
    
    /// 教学视频链接，不设置则不显示 观看权限设置教学>> 的按钮
    var tutorialLink: String?
    
    
    /// 一次性监听所有权限，如果有权限未授权，则会显示授权窗口，当所有权限都授权时，则自动隐藏
    /// - Parameters:
    ///   - authTypes: 需要授权的权限
    ///   - repeatSeconds: 定时监听的秒数，一旦某个权限有变化，就会更新显示；默认为0，表示不重复，授权完毕后，退出监测
    private var second = 0
    func monitorPermissionAuth(_ authTypes: [YLPermissionModel], repeatSeconds: Int = 0) {
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
                    self.permissionWC?.permissionVc.authTypes = authTypes
                } else {
                    self.permissionWC?.permissionVc.refreshAllAuthState()
                }
                self.permissionWC?.window?.orderFrontRegardless()
            } else {
                second += 1
                if second >= repeatSeconds {
                    // 达到了设置的间隔秒数
                    if self.allAuthPassed == false {
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
                        second = 0
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
    
    // MARK: - 单个权限
    
    // MARK: 检查某个权限是否开启，如果未开启，则弹出Alert，请求打开权限
    @discardableResult
    func checkPermission(authType type:YLPermissionAuthType) -> Bool {
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
            alert.informativeText = YLPermissionManager.localize(tips) + YLPermissionManager.appName
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
    func getPrivacyAccessibilityIsEnabled() -> Bool { AXIsProcessTrusted() }
    
    // MARK: 获取录屏权限是否打开
    func getScreenCaptureIsEnabled() -> Bool {
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
    func getFullDiskAccessIsEnabled() -> Bool {
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
    @objc func openPrivacyAccessibilitySetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        NSWorkspace.shared.open(URL(string: url)!)
        // 模拟键盘事件，将app带入到权限列表
        guard let eventRef = CGEvent(source: nil) else { return }
        let point = eventRef.location
        guard let mouseEventRef = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else { return }
        mouseEventRef.post(tap: .cghidEventTap)
    }
    
    // MARK: 打开录屏权限设置窗口
    @objc func openScreenCaptureSetting() {
        // 创建一个 1x1 的屏幕截图，检查屏幕录制权限
        let _ = CGWindowListCreateImage(CGRect(x: 0, y: 0, width: 1, height: 1), .optionOnScreenOnly, kCGNullWindowID, [])
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: 打开完全磁盘权限设置窗口
    @objc func openFullDiskAccessSetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: - private
    
    private var permissionWC: YLPermissionWindowController?
    private var authTypes: [YLPermissionModel] = []
    private var monitorTimer: Timer? = nil
    private var skipped: Bool = false
    
    
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
    
    // MARK: - 本地化相关
    
    static let bundle = Bundle(for: YLPermissionManager.self)
    static func localize(_ key: String) -> String { YLPermissionManager.bundle.localizedString(forKey: key, value: "", table: "YLPermissionManager") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}

