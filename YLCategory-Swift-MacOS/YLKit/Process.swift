//
//  Process.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// 重启app
public func RestartApp() {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = ["-n", Bundle.main.bundlePath]
    task.launch()
    NSApp.terminate(nil)
}

/// 打开链接(path)
@discardableResult
public func OpenUrl(_ path: String) -> Bool {
    YLLog("Open url: \(path)")
    if let url = URL(string: path) {
        return NSWorkspace.shared.open(url)
    }
    return false
}

/// 打开链接（url）
@discardableResult
public func OpenUrl(_ url: URL) -> Bool {
    YLLog("Open url: \(url.path)")
    return NSWorkspace.shared.open(url)
}

/// 打开文件（夹）
@discardableResult
public func OpenFilePath(_ path: String) -> Bool {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    task.arguments = [path]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        YLLog("OpenFilePath: \(path) run error: \(error)")
        return false
    }
    
    if task.terminationStatus != 0 {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let msg = String(data: data, encoding: .utf8)
        YLLog("OpenFilePath: \(path) error: \(msg ?? "Unknown")")
        return false
    }
    
    return true
}


/// 执行命令， /bin/bash -c , cmd, argus
/// - Parameters:
///   - cmd: 命令
///   - argus: 参数
/// - Returns: 返回结果
@discardableResult
public func ExecuteCMD(_ cmd: String, argus: [String]? = nil, logEnable: Bool = true) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", cmd] + (argus ?? [])
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    do {
        try process.run()
    } catch {
        if logEnable {
            YLLog("❌ cmd '/bin/bash -c \(cmd)' 发生错误: \(error)")
        }
        return nil
    }
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if process.terminationStatus != 0 {
        if logEnable {
            YLLog("❌ cmd '/bin/bash -c \(cmd)' 执行失败: \(errorOutput)")
        }
        return nil
    }
    let result = output.count > 0 ? output : errorOutput
    if logEnable {
        if errorOutput.isEmpty {
            YLLog("✅ cmd '/bin/bash -c \(cmd)' 执行成功:\n\(result)")
        } else {
            YLLog("⚠️ cmd '/bin/bash -c \(cmd)' 执行成功:\n\(result)")
        }
    }
    return result
}


///  执行自定义命令, 传入自定义的执行命令路径和参数
/// - Parameters:
///   - url: 执行命令路径
///   - argus: 参数
///   - logEnable: 是否打印执行结果
/// - Returns: 执行结果
@discardableResult
public func ExecuteCustomCMD(_ url: String, argus: [String], logEnable: Bool = true) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: url)
    process.arguments = argus
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    do {
        try process.run()
    } catch {
        if logEnable {
            YLLog("❌ custom cmd '\(([url] + argus).joined(separator: " "))' 发生错误: \(error)")
        }
        return nil
    }
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if process.terminationStatus != 0 {
        if logEnable {
            YLLog("❌ custom cmd '\(([url] + argus).joined(separator: " "))' 执行失败: \(errorOutput)")
        }
        return nil
    }
    let result = output.count > 0 ? output : errorOutput
    if logEnable {
        if errorOutput.isEmpty {
            YLLog("✅ custom cmd '\(([url] + argus).joined(separator: " "))' 执行成功:\n\(result)")
        } else {
            YLLog("⚠️ custom cmd '\(([url] + argus).joined(separator: " "))' 执行成功:\n\(result)")
        }
    }
    return result
}
