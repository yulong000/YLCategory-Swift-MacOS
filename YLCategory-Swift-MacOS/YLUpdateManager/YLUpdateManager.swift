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
    ///   当有新版本时，从该链接获取配置信息，来判断是否强制更新
    ///         "Name" :  "xxx"                                      app名字,
    ///         "BundleId": "com.xxxx.xxxx"                  app的bundle Id,
    ///         "ForceUpdateToTheLatest":  false        是否强制更新到最新版本
    ///         "MiniVersion":  "1.0.0"                           可以使用的最小版本号，小于该版本号，需要强制升级
    ///         "ExpiredDate":  "2025-10-30"                过期时间
    ///         "ExpiredOSVersion":  "17.0"                  过期的系统版本号
    ///         4个判断条件，优先级从上往下递减
    ///   - url: 线下版本（非沙盒）的更新链接（下载完整app）
    public func set(appID: String? = nil, forceUpdate xml: String? = nil, sparkleUpdate url: String? = nil) {
        if YLUpdateManager.isSandbox {
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
    
    /// 更新器
    lazy var updater: YLUpdater = YLUpdateManager.isSandbox ? YLAppStoreUpdater() : YLSparkleUpdater()
    /// 是否是沙盒
    static let isSandbox: Bool = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil

    // MARK: - 国际化
    
    static func localize(_ key: String) -> String { Bundle(for: YLUpdateManager.self).localizedString(forKey: key, value: "", table: "YLUpdateManager") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}

