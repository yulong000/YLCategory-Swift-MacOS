//
//  YLUpdateManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import Foundation

public class YLUpdateManager: NSObject {
    
    public static let shared = YLUpdateManager()
    private override init() {}
    
    /// 设置更新参数
    /// - Parameters:
    ///   - appID: app store版本（沙盒）的app ID
    ///   - xml: app store版本的强制更新配置链接（下载XML配置文件，根据配置参数判断）
    ///         "Name" :  "xxx"                                      app名字,
    ///         "BundleId": "com.xxxx.xxxx"                  app的bundle Id,
    ///         "MiniVersion":  "1.0.0"                            可以使用的最小版本号，小于该版本号，需要强制升级
    ///         "ForceUpdateToTheLastest":  false       是否强制更新到最新版本
    ///   - url: 线下 版本（非沙盒）的更新链接（下载完整app）
    public func set(appID: String? = nil, forceUpdate xml: String? = nil, sparkleUpdate url: String? = nil) {
        if isSandbox {
            // 沙盒，app store版本
            if let appID = appID, let appStoreUpdater = updater as? YLAppStoreUpdater {
                appStoreUpdater.appID = appID
                appStoreUpdater.updateUrl = xml
            }
        } else {
            if let sparkleUpdater = updater as? YLSparkleUpdater {
                sparkleUpdater.updateUrl = url
            }
        }
    }
    
    /// 检测更新
    /// - Parameter background: 是否后台检测, background = true时，无新版本，则不弹窗提醒
    public func checkForUpdates(background: Bool = true) {
        updater.checkForUpdates(background: background)
    }
    
    /// 根据日期和系统版本，判断试用到期
    /// - Parameters:
    ///   - date: 过期日期 yyyy-MM-dd
    ///   - osVersion: 过期系统版本号 6.0.0
    public func judgeAppExpire(date: String? = nil, osVersion: String? = nil) {
        updater.judgeAppExpire(date: date, osVersion: osVersion)
    }
    
    /// 更新器
    lazy var updater: YLUpdater = isSandbox ? YLAppStoreUpdater() : YLSparkleUpdater()
    /// 是否是沙盒
    private let isSandbox: Bool = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil

    // MARK: - 国际化
    
    static func localize(_ key: String) -> String { Bundle(for: YLUpdateManager.self).localizedString(forKey: key, value: "", table: "YLUpdateManager") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}

