//
//  NSResponder+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/2/19.
//

import AppKit

fileprivate var SystemThemeChangedHandlerKey = false
fileprivate var AppThemeChangedHandlerKey = false
fileprivate var AppThemeObserverKey = false

public extension NSResponder {
    
    // MARK: - 监听系统亮色｜暗色切换 （ ⚠️ 在不需要的时候，设置为nil）
    var systemThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &SystemThemeChangedHandlerKey) as? (NSResponder, Bool) -> Void }
        set {
            objc_setAssociatedObject(self, &SystemThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                DistributedNotificationCenter.default().addObserver(self, selector: #selector(systemThemeChangedNotification), name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
                
            } else {
                DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
            }
        }
    }
    
    @objc private func systemThemeChangedNotification(){
        systemThemeChangedHandler?(self, systemIsDarkTheme)
    }
    
    /// 系统是暗色模式
    private var systemIsDarkTheme: Bool {
        let info = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        if let style = info?["AppleInterfaceStyle"] as? String {
            return style.caseInsensitiveCompare("dark") == .orderedSame
        }
        return false
    }
    
    // MARK: - 监听app 亮色｜暗色切换  (⚠️ 在不需要的时候，设置为nil）
    var appThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &AppThemeChangedHandlerKey) as? (NSResponder, Bool) -> Void }
        set {
            objc_setAssociatedObject(self, &AppThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                if !isAppObserverAdded {
                    NSApp.addObserver(self, forKeyPath: "effectiveAppearance", options: [.new], context: nil)
                    isAppObserverAdded = true
                }
            } else {
                if isAppObserverAdded {
                    NSApp.removeObserver(self, forKeyPath: "effectiveAppearance")
                    isAppObserverAdded = false
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "effectiveAppearance" {
            appThemeChangedHandler?(self, appIsDarkTheme)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    /// 是否已经设置监听app主题变化
    private var isAppObserverAdded: Bool {
        get { objc_getAssociatedObject(self, &AppThemeObserverKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AppThemeObserverKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// app是暗色模式
    private var appIsDarkTheme: Bool { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
}
