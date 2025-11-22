//
//  OS.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

public struct OS {
    
    /// 26.0 系统及以后
    public static let is26OrLater: Bool = { if #available(macOS 26.0, *) { true } else { false } }()
    /// 当前系统版本号
    public static let currentVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }()
    /// 判断当前系统是否 >= 传入的版本号
    public static func sameOrLater(than version: String) -> Bool {
        guard let v = parse(version) else { return false }
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(v)
    }
    /// 判断当前系统处于传入的两个版本号之间(>=min && < max)
    public static func between(min minVersion: String, max maxVersion: String) -> Bool {
        guard let min = parse(minVersion), let max = parse(maxVersion) else { return false }
        let current = ProcessInfo.processInfo.operatingSystemVersion
        return current >= min && current < max
    }
    /// 解析字符串为OperatingSystemVersion
    private static func parse(_ version: String) -> OperatingSystemVersion? {
        let parts = version.split(separator: ".").compactMap { Int($0) }
        guard parts.count > 0 else { return nil }
        return OperatingSystemVersion(
            majorVersion: parts.count > 0 ? parts[0] : 0,
            minorVersion: parts.count > 1 ? parts[1] : 0,
            patchVersion: parts.count > 2 ? parts[2] : 0
        )
    }
    
}

// MARK: 系统版本号大小判断运算符
public extension OperatingSystemVersion {
    
    static func == (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        return  lhs.majorVersion == rhs.majorVersion &&
                lhs.minorVersion == rhs.minorVersion &&
                lhs.patchVersion == rhs.patchVersion
    }
    static func < (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        if lhs.majorVersion != rhs.majorVersion {
            return lhs.majorVersion < rhs.majorVersion
        }
        if lhs.minorVersion != rhs.minorVersion {
            return lhs.minorVersion < rhs.minorVersion
        }
        return lhs.patchVersion < rhs.patchVersion
    }
    static func > (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool { rhs < lhs }
    static func <= (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool { lhs < rhs || lhs == rhs }
    static func >= (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool { lhs > rhs || lhs == rhs }
}

