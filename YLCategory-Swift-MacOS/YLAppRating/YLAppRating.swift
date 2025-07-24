//
//  YLAppRating.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation
import StoreKit

public class YLAppRating {
    
    private static let YLAppRatingKey = "YLAppRating"
    private static let AppRateFirstLaunchTimeKey = "AppRateFirstLaunchTime"
    private static let AppRateExecCountKey = "AppRateExecCount"
    private static let AppRateLastShowTimeKey = "AppRateLastShowTime"
    
    /// App评分弹窗
    /// - Parameters:
    ///   - appID: app ID
    ///   - minExecCount: 最小执行次数，超过这个值，才会真正执行评分弹窗代码
    ///   - daysSinceFirstLaunch: 从第一次启动，到执行弹窗，最少间隔的天数，防止一上来就弹窗，需与minExecCount同时满足
    ///   - daysSinceLastPrompt: 从上次一执行弹窗代码，到下一次执行弹窗代码，中间最少间隔的天数，需与minExecCount同时满足
    ///   - delayInSeconds: 执行弹窗代码的延时操作，防止一打开app就弹窗
    public class func showWith(appID: String,
                               minExecCount: Int = 10,
                               daysSinceFirstLaunch: Int = 3,
                               daysSinceLastPrompt: Int = 365,
                               delayInSeconds: TimeInterval = 10) {
        // 检查是否从 App Store 下载
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            return
        }
        
        let userDefaults = UserDefaults.standard
        var info = userDefaults.object(forKey: YLAppRatingKey) as? [String: Any] ?? [:]
        
        // 第一次执行时间
        var firstLaunchTime = info[AppRateFirstLaunchTimeKey] as? Double ?? 0
        if firstLaunchTime == 0 {
            firstLaunchTime = Date().timeIntervalSince1970
            info[AppRateFirstLaunchTimeKey] = firstLaunchTime
        }
        
        // 执行次数
        var execCount = info[AppRateExecCountKey] as? Int ?? 0
        execCount += 1
        info[AppRateExecCountKey] = execCount
        userDefaults.set(info, forKey: YLAppRatingKey)
        userDefaults.synchronize()
        if execCount < minExecCount {
#if DEBUG
            print("App评分 - 当前执行次数：\(execCount) 未达到 \(minExecCount) 次, 直接返回")
#endif
            return
        }
        
        let currentTime = Date().timeIntervalSince1970
        
        // 判断与第一次执行的时间间隔
        if currentTime - firstLaunchTime < 60 * 60 * 24 * Double(daysSinceFirstLaunch) {
            let daysSinceFirst = (currentTime - firstLaunchTime) / (24.0 * 60 * 60)
#if DEBUG
            print("App评分 - 从第一次执行至今，已经 \(daysSinceFirst) 天，未超过 \(daysSinceFirstLaunch) 天，直接返回")
#endif
            return
        }
        
        // 判断与上一次弹窗的时间间隔
        let lastShowTime = info[AppRateLastShowTimeKey] as? Double ?? 0
        if lastShowTime > 0 && currentTime - lastShowTime < 60 * 60 * 24 * Double(daysSinceLastPrompt) {
            let daysSinceLast = (currentTime - lastShowTime) / (24.0 * 60 * 60)
#if DEBUG
            print("App评分 - 从上一次执行评分弹窗至今，已经 \(daysSinceLast) 天，未超过 \(daysSinceLastPrompt) 天，直接返回")
#endif
            return
        }
        
        // 延迟后执行评分弹窗
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            info[AppRateLastShowTimeKey] = currentTime + Double(delayInSeconds)
            info[AppRateExecCountKey] = 0
            userDefaults.set(info, forKey: YLAppRatingKey)
            userDefaults.synchronize()
            if #available(macOS 15.0, *) {
                // macOS 15 及以上支持输入中文
                SKStoreReviewController.requestReview()
            } else {
                // 跳转到 App Store 的评分页面
                let appStoreReviewPath = "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"
                if let url = URL(string: appStoreReviewPath) {
                    NSWorkspace.shared.open(url)
                }
            }
#if DEBUG
            print("App评分 - 执行了弹窗评分")
#endif
        }
    }
}
