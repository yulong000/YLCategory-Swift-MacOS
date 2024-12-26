//
//  YLAppleReview.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

public class YLAppleReview {
    
    private static var shared = YLAppleReview()
    private var beginDate: Date?
    private var endDate: Date?
    
    /// 设置开始时间和结束时间
    /// - Parameters:
    ///   - begin: 开始时间字符串， 格式： yyyy-MM-dd HH:mm:ss
    ///   - end: 结束时间字符串， 格式： yyyy-MM-dd HH:mm:ss
    class func set(begin: String, end: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        YLAppleReview.shared.beginDate = formatter.date(from: begin)
        YLAppleReview.shared.endDate = formatter.date(from: end)
    }
    
    // MARK: 是否审核中
    static var isReviewing: Bool {
        guard let beginDate = YLAppleReview.shared.beginDate,
              let endDate = YLAppleReview.shared.endDate else { return false }
        return beginDate.timeIntervalSinceNow < 0 && endDate.timeIntervalSinceNow > 0
    }
    
}
