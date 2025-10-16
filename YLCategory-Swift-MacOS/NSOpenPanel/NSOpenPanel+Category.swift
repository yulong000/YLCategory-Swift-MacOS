//
//  NSOpenPanel+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/8/6.
//

import AppKit

public extension NSOpenPanel {
    
    
    /// 选择文件（夹）路径
    /// - Parameters:
    ///   - modalWindow: 要显示到的window
    ///   - title: 标题
    ///   - message: 显示的信息
    ///   - prompt: 选择按钮
    ///   - directoryURL: 目标路径
    ///   - canChooseFiles: 是否可以选择文件
    ///   - canChooseDirectories: 是否可以选择文件夹
    ///   - allowsMultipleSelection: 是否可以多选
    ///   - canCreateDirectories: 是否可以创建文件夹
    ///   - allowedFileTypes: 允许的文件类型
    ///   - accessoryView: 自定义显示的view
    ///   - identifier: 标识符
    ///   - handler: 异步回调
    /// - Returns: 返回 openPanel
    @discardableResult
    class func open(for modalWindow: NSWindow? = nil,
                    title: String?,
                    message: String?,
                    prompt: String? = nil,
                    directoryURL: URL? = nil,
                    canChooseFiles: Bool,
                    canChooseDirectories: Bool,
                    allowsMultipleSelection: Bool = false,
                    canCreateDirectories: Bool = true,
                    allowedFileTypes: [String]? = nil,
                    accessoryView: NSView? = nil,
                    identifier: NSUserInterfaceItemIdentifier? = nil,
                    handler: @escaping ((NSApplication.ModalResponse, [URL]?)) -> Void) -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        if let title = title { openPanel.title = title }
        if let message = message { openPanel.message = message }
        if let prompt = prompt { openPanel.prompt = prompt }
        openPanel.directoryURL = directoryURL
        openPanel.canChooseFiles = canChooseFiles
        openPanel.canChooseDirectories = canChooseDirectories
        openPanel.allowsMultipleSelection = allowsMultipleSelection
        openPanel.canCreateDirectories = canCreateDirectories
        openPanel.allowedFileTypes = allowedFileTypes
        openPanel.accessoryView = accessoryView
        openPanel.identifier = identifier
        if let modalWindow = modalWindow {
            openPanel.beginSheetModal(for: modalWindow) { response in
                if response == .OK, !openPanel.urls.isEmpty {
                    handler((response, openPanel.urls))
                } else {
                    handler((response, nil))
                }
            }
        } else {
            openPanel.begin { response in
                if response == .OK, !openPanel.urls.isEmpty {
                    handler((response, openPanel.urls))
                } else {
                    handler((response, nil))
                }
            }
        }
        return openPanel
    }
    
    /// 选择文件（夹）路径
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 显示的信息
    ///   - prompt: 选择按钮
    ///   - directoryURL: 目标路径
    ///   - canChooseFiles: 是否可以选择文件
    ///   - canChooseDirectories: 是否可以选择文件夹
    ///   - allowsMultipleSelection: 是否可以多选
    ///   - canCreateDirectories: 是否可以创建文件夹
    ///   - allowedFileTypes: 允许的文件类型
    ///   - accessoryView: 自定义显示的view
    ///   - identifier: 标识符
    /// - Returns: 返回选择的结果
    @discardableResult
    class func open(title: String? = nil,
                    message: String?,
                    prompt: String? = nil,
                    directoryURL: URL? = nil,
                    canChooseFiles: Bool,
                    canChooseDirectories: Bool,
                    allowsMultipleSelection: Bool = false,
                    canCreateDirectories: Bool = true,
                    allowedFileTypes: [String]? = nil,
                    accessoryView: NSView? = nil,
                    identifier: NSUserInterfaceItemIdentifier? = nil) -> (NSApplication.ModalResponse, [URL]?) {
        let openPanel = NSOpenPanel()
        if let title = title { openPanel.title = title }
        if let message = message { openPanel.message = message }
        if let prompt = prompt { openPanel.prompt = prompt }
        openPanel.directoryURL = directoryURL
        openPanel.canChooseFiles = canChooseFiles
        openPanel.canChooseDirectories = canChooseDirectories
        openPanel.allowsMultipleSelection = allowsMultipleSelection
        openPanel.canCreateDirectories = canCreateDirectories
        openPanel.allowedFileTypes = allowedFileTypes
        openPanel.accessoryView = accessoryView
        openPanel.identifier = identifier
        let response = openPanel.runModal()
        if response == .OK {
            return (response, openPanel.urls)
        }
        return (response, nil)
    }
}
