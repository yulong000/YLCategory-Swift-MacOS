//
//  YLUpdateManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import AppKit

public class YLUpdateManager: NSObject {
    
    public static let shared = YLUpdateManager()
    private override init() {}
    
    /// 设置更新参数
    /// - Parameters:
    ///   - appID: app 的唯一标识
    ///   - xml: 强制更新配置链接（下载XML配置文件，根据配置参数判断）
    ///   - skipEnable: 是否可以跳过当前更新版本
    ///   当有新版本时，从该链接获取配置信息，来判断是否强制更新
    ///         "Name" :  "xxx"                                      app名字,
    ///         "BundleId": "com.xxxx.xxxx"                  app的bundle Id,
    ///         "ForceUpdateToTheLatest":  false        是否强制更新到最新版本
    ///         "MiniVersion":  "1.0.0"                           可以使用的最小版本号，小于该版本号，需要强制升级
    ///         "ExpiredDate":  "2025-10-30"                过期时间
    ///         "ExpiredOSVersion":  "17.0"                  过期的系统版本号
    ///         4个判断条件，优先级从上往下递减
    public func set(appID: String, forceUpdate xml: String? = nil, isSkipEnable: Bool = false) {
        self.appID = appID
        self.forceUpdateUrl = xml
        self.isSkipEnable = isSkipEnable
    }
    
    /// 检测更新
    /// - Parameter background: 是否后台检测, background = true时，无新版本，则不弹窗提醒
    public func checkForUpdates(background: Bool = true) {
        guard let appID = appID, !appID.isEmpty else { return }
        let task = URLSession.shared.dataTask(with: URL(string: appUpdateUrl!)!) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                    if let resultCount = resp["resultCount"] as? Int, resultCount > 0,
                       let results = resp["results"] as? [[String : Any]],
                       let dict = results.first,
                       let latestVersion = dict["version"] as? String,
                       let info = dict["releaseNotes"] as? String,
                       let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       latestVersion.compare(appVersion, options: .numeric) == .orderedDescending {
#if DEBUG
                        print("当前版本：\(appVersion)  app store 最新版本: \(latestVersion)")
#endif
                        DispatchQueue.main.async {
                            // 有新版本
                            if let forceUpdateUrl = self.forceUpdateUrl, !forceUpdateUrl.isEmpty {
                                // 有强制更新url
                                self.requestServerForUpdateWay(URL(string: forceUpdateUrl)!, currentVersion: appVersion, appStoreVersion: latestVersion, updateInfo: info, background: background)
                            } else {
                                self.showNew(version: latestVersion, info: info, background: background)
                            }
                        }
                    } else {
                        // 已经是最新版本
#if DEBUG
                        print("已经是最新版本")
#endif
                        if !background {
                            DispatchQueue.main.async {
                                self.showCurrentVersionIsLatestAlert()
                            }
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: - Private
    
    /// app ID
    private var appID: String? {
        didSet {
            guard let appID = appID, !appID.isEmpty else { return }
            let countryCode = Locale.current.regionCode?.lowercased() ?? ""
            appStoreUrl = "itms-apps://itunes.apple.com/cn/app/id" + appID
            appUpdateUrl = String(format: "http://itunes.apple.com/lookup?id=%@&country=%@", appID, countryCode)
            appIntroduceUrl = "https://apps.apple.com/cn/app/id" + appID
        }
    }
    /// 是否可以跳过当前更新版本
    private var isSkipEnable: Bool = false
    /// 强制更新xml文件地址
    private(set) var forceUpdateUrl: String?
    
    /// app应用商店地址
    private(set) var appStoreUrl: String?
    /// app更新地址
    private(set) var appUpdateUrl: String?
    /// app介绍
    private(set) var appIntroduceUrl: String?
    /// 解析xml的 delegate
    private var xmlDelegate = YLUpdateXMLParserDelegate()
    
    // MARK: 请求服务器，判断如何升级
    private func requestServerForUpdateWay(_ url: URL, currentVersion: String, appStoreVersion: String, updateInfo: String, background: Bool) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { [self] in
                if let data = data, error == nil  {
                    // xml 解析
                    let parser = XMLParser(data: data)
                    parser.delegate = xmlDelegate
                    parser.parse()
#if DEBUG
                    print("xml 内容:\n\(String(data: data, encoding: .utf8) ?? "")")
                    print("强制更新信息:\n\(xmlDelegate.update?.toJson() ?? [:])")
#endif
                    // 解析完成
                    if let update = xmlDelegate.update, update.BundleId == Bundle.main.bundleIdentifier {
                        // 解析成功
                        if let force = update.ForceUpdateToTheLatest, force {
                            // 强制升级到最新版
                            showForceUpdateAlert()
                            return
                        }
                        if let mini = update.MiniVersion, mini.compare(currentVersion, options: .numeric) == .orderedDescending {
                            // 低于设置的最小版本号
                            showForceUpdateAlert()
                            return
                        }
                        if let expiredDate = update.ExpiredDate, !expiredDate.isEmpty {
                            // 设置了过期时间
                            let formatter = DateFormatter()
                            formatter.locale = Locale(identifier: "en_US_POSIX")
                            formatter.dateFormat = "yyyy-MM-dd"
                            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
                            if let d = formatter.date(from: expiredDate), Date().timeIntervalSince(d) > 0 {
                                showDateExpiredAlert()
                                return
                            }
                        }
                        if let expiredOSVersion = update.ExpiredOSVersion, !expiredOSVersion.isEmpty {
                            // 设置了过期系统版本
                            let sv = ProcessInfo.processInfo.operatingSystemVersion
                            let sysVersion: String = String(format: "%ld.%ld.%ld", sv.majorVersion, sv.minorVersion, sv.patchVersion)
                            if sysVersion.compare(expiredOSVersion, options: .numeric) != .orderedAscending {
                                showOSVersionExpiredAlert()
                                return
                            }
                        }
                    }
                }
                // 普通升级
                showNew(version: appStoreVersion, info: updateInfo, background: background)
            }
        }.resume()
    }
    
    // MARK: 显示有新版本提示
    private func showNew(version: String, info: String, background: Bool) {
        if background,
           let skipVersion = UserDefaults.standard.string(forKey: "YLUpdateSkipVersion"),
           skipVersion == version {
            // 跳过
#if DEBUG
            print("设置了跳过该更新版本： \(version)")
#endif
            return
        }
        let wc = YLUpdateWindowController()
        wc.showNew(version: version, info: info, isSkipEnable: isSkipEnable && background)
        wc.window?.center()
        wc.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: 显示当前是最新版本
    private func showCurrentVersionIsLatestAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLUpdateManager.localize("Kind tips")
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            alert.informativeText = appVersion + " " + YLUpdateManager.localize("Latest version")
        } else {
            alert.informativeText = YLUpdateManager.localize("Latest version")
        }
        alert.addButton(withTitle: YLUpdateManager.localize("Sure"))
        alert.runModal()
    }
    
