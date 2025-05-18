//
//  YLUpdater.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/5/18.
//

import AppKit
import Sparkle

class YLUpdater: NSObject {
    
    /// 更新内容地址
    var updateUrl: String?
    
    /// 检测更新
    /// - Parameter background: 是否后台检测, background = true时，无新版本，则不弹窗提醒
    func checkForUpdates(background: Bool = true) {}
    
    /// 根据日期和系统版本，判断试用到期
    /// - Parameters:
    ///   - date: 过期日期 yyyy-MM-dd
    ///   - osVersion: 过期系统版本号 6.0.0
    func judgeAppExpire(date: String? = nil, osVersion: String? = nil) {}
    
    
    /// 显示日期过期的alert弹窗
    /// - Parameter updateUrl: 更新地址
    func showDateExpiredAlert(date: String, updateUrl: String?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        if let d = formatter.date(from: date), Date().timeIntervalSince(d) > 0 {
            // 过期了
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NSApp.activate(ignoringOtherApps: true)
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = YLUpdateManager.localize("Kind tips")
                alert.informativeText = String(format: YLUpdateManager.localize("Expire Tips"), YLUpdateManager.appName)
                alert.addButton(withTitle: YLUpdateManager.localize("Click to download"))
                alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
                if alert.runModal() == .alertFirstButtonReturn {
                    if let updateUrl = updateUrl {
                        NSWorkspace.shared.open(URL(string: updateUrl)!)
                    }
                }
                NSApp.terminate(nil)
            }
        }
    }
    
    
    /// 显示系统版本过期的alert弹窗
    /// - Parameter updateUrl: 更新地址
    func showOSVersionExpiredAlert(osVersion: String, updateUrl: String?) {
        let sv = ProcessInfo.processInfo.operatingSystemVersion
        let sysVersion: String = String(format: "%ld.%ld.%ld", sv.majorVersion, sv.minorVersion, sv.patchVersion)
        if sysVersion.compare(osVersion, options: .numeric) != .orderedAscending {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // 大于等于设置的系统版本号
                NSApp.activate(ignoringOtherApps: true)
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = YLUpdateManager.localize("Kind tips")
                alert.informativeText = String(format: YLUpdateManager.localize("OS Expire Tips"), YLUpdateManager.appName)
                alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
                alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
                if alert.runModal() == .alertFirstButtonReturn {
                    if let updateUrl = updateUrl {
                        NSWorkspace.shared.open(URL(string: updateUrl)!)
                    }
                }
                NSApp.terminate(nil)
            }
        }
    }
}

class YLAppStoreUpdater: YLUpdater {
    /// app ID
    var appID: String? {
        didSet {
            guard let appID = appID, !appID.isEmpty else { return }
            let countryCode = Locale.current.regionCode?.lowercased() ?? ""
            appStoreUrl = "itms-apps://itunes.apple.com/cn/app/id" + appID
            appUpdateUrl = String(format: "http://itunes.apple.com/lookup?id=%@&country=%@", appID, countryCode)
            appIntroduceUrl = "https://apps.apple.com/cn/app/id" + appID
        }
    }
    
    // MARK: - app store 版本，根据app ID生成的链接
    
    /// app应用商店地址
    private(set) var appStoreUrl: String?
    /// app更新地址
    private(set) var appUpdateUrl: String?
    /// app介绍
    private(set) var appIntroduceUrl: String?
    
    // MARK: - 升级提醒
    
    private var xmlDelegate = YLUpdateXMLParserDelegate()
    
