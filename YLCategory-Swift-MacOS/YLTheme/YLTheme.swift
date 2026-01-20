//
//  YLTheme.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/1/20.
//

import AppKit

// 应用语言类型枚举
@objc public enum ThemeType: UInt8 {
    case system     // 跟随系统
    case light      // 亮色
    case dark       // 暗色
    
    var title: String {
        switch self {
        case .system:   YLTheme.localize("Follow System")
        case .light:    YLTheme.localize("Light")
        case .dark:     YLTheme.localize("Dark")
        }
    }
}

public class YLTheme {
    
    /// 所有的主题
    public class var allThemeTitles: [String] {
        [
            ThemeType.system.title,
            ThemeType.light.title,
            ThemeType.dark.title
        ]
    }
    
    /// 根据标题获取主题类型
    public class func type(with title: String) -> ThemeType {
        switch title {
        case YLTheme.localize("Follow System"): return .system
        case YLTheme.localize("Light"):         return .light
        case YLTheme.localize("Dark"):          return .dark
        default:                                return .system
        }
    }
    
    // MARK: 设置主题
    public class func set(theme type: ThemeType) {
        switch type {
        case .system:   NSApp.appearance = nil
        case .light:    NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:     NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
    
    static let bundle = Bundle(for: YLTheme.self)
    static func localize(_ key: String) -> String { YLTheme.bundle.localizedString(forKey: key, value: "", table: "YLTheme") }
}
