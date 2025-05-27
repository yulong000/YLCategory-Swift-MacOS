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
    
    // 是否显示根路径授权按钮
    public var allowRootOption: Bool = false
    
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
    
    /// 请求对路径授权
    /// - Parameters:
    ///   - filePath: 路径
    ///   - auth: 是否是临时授权
    /// - Returns: 授权是否成功
    public func requestAccess(_ filePath: String, temp auth: Bool = false) -> Bool {
        return requestAccess(URL(fileURLWithPath: filePath), temp: auth)
    }
    
    public func requestAccess(_ fileUrl: URL, temp auth: Bool = false) -> Bool {
        guard let model = createOpenPanel(fileUrl) else { return true }
        NSApp.activate(ignoringOtherApps: true)
        if model.openPanel.runModal() == .OK, let allowUrl = model.openPanel.url {
            return startAccess(allowUrl, temp: auth)
        }
        return false
    }
    
    /// 请求对路径授权，附带根路径授权功能
    /// - Parameters:
    ///   - filePath: 路径
    ///   - auth: 是否是临时授权
    ///   - completion: 授权后的回调
    public func requestAccess(_ filePath: String, temp auth: Bool = false, completion: @escaping (Bool) -> Void) {
        requestAccess(URL(fileURLWithPath: filePath), temp: auth, completion: completion)
    }
    
    public func requestAccess(_ fileUrl: URL, temp auth: Bool = false, completion: @escaping (Bool) -> Void) {
        guard let model = createOpenPanel(fileUrl) else {
            completion(true)
            return
        }
        openPanelModel = model
        openPanelModel?.completionHandler = completion
        openPanelModel?.tempAuth = auth
        if openPanelModel?.delegate.url.path != "/" && allowRootOption {
            // 授权根目录
            let btn = NSButton(title: YLFileAccess.localize("Authorization root directory"), target: self, action: #selector(authRootPath))
            btn.bezelColor = .controlAccentColor
            let message = NSTextField(wrappingLabelWithString: String(format: YLFileAccess.localize("Authorization root directory message"), YLFileAccess.appName))
            
            btn.sizeToFit()
            message.sizeToFit()
            
            let accessoryView = NSView()
            accessoryView.frame = NSMakeRect(0, 0, btn.bounds.width + message.bounds.width + 150, message.bounds.height + 30)
            
            btn.frame = NSMakeRect(5, (accessoryView.bounds.height - btn.bounds.height) / 2 - 2, btn.bounds.width, btn.bounds.height)
            message.frame = NSMakeRect(CGRectGetMaxX(btn.frame) + 10, (accessoryView.bounds.height - message.bounds.height) / 2, message.bounds.width, message.bounds.height)
            
            accessoryView.addSubview(btn)
            accessoryView.addSubview(message)
            
            openPanelModel?.openPanel.accessoryView = accessoryView
            openPanelModel?.openPanel.isAccessoryViewDisclosed = true
        }
        NSApp.activate(ignoringOtherApps: true)
        openPanelModel?.openPanel.begin { [self] result in
            if result == .OK, let allowUrl = openPanelModel?.openPanel.url {
                let success = startAccess(allowUrl, temp: openPanelModel?.tempAuth ?? false)
                completion(success)
            } else {
                completion(false)
            }
            self.openPanelModel = nil
        }
    }
    
    // MARK: - private
    
    private var openPanelModel: YLFileAccessOpenPanelModel?
    
    // MARK: 创建一个openPanel，如果已经授权，返回nil
    private func createOpenPanel(_ fileUrl: URL) -> YLFileAccessOpenPanelModel? {
        var url = fileUrl.standardizedFileURL.resolvingSymlinksInPath()
        if let data = bookmarkData(for: url), handleBookmarkData(data, for: url) {
            // 已经授权
            return nil
        }
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
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = YLFileAccess.localize("File access prompt")
        openPanel.title = YLFileAccess.localize("File access title")
        openPanel.message = String(format: YLFileAccess.localize("File access message"), YLFileAccess.appName)
        openPanel.showsHiddenFiles = false
        openPanel.isExtensionHidden = false
        openPanel.directoryURL = url
        openPanel.delegate = delegate
        return YLFileAccessOpenPanelModel(openPanel: openPanel, delegate: delegate)
    }
    
    // MARK: 点击了授权根目录按钮
    @objc private func authRootPath(_ btn: NSButton) {
        btn.isEnabled = false
        openPanelModel?.openPanel.close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            guard let model = openPanelModel, let completionHandler = model.completionHandler else { return }
            requestAccess(URL(fileURLWithPath: "/"), temp: model.tempAuth, completion: completionHandler)
        }
    }
    
    // MARK: - 取消授权
    
    public func cancelAccess(_ filePath: String) {
        cancelAccess(URL(fileURLWithPath: filePath))
    }
    
    public func cancelAccess(_ fileUrl: URL) {
        clearBookmarkData(for: fileUrl)
    }
    
    public func cancelAllAccess() {
        clearAllBookmarkDatas()
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
        var fileUrl = url
        while fileUrl.path.count > 1 {
            if let data = all[fileUrl.absoluteString] as? Data {
                return data
            }
            fileUrl = fileUrl.deletingLastPathComponent()
        }
        return all[fileUrl.absoluteString] as? Data
    }
    
    // MARK: 清除授权数据
    private func clearBookmarkData(for url: URL) {
        var all = allBookmarksInfo()
        all.removeValue(forKey: url.absoluteString)
        UserDefaults.standard.set(all, forKey: "YLBookmarkDatas")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: 清除所有授权数据
    private func clearAllBookmarkDatas() {
        UserDefaults.standard.removeObject(forKey: "YLBookmarkDatas")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: 保存授权数据
    private func saveBookmarkData(_ data: Data, for url: URL) {
        var all = allBookmarksInfo()
        all[url.absoluteString] = data
        UserDefaults.standard.set(all, forKey: "YLBookmarkDatas")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - 本地化
    
    static let bundle = Bundle(for: YLFileAccess.self)
    static func localize(_ key: String) -> String { YLFileAccess.bundle.localizedString(forKey: key, value: "", table: "YLFileAccess") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}

// MARK: - 选择路径的delegate

fileprivate class YLFileAccessOpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
    
    init(url: URL) {
        self.url = url
        self.paths = url.pathComponents
    }
    
    var url: URL
    private(set) var paths: [String]
    
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


// MARK: - 保存授权窗口的数据

fileprivate struct YLFileAccessOpenPanelModel {
    // 授权窗口
    var openPanel: NSOpenPanel
    // 代理，如果不强引用，会被释放，造成点击其他目录后卡住
    var delegate: YLFileAccessOpenPanelDelegate
    // 授权回调
    var completionHandler: ((Bool) -> Void)?
    // 是否是临时权限
    var tempAuth: Bool = false
}
