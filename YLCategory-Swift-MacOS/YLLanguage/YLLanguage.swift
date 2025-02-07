//
//  YLLanguage.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Cocoa

// 应用语言类型枚举
@objc public enum LanguageType: UInt8 {
    case system                    // 跟随系统
    case chineseSimplified         // 简体中文
    case chineseTraditional        // 繁体中文
    case english                   // 英语
    case japanese                  // 日语
    case korean                    // 韩语
    case french                    // 法语
    case spanish                   // 西班牙语
    case portuguese                // 葡萄牙语
    case german                    // 德语
}

public class YLLanguage {
    
    /// 所有的语言
    public class var allLanguages: [YLLanguageModel] {
        [
            YLLanguageModel(type: .system),
            YLLanguageModel(type: .chineseSimplified),
            YLLanguageModel(type: .chineseTraditional),
            YLLanguageModel(type: .english),
            YLLanguageModel(type: .japanese),
            YLLanguageModel(type: .korean),
            YLLanguageModel(type: .french),
            YLLanguageModel(type: .spanish),
            YLLanguageModel(type: .portuguese),
            YLLanguageModel(type: .german),
        ]
    }
    
    /// 当前语言类型
    public class var currentType: LanguageType {
        var type: LanguageType = .system
        if let current = Bundle.main.preferredLocalizations.first {
            for model in YLLanguage.allLanguages {
                if model.code == current {
                    type = model.languageType
                    break
                }
            }
        }
        return type
    }
    
    /// 根据语言类型获取code
    public class func code(for type: LanguageType) -> String {
        var code = ""
        switch type {
        case .chineseSimplified:    code = "zh-Hans"
        case .chineseTraditional:   code = "zh-Hant"
        case .english:              code = "en"
        case .japanese:             code = "ja"
        case .korean:               code = "ko"
        case .spanish:              code = "es"
        case .french:               code = "fr"
        case .portuguese:           code = "pt-PT"
        case .german:               code = "de"
        default: break
        }
        return code
    }
    
    /// 设置app语言
    /// - Parameters:
    ///   - model: 语言模型
    ///   - type: 原来的语言类型
    ///   - action: 设置完成后，重启app之前，执行的代码
    public class func set(language model: YLLanguageModel, from type: LanguageType, beforeRestart action: (() -> Void)? = nil) {
        if model.languageType == type { return }
        if model.languageType == .system {
            // 跟随系统
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            // 指定语言
            UserDefaults.standard.set([model.code], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        if let action = action { action() }
        restartApp()
    }
    
    /// 设置app的语言类型
    /// - Parameters:
    ///   - languageType: 语言类型
    ///   - restart: 是否重启app
    public class func set(languageType: LanguageType, restart: Bool) {
        if languageType == .system {
            // 跟随系统
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            // 指定语言
            UserDefaults.standard.set([YLLanguage.code(for: languageType)], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        if restart {
            restartApp()
        }
    }
    
    // MARK: 重启app
    private class func restartApp() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLLanguage.localize("Kind tips")
        alert.informativeText = YLLanguage.localize("Restart app tips")
        alert.addButton(withTitle: YLLanguage.localize("Restart"))
        alert.addButton(withTitle: YLLanguage.localize("Cancel"))
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // 重启
            let bundlePath = Bundle.main.bundlePath
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-n", bundlePath]
            do {
                try task.run()
                NSApplication.shared.terminate(nil)
            } catch {
                print("重启app失败:\(error)")
            }
        }
    }
    
    static let bundle = Bundle(for: YLLanguage.self)
    static func localize(_ key: String) -> String { YLLanguage.bundle.localizedString(forKey: key, value: "", table: "YLLanguage") }
}