    // MARK: 显示强制升级
    private func showForceUpdateAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLUpdateManager.localize("Kind tips")
        alert.informativeText = YLUpdateManager.localize("Force Update Tips")
        alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
        alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            if let appStoreUrl = URL(string: appStoreUrl!) {
                NSWorkspace.shared.open(appStoreUrl)
            }
        }
        NSApp.terminate(nil)
    }
    
    /// 显示日期过期的alert弹窗
    private func showDateExpiredAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLUpdateManager.localize("Kind tips")
        alert.informativeText = String(format: YLUpdateManager.localize("Expire Tips"), YLUpdateManager.appName)
        alert.addButton(withTitle: YLUpdateManager.localize("Click to download"))
        alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
        if alert.runModal() == .alertFirstButtonReturn {
            if let appStoreUrl = URL(string: appStoreUrl!) {
                NSWorkspace.shared.open(appStoreUrl)
            }
        }
        NSApp.terminate(nil)
    }
    
    /// 显示系统版本过期的alert弹窗
    private func showOSVersionExpiredAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLUpdateManager.localize("Kind tips")
        alert.informativeText = String(format: YLUpdateManager.localize("OS Expire Tips"), YLUpdateManager.appName)
        alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
        alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
        if alert.runModal() == .alertFirstButtonReturn {
            if let appStoreUrl = URL(string: appStoreUrl!) {
                NSWorkspace.shared.open(appStoreUrl)
            }
        }
        NSApp.terminate(nil)
    }
    
    // MARK: - 国际化
    
    static func localize(_ key: String) -> String { Bundle(for: YLUpdateManager.self).localizedString(forKey: key, value: "", table: "YLUpdateManager") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}

