//
//  Environment.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// app运行环境的枚举
public enum AppEnvironment: String {
    case appStore       = "App store"       // App store 线上，或苹果审核
    case testFlight     = "TestFlight"      // TestFlight 测试
    case developerID    = "Developer ID"    // 线下分发的Apple公证过的app
    case adHoc          = "Ad Hoc"          // 特定人群的测试版本
    case development    = "Development"     // 开发调试
    case other          = "Other"           // 未知版本
}

/// app当前的运行环境
public let AppRunningEnvironment: AppEnvironment = {
    
    var environment: AppEnvironment = .other
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
    process.arguments = ["-dv", "--verbose=4", Bundle.main.bundlePath]
    
    let pipe = Pipe()
    // 输出内容在error里
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard process.terminationStatus == 0 else {
            YLLog("Get AppRunningEnvironment error: \(output)")
            return environment
        }
        // 审核中，正常应该是跟app store下载的一样
        // 有时返回的字符串是 /Applications/xxx.app: No such file or directory
        let list = output.components(separatedBy: "\n").compactMap { $0.hasPrefix("Authority") ? $0 : nil }
        for str in list {
            guard let evn = str.components(separatedBy: "=").last else { continue }
            switch evn {
            case "Apple Mac OS Application Signing":                    environment = .appStore
            case "TestFlight Beta Distribution":                        environment = .testFlight
            case let id where id.hasPrefix("Developer ID Application"): environment = .developerID
            case let id where id.hasPrefix("Apple Distribution"):       environment = .adHoc
            case let id where id.hasPrefix("Apple Development"):        environment = .development
            default: break
            }
        }
    } catch {
        YLLog("Get AppRunningEnvironment error: \(error)")
    }
    YLLog("当前App的运行环境为：\(environment.rawValue)")
    return environment
}()

/// 测试中
public let IsTesting = AppRunningEnvironment == .testFlight || AppRunningEnvironment == .development

/// app是沙盒
public let AppIsSanbox: Bool = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
