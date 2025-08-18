//
//  NSSavePanel+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/8/6.
//

import AppKit

public struct YLSavePanelResponse {
    var response: NSApplication.ModalResponse
    var url: URL?
}

public extension NSSavePanel {
    
    
    /// 选择保存路径
    /// - Parameters:
    ///   - modalWindow: 要显示到的window
    ///   - title: 标题
    ///   - message: 显示的信息
    ///   - prompt: 保存按钮
    ///   - nameFieldLabel: 保存的文件名的标题
    ///   - directoryURL: 目标路径
    ///   - nameFieldStringValue: 保存的文件名，modal 前有效
    ///   - canCreateDirectories: 是否可以创建文件夹
    ///   - canSelectHiddenExtension: 是否显示隐藏扩展菜单项
    ///   - showsHiddenFiles: 是否显示隐藏文件
    ///   - isExtensionHidden: 扩展名是否隐藏
    ///   - accessoryView: 自定义view
    ///   - identifier: 标识符
    ///   - handler: 异步回调
    /// - Returns: 返回 savePanel
    @discardableResult
    class func show(for modalWindow: NSWindow? = nil,
                    title: String? = nil,
                    message: String? = nil,
                    prompt: String? = nil,
                    nameFieldLabel: String? = nil,
                    directoryURL: URL? = nil,
                    nameFieldStringValue: String? = nil,
                    canCreateDirectories: Bool = true,
                    canSelectHiddenExtension: Bool = false,
                    showsHiddenFiles: Bool = false,
                    isExtensionHidden: Bool = true,
                    accessoryView: NSView? = nil,
                    identifier: NSUserInterfaceItemIdentifier? = nil,
                    handler: @escaping (YLSavePanelResponse) -> Void) -> NSSavePanel {
        let savePanel = NSSavePanel()
        if let title = title { savePanel.title = title }
        if let message = message { savePanel.message = message }
        if let prompt = prompt { savePanel.prompt = prompt }
        if let nameFieldLabel = nameFieldLabel { savePanel.nameFieldLabel = nameFieldLabel }
        if let nameFieldStringValue = nameFieldStringValue { savePanel.nameFieldStringValue = nameFieldStringValue }
        savePanel.directoryURL = directoryURL
        savePanel.canCreateDirectories = canCreateDirectories
        savePanel.canSelectHiddenExtension = canSelectHiddenExtension
        savePanel.isExtensionHidden = isExtensionHidden
        savePanel.showsHiddenFiles = showsHiddenFiles
        savePanel.accessoryView = accessoryView
        savePanel.identifier = identifier
        if let modalWindow = modalWindow {
            savePanel.beginSheetModal(for: modalWindow) { response in
                handler(YLSavePanelResponse(response: response, url: savePanel.url))
            }
        } else {
            savePanel.begin { response in
                handler(YLSavePanelResponse(response: response, url: savePanel.url))
            }
        }
        return savePanel
    }
    
    /// 选择保存路径
    /// - Parameters:
    ///   - modalWindow: 要显示到的window
    ///   - title: 标题
    ///   - message: 显示的信息
    ///   - prompt: 保存按钮
    ///   - nameFieldLabel: 保存的文件名的标题
    ///   - directoryURL: 目标路径
    ///   - nameFieldStringValue: 保存的文件名，modal 前有效
    ///   - canCreateDirectories: 是否可以创建文件夹
    ///   - canSelectHiddenExtension: 是否显示隐藏扩展菜单项
    ///   - showsHiddenFiles: 是否显示隐藏文件
    ///   - isExtensionHidden: 扩展名是否隐藏
    ///   - accessoryView: 自定义view
    ///   - identifier: 标识符
    /// - Returns: 返回选择的结果
    @discardableResult
    class func show(for modalWindow: NSWindow? = nil,
                    title: String? = nil,
                    message: String? = nil,
                    prompt: String? = nil,
                    nameFieldLabel: String? = nil,
                    directoryURL: URL? = nil,
                    nameFieldStringValue: String? = nil,
                    canCreateDirectories: Bool = true,
                    canSelectHiddenExtension: Bool = false,
                    showsHiddenFiles: Bool = false,
                    isExtensionHidden: Bool = true,
                    accessoryView: NSView? = nil,
                    identifier: NSUserInterfaceItemIdentifier? = nil) -> YLSavePanelResponse {
        let savePanel = NSSavePanel()
        if let title = title { savePanel.title = title }
        if let message = message { savePanel.message = message }
        if let prompt = prompt { savePanel.prompt = prompt }
        if let nameFieldLabel = nameFieldLabel { savePanel.nameFieldLabel = nameFieldLabel }
        if let nameFieldStringValue = nameFieldStringValue { savePanel.nameFieldStringValue = nameFieldStringValue }
        savePanel.directoryURL = directoryURL
        savePanel.canCreateDirectories = canCreateDirectories
        savePanel.canSelectHiddenExtension = canSelectHiddenExtension
        savePanel.isExtensionHidden = isExtensionHidden
        savePanel.showsHiddenFiles = showsHiddenFiles
        savePanel.accessoryView = accessoryView
        savePanel.identifier = identifier
        let response = savePanel.runModal()
        return YLSavePanelResponse(response: response, url: savePanel.url)
    }
}
