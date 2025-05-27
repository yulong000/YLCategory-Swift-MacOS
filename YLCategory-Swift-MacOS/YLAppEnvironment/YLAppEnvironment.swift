//
//  YLAppEnvironment.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/5/28.
//

import Foundation

public enum AppEnvironment {
    case appStore       // app store 线上
    case testFlight     // testFlight 测试
    case development    // 开发/企业证书等
    case nonSandbox     // 非沙盒
}

public struct YLAppEnvironment {
    
    public static let shared = YLAppEnvironment()
    private init() {}
    
    public func getEnvironment() -> AppEnvironment {
        guard let _ = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] else {
            print("当前App环境: Non-sandbox")
            return .nonSandbox
        }
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptUrl.path) else {
            print("当前App环境: Development (receipt not exist)")
            return .development
        }
        var staticCode: SecStaticCode?
        guard SecStaticCodeCreateWithPath(receiptUrl as CFURL, [], &staticCode) == errSecSuccess,
              let code = staticCode else {
            print("当前App环境: Development (static code not exist)")
            return .development
        }
        if staticCodeHasOID(code, oid: "1.2.840.113635.100.6.11.1") {
            print("当前App环境: App store")
            return .appStore
        }
        
        if staticCodeHasOID(code, oid: "1.2.840.113635.100.6.1.25") {
            print("当前App环境: TestFlight")
            return .testFlight
        }
        print("当前App环境: Development (unknown)")
        return .development
    }
    
    func staticCodeHasOID(_ code: SecStaticCode, oid: String) -> Bool {
        var requirement: SecRequirement?
        let reqStr = "certificate leaf[\(oid)] exists" as CFString
        guard SecRequirementCreateWithString(reqStr, [], &requirement) == errSecSuccess,
              let req = requirement else {
            return false
        }
        return SecStaticCodeCheckValidity(code, [], req) == errSecSuccess
    }
}

