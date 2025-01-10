//
//  YLFileAccess.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/1/2.
//

import Foundation
import AppKit

public class YLFileAccess {
    
    public static let shared = YLFileAccess()
    private init() {}
    
    // MARK: - 加载访问权限
    
    /// 加载访问权限
    /// - Parameter filePath: 路径 path
    /// - Returns: 是否加载成功
    @discardableResult
    public func loadAccess(_ filePath: String) -> Bool {
        return loadAccess(URL(fileURLWithPath: filePath))
    }
    
    /// 加载访问权限
    /// - Parameter fileUrl: 路径 url
    /// - Returns: 是否加载成功
    @discardableResult
    public func loadAccess(_ fileUrl: URL) -> Bool {
        guard let data = bookmarkData(for: fileUrl) else { return false }
        return handleBookmarkData(data, for: fileUrl)
    }
    
    /// 加载所有的已获得的访问权限
    public func loadAllAccessPath() {
        let info = allBookmarksInfo()
        info.forEach { path, data in
            if let url = URL(string: path) {
                loadAccess(url)
            }
        }
    }
    
    // MARK: - 请求授权
    
    public func requestAccess(_ filePath: String, temp auth: Bool = false) -> Bool {
        return requestAccess(URL(fileURLWithPath: filePath), temp: auth)
    }
    
    public func requestAccess(_ fileUrl: URL, temp auth: Bool = false) -> Bool {
        var url = fileUrl.standardizedFileURL.resolvingSymlinksInPath()
        if let data = bookmarkData(for: url) {
            return handleBookmarkData(data, for: url)
        }
        // 未授权
        var path = url.path as NSString
        while path.length > 1 {
            if FileManager.default.fileExists(atPath: path as String) {
                break
            }
            path = path.deletingLastPathComponent as NSString
        }
        url = URL(fileURLWithPath: path as String)
        
        let delegate = YLFileAccessOpenPanelDelegate(url: url)
        let openPanel = NSOpenPanel()
        openPanel.message = String(format: YLFileAccess.localize("File access message"), YLFileAccess.appName)
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = YLFileAccess.localize("File access prompt")
        openPanel.title = YLFileAccess.localize("File access title")
        openPanel.showsHiddenFiles = false
        openPanel.isExtensionHidden = false
        openPanel.directoryURL = url
        openPanel.delegate = delegate
        NSApp.activate(ignoringOtherApps: true)
        if openPanel.runModal() == .OK, let allowUrl = openPanel.url {
            return startAccess(allowUrl, temp: auth)
        }
        return false
    }
    
    // MARK: - 取消授权
    
    public func cancelAccess(_ filePath: String) {
        cancelAccess(URL(fileURLWithPath: filePath))
    }
    
    public func cancelAccess(_ fileUrl: URL) {
        clearBookmarkData(for: fileUrl)
    }
    
    // MARK: - 私有方法
    
    // MARK: 处理已存储的授权数据
    private func handleBookmarkData(_ data: Data, for url: URL) -> Bool {
        do {
            var isStale: Bool = false
            let allowUrl = try URL(resolvingBookmarkData: data, options: [.withSecurityScope, .withoutUI], bookmarkDataIsStale: &isStale)
            
            if isStale {
                clearBookmarkData(for: url)
                return startAccess(allowUrl)
            } else {
                return allowUrl.startAccessingSecurityScopedResource()
            }
        } catch {
            print("Error resolving bookmark data: \(error)")
            clearBookmarkData(for: url)
            return false
        }
    }
    
    // MARK: 保存并开始访问授权
    private func startAccess(_ url: URL, temp auth: Bool = false) -> Bool {
        do {
            let data = try url.bookmarkData(options: .withSecurityScope)
            if !auth {
                saveBookmarkData(data, for: url)
            }
            return url.startAccessingSecurityScopedResource()
        } catch {
            print("Error saving bookmark data: \(error)")
            return false
        }
    }
    
    // MARK: - 数据存储与读取
    
    // MARK: 所有的授权数据
    private func allBookmarksInfo() -> Dictionary<String, Any> {
        UserDefaults.standard.object(forKey: "YLBookmarkDatas") as? Dictionary<String, Any> ?? [:]
    }
    
    // MARK: 获取授权数据
    private func bookmarkData(for url: URL) -> Data? {
        let all = allBookmarksInfo()
        return all[url.absoluteString] as? Data
    }
    
    // MARK: 清除授权数据
    private func clearBookmarkData(for url: URL) {
        var all = allBookmarksInfo()
        all.removeValue(forKey: url.absoluteString)
        UserDefaults.standard.set(all, forKey: "YLBookmarkDatas")
    }
    
    // MARK: 保存授权数据
    private func saveBookmarkData(_ data: Data, for url: URL) {
        var all = allBookmarksInfo()
        all[url.absoluteString] = data
        UserDefaults.standard.set(all, forKey: "YLBookmarkDatas")
    }
    
    // MARK: - 本地化
    
    static let bundle = Bundle(for: YLFileAccess.self)
    static func localize(_ key: String) -> String { YLFileAccess.bundle.localizedString(forKey: key, value: "", table: "YLFileAccess") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}


fileprivate class YLFileAccessOpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
    
    var paths: [String]
    init(url: URL) {
        self.paths = url.pathComponents
    }
    
    public func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        let urlPaths = url.pathComponents
        if urlPaths.count != paths.count {
            return false
        }
        
        for (index, path) in urlPaths.enumerated() {
            if path != paths[index] {
                return false
            }
        }
        return true
    }
}
