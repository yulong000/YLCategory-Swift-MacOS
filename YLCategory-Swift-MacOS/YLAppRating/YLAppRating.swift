//
//  YLAppRating.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation
import StoreKit

public class YLAppRating {
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
    static func showWith(appID: String,
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
        
        // 第一次执行时间
        var firstLaunchTime = userDefaults.double(forKey: AppRateFirstLaunchTimeKey)
        if firstLaunchTime == 0 {
            firstLaunchTime = Date().timeIntervalSince1970
            userDefaults.set(firstLaunchTime, forKey: AppRateFirstLaunchTimeKey)
        }
        
        // 执行次数
        var execCount = userDefaults.integer(forKey: AppRateExecCountKey)
        execCount += 1
        userDefaults.set(execCount, forKey: AppRateExecCountKey)
        if execCount < minExecCount {
            userDefaults.synchronize()
            print("App评分 - 当前执行次数：\(execCount) 未达到 \(minExecCount) 次, 直接返回")
            return
        }
        
        let currentTime = Date().timeIntervalSince1970
        
        // 判断与第一次执行的时间间隔
        if currentTime - firstLaunchTime < 60 * 60 * 24 * Double(daysSinceFirstLaunch) {
            userDefaults.synchronize()
            let daysSinceFirst = (currentTime - firstLaunchTime) / (24.0 * 60 * 60)
            print("App评分 - 从第一次执行至今，已经 \(daysSinceFirst) 天，未超过 \(daysSinceFirstLaunch) 天，直接返回")
            return
        }
        
        // 判断与上一次弹窗的时间间隔
        let lastShowTime = userDefaults.double(forKey: AppRateLastShowTimeKey)
        if lastShowTime > 0 && currentTime - lastShowTime < 60 * 60 * 24 * Double(daysSinceLastPrompt) {
            userDefaults.synchronize()
            let daysSinceLast = (currentTime - lastShowTime) / (24.0 * 60 * 60)
            print("App评分 - 从上一次执行评分弹窗至今，已经 \(daysSinceLast) 天，未超过 \(daysSinceLastPrompt) 天，直接返回")
            return
        }
        
        // 延迟后执行评分弹窗
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            userDefaults.set(currentTime + Double(delayInSeconds), forKey: AppRateLastShowTimeKey)
            userDefaults.set(0, forKey: AppRateExecCountKey)
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
            print("App评分 - 执行了弹窗评分")
        }
    }
}
