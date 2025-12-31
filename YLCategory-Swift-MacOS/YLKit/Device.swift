//
//  Device.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/12/31.
//

import Foundation

/// 获取设备的UUID，获取失败时，自动生成一个
public func GetUUID() -> String {
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    guard service != 0 else { return UUID().uuidString }
    defer { IOObjectRelease(service) }

    guard let str = IORegistryEntryCreateCFProperty(service, "IOPlatformUUID" as CFString, kCFAllocatorDefault, .zero).takeUnretainedValue() as? String else {
        return UUID().uuidString
    }
    return str
}
