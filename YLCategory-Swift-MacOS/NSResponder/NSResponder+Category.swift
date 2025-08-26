//
//  NSResponder+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/2/19.
//

import AppKit

fileprivate var AppThemeChangedHandlerKey = false
fileprivate var AppThemeObserverKey = false
fileprivate var SystemThemeChangedHandlerKey = false
fileprivate var SystemThemeObserverKey = false

public extension NSResponder {
    
    // MARK: - 监听系统亮色｜暗色切换  (responder, isDark) -> Void
    var systemThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &SystemThemeChangedHandlerKey) as? (NSResponder, Bool) -> Void }
        set {
            objc_setAssociatedObject(self, &SystemThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                if objc_getAssociatedObject(self, &SystemThemeObserverKey) == nil {
                    let observer = YLThemeObserver(owner: self, observeSystem: true)
                    objc_setAssociatedObject(self, &SystemThemeObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            } else {
                objc_setAssociatedObject(self, &SystemThemeObserverKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: - 监听app 亮色｜暗色切换  (responder, isDark) -> Void
    var appThemeChangedHandler: ((NSResponder, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &AppThemeChangedHandlerKey) as? (NSResponder, Bool) -> Void }
        set {
            objc_setAssociatedObject(self, &AppThemeChangedHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                if objc_getAssociatedObject(self, &AppThemeObserverKey) == nil {
                    let observer = YLThemeObserver(owner: self, observeApp: true)
                    objc_setAssociatedObject(self, &AppThemeObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            } else {
                objc_setAssociatedObject(self, &AppThemeObserverKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

private class YLThemeObserver: NSObject {
    weak var owner: NSResponder?
    private var observeSystem: Bool
    private var observeApp: Bool
    private var kvoContext = 0
    
    init(owner: NSResponder, observeSystem: Bool = false, observeApp: Bool = false) {
        self.owner = owner
        self.observeSystem = observeSystem
        self.observeApp = observeApp
        super.init()
        
        if observeSystem {
            DistributedNotificationCenter.default().addObserver(
                self, selector: #selector(systemNotification),
                name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil
            )
        }
        if observeApp {
            NSApp.addObserver(self, forKeyPath: "effectiveAppearance", options: [.new], context: &kvoContext)
        }
    }
    
    deinit {
        if observeSystem {
            DistributedNotificationCenter.default().removeObserver(self)
        }
        if observeApp {
            NSApp.removeObserver(self, forKeyPath: "effectiveAppearance", context: &kvoContext)
        }
    }
    
    @objc private func systemNotification() {
        guard observeSystem, let owner = owner else { return }
        owner.systemThemeChangedHandler?(owner, systemIsDarkTheme)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard observeApp, let owner = owner else { return }
        if keyPath == "effectiveAppearance" {
            owner.appThemeChangedHandler?(owner, appIsDarkTheme)
        }
    }
    
    /// app是暗色模式
    private var appIsDarkTheme: Bool { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
    /// 系统是暗色模式
    private var systemIsDarkTheme: Bool {
        let info = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        if let style = info?["AppleInterfaceStyle"] as? String {
            return style.caseInsensitiveCompare("dark") == .orderedSame
        }
        return false
    }
}
