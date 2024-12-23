//
//  NSResponder+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation

fileprivate var SystemThemeChangedHandlerKey = false
fileprivate var AppThemeChangedHandlerKey = false

public extension NSResponder {
    
    // MARK: 系统是暗色模式
    private var isSystemDarkTheme: Bool {
        let dict = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        let style = dict?["AppleInterfaceStyle"] as? String
        return style?.caseInsensitiveCompare("dark") == .orderedSame
    }
    // MARK: app是暗色模式
    private var isAppDarkTheme: Bool { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
    
    // MARK: 监听系统亮色｜暗色模式变化
    var systemThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &SystemThemeChangedHandlerKey) as? ((NSResponder, Bool) -> Void) }
        set {
            objc_setAssociatedObject(self, &SystemThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            let center = DistributedNotificationCenter.default()
            center.removeObserver(self, name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
            if newValue != nil {
                center.addObserver(self, selector: #selector(systemThemeChanged), name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
            }
        }
    }
    
    @objc private func systemThemeChanged() {
        systemThemeChangedHandler?(self, isSystemDarkTheme)
    }
    
    // MARK: 监听App亮色｜暗色模式变化
    var appThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &AppThemeChangedHandlerKey) as? ((NSResponder, Bool) -> Void) }
        set {
            objc_setAssociatedObject(self, &AppThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            NSApp.removeObserver(self, forKeyPath: "effectiveAppearance")
            if newValue != nil {
                NSApp.addObserver(self, forKeyPath: "effectiveAppearance", options: .new, context: nil)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "effectiveAppearance" {
            appThemeChangedHandler?(self, isAppDarkTheme)
        }
    }
}
