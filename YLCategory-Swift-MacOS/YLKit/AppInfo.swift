//
//  AppInfo.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit
import SystemConfiguration

/// app是暗黑模式
public var AppIsDarkTheme: Bool { NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
/// 系统是暗黑模式
public var SystemIsDarkTheme: Bool {
    let info = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
    if let style = info?["AppleInterfaceStyle"] as? String {
        return style.caseInsensitiveCompare("dark") == .orderedSame
    }
    return false
}
/// Document 路径
public var DocumentPath: String { NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "" }
/// Library 路径
public var LibraryPath: String { NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last ?? "" }
/// Cache 路径
public var CachePath: String { NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? "" }
/// app内文件的路径
public func BundlePath(_ fileName: String) -> String? { Bundle.main.path(forResource: fileName, ofType: nil) }

/// app版本号
public let APP_Version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
/// app build number
public let APP_Build_Number: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
/// app的本地化名字
public let App_Name: String = {
    let localizedInfo = Bundle.main.localizedInfoDictionary ?? [:]
    let info = Bundle.main.infoDictionary ?? [:]
    return  localizedInfo["CFBundleDisplayName"] as? String ??
            info["CFBundleDisplayName"] as? String ??
            localizedInfo["CFBundleName"] as? String ??
            info["CFBundleName"] as? String ?? ""
}()
/// 当前app的bundle ID
public let Bundle_Id: String = Bundle.main.bundleIdentifier ?? ""
/// 当前系统版本号
public let System_OS_Version = {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}()
/// 当前登录的用户名, 未登录用户时，返回nil
public var GUIUserName: String? {
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, nil, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    return userName
}
/// 当前登录的用户名(例如/Users/xxx/中的xxx，有可能跟 GUIUserName 不一样), 未登录用户时，返回nil
public var GUIUserDisplayName: String? {
    var uid: uid_t = 0
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, &uid, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    guard let pwd = getpwuid(uid),
          let home = pwd.pointee.pw_dir else {
        return nil
    }
    return String(cString: home).components(separatedBy: "/").last
}
/// 当前用户的名字 （/Users/xxx中的xxx）
public var UserName: String { GUIUserDisplayName ?? NSUserName() }
/// 当前用户的目录 （/Users/xxx）
public var UserHome: String {
    var uid: uid_t = 0
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, &uid, nil) as? String,
          userName != "loginWindow",
          let pwd = getpwuid(uid),
          let home = pwd.pointee.pw_dir else {
        return "/Users/\(NSUserName())"
    }
    return String(cString: home)
}
/// app的owner account ID, 从app store下载的一般是0，其他方式安装的是501，也有可能是其他值
public let OwnerAccountID: Int? = {
    guard let path = Bundle.main.executablePath,
          let attr = try? FileManager.default.attributesOfItem(atPath: path),
          let accountID = attr[.ownerAccountID] as? Int else {
        return nil
    }
    return accountID
}()

/// app是否安装
public func AppIsInstalled(_ bundleId: String) -> Bool {
    guard let url = AppUrl(bundleId) else { return false }
    return FileManager.default.fileExists(atPath: url.path)
}
/// 根据bundle ID获取app的安装路径
public func AppUrl(_ bundleId: String) -> URL? {
    if #available(macOS 12.0, *) {
        // 获取所有匹配 App 的 URL
        let urls = NSWorkspace.shared.urlsForApplications(withBundleIdentifier: bundleId)
        guard !urls.isEmpty else { return nil }
        
        // 过滤掉xcode下的app
        let filtered = urls.filter { !$0.path.contains("/Library/Developer/Xcode/") }
        
        // 按版本号排序（最新版本优先）
        let sortedByVersion = filtered.sorted { url1, url2 in
            let version1 = Bundle(url: url1)?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
            let version2 = Bundle(url: url2)?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
            return version1.compare(version2, options: .numeric) == .orderedDescending
        }
        
        // 优先 /Applications 下
        if let appInSystem = sortedByVersion.first(where: { $0.path.hasPrefix("/Applications") }) {
            return appInSystem
        }
        
        // 如果 /Applications 没有，则返回最新的其他路径
        return sortedByVersion.first
    } else {
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId),
              !appUrl.path.contains("/Library/Developer/Xcode/") else {
            return nil
        }
        return appUrl
    }
}
/// 获取某个app的版本号
public func AppVersion(_ bundleId: String) -> String? {
    return AppInfoValue(for: "CFBundleShortVersionString", bundleId: bundleId)
}
/// 根据bundle ID获取某个app的Info中的某个值
public func AppInfoValue(for key: String, bundleId: String) -> String? {
    guard let appUrl = AppUrl(bundleId) else { return nil }
    return AppInfoValue(for: key, appUrl: appUrl)
}
/// 根据app路径获取app的版本号
public func AppVersion(_ appUrl: URL) -> String? {
    return AppInfoValue(for: "CFBundleShortVersionString", appUrl: appUrl)
}
/// 根据app路径获取app的Info中的某个值
public func AppInfoValue(for key: String, appUrl: URL) -> String? {
    guard let bundle = Bundle(url: appUrl),
          let info = bundle.infoDictionary else {
        return nil
    }
    return info[key] as? String
}

/// app是否在运行
public func AppIsRunning(_ bundleId: String) -> Bool {
    !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
}


/// 根据名字打开app, 延迟一定的秒数，回调
/// - Parameters:
///   - name: app名字
///   - second: 延迟多少秒后回调
///   - handler: 回调方法
public func RunAppWithName(_ name: String, delay second: TimeInterval = 0, success handler: (() -> Void)? = nil) {
    for runningApp in NSWorkspace.shared.runningApplications {
        if let appName = runningApp.localizedName, name == appName {
            if second > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    handler?()
                }
            } else {
                handler?()
            }
            return
        }
    }
    if NSWorkspace.shared.launchApplication(name) {
        if second > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                handler?()
            }
        } else {
            handler?()
        }
    }
}


/// 根据 bundle id 打开app, 传入参数，回调
/// - Parameters:
///   - bundleID: bundle id
///   - arguments: 参数
///   - activates: 是否激活
///   - handler: 回调
public func RunAppWithBundleID(_ bundleID: String, arguments: [String]? = nil, activates: Bool = true, completion handler: ((Bool) -> Void)? = nil) {
    if !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty {
        // 已经在运行
        handler?(true)
        return
    }
    if #available(macOS 11.0, *) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            handler?(false)
            return
        }
        let config = NSWorkspace.OpenConfiguration()
        config.activates = activates
        config.arguments = arguments ?? []
        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { app, error in
            DispatchQueue.main.async {
                if let _ = app, error == nil {
                    handler?(true)
                } else {
                    handler?(false)
                }
            }
        }
    } else {
        let success = NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleID, options: activates ? .default : .withoutActivation, additionalEventParamDescriptor: nil, launchIdentifier: nil)
        handler?(success)
    }
}

