//
//  NSDate+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/25.
//

import Foundation

public enum Weekday: String {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    func text(type: Int = 0) -> String {
        var text = ""
        switch self {
        case .monday:       text = type == 0 ? "周一" : "星期一"
        case .tuesday:      text = type == 0 ? "周二" : "星期二"
        case .wednesday:    text = type == 0 ? "周三" : "星期三"
        case .thursday:     text = type == 0 ? "周四" : "星期四"
        case .friday:       text = type == 0 ? "周五" : "星期五"
        case .saturday:     text = type == 0 ? "周六" : "星期六"
        case .sunday:       text = type == 0 ? "周日" : "星期日"
        }
        return text
    }
}

public extension Date {
    
    // MARK: 年
    var year: Int { dateComponents().year! }
    
    // MARK: 月
    var month: Int { dateComponents().month! }
    
    // MARK: 周
    var week: Int { (day == 1 && month == 1) ? 1 : dateAdd(days: -1).dateComponents().weekOfYear! }
    
    // MARK: 本周的第几天，周日 = 1
    var weekday: Weekday { Weekday(rawValue: stringValue(format: "EEEE"))! }
    
    // MARK: 日
    var day: Int { dateComponents().day! }
    
    // MARK: 时
    var hour: Int { dateComponents().hour! }
    
    // MARK: 分
    var minute: Int { dateComponents().minute! }
    
    // MARK: 秒
    var second: Int { dateComponents().second! }
    
    // MARK: 根据日期格式和字符串，创建日期实例
    static func date(string: String, format: String, chinaTimeZone: Bool = false) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        if chinaTimeZone { formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") }
        return formatter.date(from: string)
    }
    
    // MARK: 根据时间戳，返回格式化的字符串
    static func dateString(timeInterval: TimeInterval, format: String) -> String {
        Date(timeIntervalSince1970: timeInterval).stringValue(format: format)
    }
    
    // MARK: 将日期转换成字符串
    func stringValue(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // MARK: 获取日期所在月的第一天
    func firstDayOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? self
    }
    
    // MARK: 获取日期所在月的最后一天
    func lastDayOfMonth() -> Date {
        if let end = Calendar.current.dateInterval(of: .month, for: self)?.end {
            return Calendar.current.date(byAdding: .day, value: -1, to: end) ?? self
        }
        return self
    }
    
    // MARK: 获取当月的第一天
    static func firstDayOfCurrentMonth() -> Date {
        Date().firstDayOfMonth()
    }
    
    // MARK: 获取当月的最后一天
    static func lastDayOfCurrentMonth() -> Date {
        Date().lastDayOfMonth()
    }
    
    // MARK: 上个月的这一天
    func dayOfPreviousMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    // MARK: 下个月的这一天
    func dayOfNextMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
    
    // MARK: 当前年有多少天
    func daysOfYear() -> Int { Date.daysInYear(year) }
    
    // MARK: 传入的年份有多少天
    static func daysInYear(_ year: Int) -> Int {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let startOfNextYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        return calendar.dateComponents([.day], from: startOfYear, to: startOfNextYear).day!
    }
    
    // MARK: 当前月有多少天
    func dayCountOfMonth() -> Int {
        Calendar.current.range(of: .day, in: .month, for: self)!.count
    }
    
    // MARK: 获取当前周的日期
    func daysForWholeWeek() -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let offset = calendar.firstWeekday == 1 ? weekday - 2 : weekday - 1
        let startOfWeek = calendar.date(byAdding: .day, value: -offset, to: self)!
        var weekDates: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                weekDates.append(day)
            }
        }
        return weekDates
    }
    
    // MARK: 当前日期+天数的日期
    func dateAdd(days count: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: count, to: self)!
    }
    
    // MARK: 当前日期是本月第几周
    func weekIndexOfMonth() -> Int { dateComponents().weekOfMonth! }
    
    // MARK: 当前日期的前一天
    func yesterday() -> Date { dateAdd(days: -1) }
    
    // MARK: 同一年
    func sameYear(with date: Date) -> Bool { year == date.year }
    
    // MARK: 同年同月
    func sameMonth(with date: Date) -> Bool { sameYear(with: date) && month == date.month }
    
    // MARK: 同年同月同周
    func sameWeek(with date: Date) -> Bool { sameMonth(with: date) && week == date.week }
    
    // MARK: 同年同月同日
    func sameDay(with date: Date) -> Bool { sameMonth(with: date) && day == date.day }
    
    // MARK: 同年同月同日同时
    func sameHour(with date: Date) -> Bool { sameDay(with: date) && hour == date.hour }
    
    // MARK: 同年同月同日同时同分
    func sameMinute(with date: Date) -> Bool { sameHour(with: date) && minute == date.minute }
    
    private func dateComponents() -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .weekday, .weekOfYear, .weekOfMonth, .hour, .minute, .second], from: self)
    }
}
