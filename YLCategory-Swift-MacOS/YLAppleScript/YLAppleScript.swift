//
//  YLAppleScript.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/31.
//

import Foundation
import Carbon

public class YLAppleScript {
    
    /// 获取脚本的安装路径
    public class func getScriptLocalURL() -> URL? {
        var url: URL?
        do {
            url = try FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("获取脚本安装路径失败：\(error)")
        }
        return url
    }
    
    /// 脚本文件是否已安装
    /// - Parameter fileName: 文件名   apple_script.scpt
    /// - Returns: 返回 ture or false
    public class func scriptFileHasInstalled(_ fileName: String) -> Bool {
        guard !fileName.isEmpty else { return false }
        guard let destinationUrl = getScriptLocalURL()?.appendingPathComponent(fileName) else { return false }
        return FileManager.default.fileExists(atPath: destinationUrl.path)
    }
    
    /// 执行简单的脚本文件，如果本地不存在，从项目内拷贝到本地再运行
    /// - Parameter fileName: 文件名   apple_script.scpt
    /// - Parameter funcName: 文件内函数的名字
    /// - Parameter arguments: 函数的传参
    /// - Parameter completionHandler: 执行完毕的回调
    public class func executeScript(fileName: String, funcName: String? = nil, arguments: [Any]? = nil, completionHandler: NSUserAppleScriptTask.CompletionHandler? = nil) {
        // 给文件名拼上 ".scpt"
        var fileName = fileName
        if fileName.hasSuffix(".scpt") == false {
            fileName = fileName + ".scpt"
        }
        if let _ = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] {
            // 沙盒
            let scriptDirUrl = getScriptLocalURL()
            if let scriptUrl = scriptDirUrl?.appendingPathComponent(fileName),
               FileManager.default.fileExists(atPath: scriptUrl.path) {
                // 已经存在脚本，执行
                do {
                    let task = try NSUserAppleScriptTask(url: scriptUrl)
                    let descriptor = createEventDescriptor(funcName: funcName, arguments: arguments)
                    task.execute(withAppleEvent: descriptor) { result, error in
                        if let completionHandler = completionHandler {
                            DispatchQueue.main.async {
                                completionHandler(result, error)
                            }
                        }
                    }
                } catch {
                    YLHud.showError(YLAppleScript.localize("Script task creation failed"), to: NSApp.keyWindow)
                    print("Create apple script task error: \(error)")
                }
                return
            }
            // 脚本未安装
            installScript(fileName) { success in
                if success {
                    executeScript(fileName: fileName, funcName: funcName, arguments: arguments, completionHandler: completionHandler)
                } else {
                    YLHud.showError(YLAppleScript.localize("Install failed"), to: NSApp.keyWindow)
                }
            }
        } else {
            // 非沙盒
            guard let scriptUrl = Bundle.main.url(forResource: fileName, withExtension: nil) else {
                if let completionHandler = completionHandler {
                    DispatchQueue.main.async {
                        completionHandler(nil, nil)
                    }
                }
                return
            }
            DispatchQueue.global().async {
                var error: NSDictionary? = nil
                guard let appleScript = NSAppleScript(contentsOf: scriptUrl, error: &error),
                      let descriptor = createEventDescriptor(funcName: funcName, arguments: arguments) else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, error as? Error)
                    }
                    return
                }
                let result = appleScript.executeAppleEvent(descriptor, error: &error)
                DispatchQueue.main.async {
                    completionHandler?(result, error as? Error)
                }
            }
        }
    }
    
    /// 根据函数名和参数，创建 eventDescriptor
    /// - Parameters:
    ///   - funcName: 函数名
    ///   - arguments: 参数
    /// - Returns: 事件描述
    private class func createEventDescriptor(funcName: String?, arguments: [Any]?) -> NSAppleEventDescriptor? {
        guard let funcName = funcName, !funcName.isEmpty else { return nil }
        
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        let target = NSAppleEventDescriptor(descriptorType: typeProcessSerialNumber, bytes: &psn, length: MemoryLayout<ProcessSerialNumber>.size)
        let function = NSAppleEventDescriptor(string: funcName)
        let parameters = NSAppleEventDescriptor.list()
        
        arguments?.enumerated().forEach({ index, argument in
            let descriptor: NSAppleEventDescriptor?
            switch argument {
            case let string as String:
                descriptor = NSAppleEventDescriptor(string: string)
            case let number as NSNumber:
                descriptor = NSAppleEventDescriptor(int32: number.int32Value)
            case let bool as Bool:
                descriptor = NSAppleEventDescriptor(boolean: bool)
            case let double as Double:
                descriptor = NSAppleEventDescriptor(double: double)
            case let date as Date:
                descriptor = NSAppleEventDescriptor(date: date)
            case let url as URL:
                descriptor = NSAppleEventDescriptor(fileURL: url)
            default:
                descriptor = nil
            }
            if let descriptor = descriptor {
                parameters.insert(descriptor, at: index + 1)
            }
        })
        
        // 创建 apple event
        guard let eventClass = AEEventClass(exactly: UInt32(kASAppleScriptSuite)),
              let eventID = AEEventID(exactly: UInt32(kASSubroutineEvent)) else { return nil}
        let event = NSAppleEventDescriptor.appleEvent(withEventClass: eventClass, eventID: eventID, targetDescriptor: target, returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
        // 设置方法和参数
        event.setParam(function, forKeyword: AEKeyword(keyASSubroutineName))
        event.setParam(parameters, forKeyword: keyDirectObject)
        return event
    }
    
    /// 安装脚本文件到app脚本库
    /// - Parameters:
    ///   - fileName: 脚本文件名 apple_script.scpt
    ///   - handler: 执行后的回调
    public class func installScript(_ fileName: String, handler: @escaping ((Bool) -> Void)) {
        installScripts([fileName], handler: handler)
    }
    
    /// 安装多个脚本文件到app脚本库
    /// - Parameters:
    ///   - fileNames: 多个文件名
    ///   - handler: 执行后的回调
    public class func installScripts(_ fileNames: [String], handler: @escaping ((Bool) -> Void)) {
        guard fileNames.isEmpty else {
            assert(false, "fileNames must not be empty")
            handler(false)
            return
        }
        let alert = NSAlert()
        alert.messageText = YLAppleScript.localize("Kind tips")
        alert.informativeText = YLAppleScript.localize("Install first")
        alert.addButton(withTitle: YLAppleScript.localize("Install"))
        alert.addButton(withTitle: YLAppleScript.localize("Cancel"))
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            beginInstallScripts(fileNames) { success in
                if success {
                    YLHud.showSuccess(YLAppleScript.localize("Install succeed"), to: NSApp.keyWindow)
                } else {
                    YLHud.showError(YLAppleScript.localize("Install failed"), to: NSApp.keyWindow)
                }
                handler(success)
            }
        }
    }
    
    /// 开始安装脚本
    /// - Parameters:
    ///   - fileNames: 多个文件名
    ///   - handler: 执行后的回调
    private class func beginInstallScripts(_ fileNames: [String], handler: @escaping (Bool) -> Void) {
        guard let scriptLocalUrl = getScriptLocalURL() else {
            handler(false)
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = scriptLocalUrl
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.prompt = YLAppleScript.localize("Install script")
        openPanel.message = YLAppleScript.localize("Install script in current folder")
        openPanel.begin { result in
            if result == .cancel {
                print("User cancel install scripts")
                handler(false)
                return
            }
            guard let selectedUrl = openPanel.url,
                  selectedUrl == scriptLocalUrl else {
                // 目录不对,重新选择
                reinstallScripts(fileNames, handler: handler)
                return
            }
            var success = true
            for fileName in fileNames {
                guard let soureUrl = Bundle.main.url(forResource: fileName, withExtension: nil) else {
                    success = false
                    continue
                }
                let destinationUrl = scriptLocalUrl.appendingPathComponent(fileName)
                do {
                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
                        try FileManager.default.removeItem(at: destinationUrl)
                    }
                    try FileManager.default.copyItem(at: soureUrl, to: destinationUrl)
                } catch {
                    print("Failed to copy \(fileName): \(error.localizedDescription)")
                    success = false
                }
            }
            handler(success)
        }
    }
    
    private class func reinstallScripts(_ fileNames: [String], handler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = YLAppleScript.localize("Kind tips")
        alert.informativeText = YLAppleScript.localize("Install error path")
        alert.addButton(withTitle: YLAppleScript.localize("Reselect"))
        alert.addButton(withTitle: YLAppleScript.localize("Cancel"))
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            beginInstallScripts(fileNames, handler: handler)
        }
    }
    
    
    // MARK: - 本地化
    
    static func localize(_ key: String) -> String { Bundle(for: YLAppleScript.self).localizedString(forKey: key, value: "", table: "YLAppleScript") }
    
}