    override func checkForUpdates(background: Bool = true) {
        guard let appID = appID, !appID.isEmpty else { return }
        let task = URLSession.shared.dataTask(with: URL(string: appUpdateUrl!)!) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                    DispatchQueue.main.async {
                        if let resultCount = resp["resultCount"] as? Int, resultCount > 0,
                           let results = resp["results"] as? [[String : Any]],
                           let dict = results.first,
                           let lastestVersion = dict["version"] as? String,
                           let info = dict["releaseNotes"] as? String,
                           let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           lastestVersion.compare(appVersion, options: .numeric) == .orderedDescending {
#if DEBUG
                            print("当前版本：\(appVersion)  app store 最新版本: \(lastestVersion)")
#endif
                            // 有新版本
                            if let updateUrl = self.updateUrl, !updateUrl.isEmpty {
                                // 有强制更新url
                                let dataTask = URLSession.shared.dataTask(with: URL(string: updateUrl)!) { data, response, error in
                                    DispatchQueue.main.async { [self] in
                                        if let data = data, error == nil  {
                                            // xml 解析
                                            let parser = XMLParser(data: data)
                                            parser.delegate = xmlDelegate
                                            parser.parse()
#if DEBUG
                                            print("强制更新信息：\(xmlDelegate.update?.toJson() ?? [:])")
#endif
                                            // 解析完成
                                            if let update = xmlDelegate.update, update.BundleId == Bundle.main.bundleIdentifier {
                                                // 解析成功
                                                if update.ForceUpdateToTheLastest || update.MiniVersion?.compare(appVersion, options: .numeric) == .orderedDescending {
                                                    // 强制升级到最新版
                                                    NSApp.activate(ignoringOtherApps: true)
                                                    let alert = NSAlert()
                                                    alert.alertStyle = .warning
                                                    alert.messageText = YLUpdateManager.localize("Kind tips")
                                                    alert.informativeText = YLUpdateManager.localize("Force Update Tips")
                                                    alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
                                                    alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
                                                    let result = alert.runModal()
                                                    if result == .alertFirstButtonReturn {
                                                        // 升级
                                                        if let appStoreUrl = URL(string: appStoreUrl!) {
                                                            NSWorkspace.shared.open(appStoreUrl)
                                                        }
                                                    }
                                                    NSApp.terminate(nil)
                                                    return
                                                }
                                            }
                                        }
                                        // 普通升级
                                        let wc = YLUpdateWindowController()
                                        wc.showNew(version: lastestVersion, info: info)
                                        wc.window?.makeKeyAndOrderFront(nil)
                                        NSApp.activate(ignoringOtherApps: true)
                                    }
                                }
                                dataTask.resume()
                            } else {
                                let wc = YLUpdateWindowController()
                                wc.showNew(version: lastestVersion, info: info)
                                wc.window?.makeKeyAndOrderFront(nil)
                                NSApp.activate(ignoringOtherApps: true)
                            }
                        } else {
                            // 已经是最新版本
#if DEBUG
                            print("已经是最新版本")
#endif
                            if !background {
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
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: - 过期判断
    
    override func judgeAppExpire(date: String? = nil, osVersion: String? = nil) {
        guard let _ = appID else { return }
        if let date = date, !date.isEmpty {
            // 传的有日期
            showDateExpiredAlert(date: date, updateUrl: appStoreUrl)
            return
        }
        if let osVersion = osVersion, !osVersion.isEmpty {
            // 传的有版本号
            showOSVersionExpiredAlert(osVersion: osVersion, updateUrl: appStoreUrl)
        }
    }
}

class YLSparkleUpdater: YLUpdater, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    
    /// 检测更新控制器
    private lazy var updateController: SPUStandardUpdaterController = {
        let controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: self)
        controller.updater.automaticallyChecksForUpdates = true
        return controller
    }()
    
    // MARK: - 检测更新
    override func checkForUpdates(background: Bool = true) {
        if background {
            updateController.updater.checkForUpdatesInBackground()
        } else {
            updateController.checkForUpdates(nil)
        }
    }
    
    // MARK: sparkle delegate
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        print("Sparkle 获取xml文件成功: \(appcast.items.first?.propertiesDictionary ?? [:])")
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        print("Sparkle 暂无更新");
    }
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        print("Sparkle 有可用升级:\nVersion: \(item.displayVersionString)\nBuild number: \(item.versionString)\nUrl:\(item.fileURL?.absoluteString ?? "")\nNote: \(item.itemDescriptionFormat ?? "")")
    }
    
    func updater(_ updater: SPUUpdater, userDidMake choice: SPUUserUpdateChoice, forUpdate updateItem: SUAppcastItem, state: SPUUserUpdateState) {
        switch (choice) {
        case .skip:     print("Sparkle 用户点击 跳过这个版本");
        case .install:  print("Sparkle 用户点击 安装更新");
        case .dismiss:  print("Sparkle 用户点击 稍后提醒");
        default: break;
        }
    }
    
    // MARK: - 过期判断
    override func judgeAppExpire(date: String? = nil, osVersion: String? = nil) {
        if let date = date, !date.isEmpty {
            // 传的有日期
            showDateExpiredAlert(date: date, updateUrl: updateUrl)
            return
        }
        if let osVersion = osVersion, !osVersion.isEmpty {
            // 传的有版本号
            showOSVersionExpiredAlert(osVersion: osVersion, updateUrl: updateUrl)
        }
    }
}
