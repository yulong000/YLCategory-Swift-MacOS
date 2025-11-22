//
//  File.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// url是否是文件夹
public func IsDirectory(_ url: URL) -> Bool {
    return IsDirectory(url.path)
}

/// path是否是文件夹
public func IsDirectory(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        return isDir.boolValue
    }
    return false
}

/// url是否是普通文件夹，而不是包
public func IsDirectoryNotPackage(_ url: URL) -> Bool {
    return IsDirectoryNotPackage(url.path)
}

/// path是否是普通文件夹,而不是包
public func IsDirectoryNotPackage(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        return isDir.boolValue
    }
    return false
}

/// 判断文件的类型, 传入URL
@available(macOS, introduced: 10.3, deprecated: 11.0, message: "请改用 File(_:isType:) 方法，支持基于 UTType 的类型判断")
public func File(_ url: URL, isType type: CFString) -> Bool {
    return File(url.path, isType: type)
}

/// 判断文件的类型, 传入path, eg: File("/Users/xxx/test.zip", isType: kUTTypeArchive)
@available(macOS, introduced: 10.3, deprecated: 11.0, message: "请改用 File(_:isType:) 方法，支持基于 UTType 的类型判断")
public func File(_ path: String, isType type: CFString) -> Bool {
    return File(path, isAnyOfTypes: [type])
}

/// 判断文件是否符合任一指定类型
@available(macOS, introduced: 10.3, deprecated: 11.0, message: "请改用 File(_:isAnyOfTypes:) 方法，支持基于 UTType 的类型判断")
public func File(_ path: String, isAnyOfTypes types: [CFString]) -> Bool {
    // 判断是否是目录
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else {
        return false
    }
    
    let ext = (path as NSString).pathExtension.lowercased()
    guard !ext.isEmpty else { return false }
    
    if #available(macOS 11.0, *) {
        if let utType = UTType(filenameExtension: ext) {
            for cfType in types {
                if let targetType = UTType(cfType as String),
                   utType.conforms(to: targetType) {
                    return true
                }
            }
            return false
        }
    }
    
    // 兼容旧系统
    if let cfUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() {
        for cfType in types {
            if UTTypeConformsTo(cfUTI, cfType) {
                return true
            }
        }
    }
    
    return false
}

/// 判断文件的类型, 传入URL (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ url: URL, isType type: UTType) -> Bool {
    return File(url.path, isAnyOfTypes: [type])
}

/// 判断文件的类型, 传入path (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ path: String, isType type: UTType) -> Bool {
    return File(path, isAnyOfTypes: [type])
}

/// 判断文件是否符合任一指定类型 (macOS 11.0 及以后)
@available(macOS 11.0, *)
public func File(_ path: String, isAnyOfTypes types: [UTType]) -> Bool {
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else {
        return false
    }
    
    let ext = (path as NSString).pathExtension.lowercased()
    guard !ext.isEmpty else { return false }
    
    guard let fileType = UTType(filenameExtension: ext) else {
        return false
    }
    
    for type in types {
        if fileType.conforms(to: type) {
            return true
        }
    }
    
    return false
}

/// 找出多个文件路径的公共部分，有可能是其中一个，有可能是共同的父目录(PATH)
public func TopPath(of paths: [String]) -> String {
    let urls = paths.map { URL(fileURLWithPath: ($0.isEmpty || $0 == "." ? "/" : $0)) }
    return TopUrl(of: urls).path
}

/// 找出多个文件路径的公共部分，有可能是其中一个，有可能是共同的父目录(URL)
public func TopUrl(of urls: [URL]) -> URL {
    guard !urls.isEmpty else { return URL(fileURLWithPath: "/") }

    // 把所有 URL 统一成目录路径（如果是文件则取它的父目录）
    let dirUrls = urls.map { url -> URL in
        var current = url.standardizedFileURL
        var isDir: ObjCBool = false
        while !FileManager.default.fileExists(atPath: current.path, isDirectory: &isDir) {
            let parent = current.deletingLastPathComponent()
            if parent.path == current.path {
                break
            }
            current = parent
        }
        if isDir.boolValue {
            return current
        } else {
            return current.deletingLastPathComponent()
        }
    }

    // 拆分路径组件
    let componentsList = dirUrls.map { $0.pathComponents }
    // 找出最短路径
    let shortest = componentsList.min(by: { $0.count < $1.count }) ?? []

    var commonComponents: [String] = []
    // 逐层比较组件
    for (i, component) in shortest.enumerated() {
        if componentsList.allSatisfy({ $0[i] == component }) {
            commonComponents.append(component)
        } else {
            break
        }
    }

    guard !commonComponents.isEmpty else { return URL(fileURLWithPath: "/") }

    // 拼接成共同父目录
    let commonPath = NSString.path(withComponents: commonComponents)
    return URL(fileURLWithPath: commonPath, isDirectory: true)
}

/// 找出多个文件路径的父目录的公共部分，一定是父目录(PATH)
public func ParentPath(of paths: [String]) -> URL {
    let urls = paths.map { URL(fileURLWithPath: ($0.isEmpty || $0 == "." ? "/" : $0)) }
    return ParentUrl(of: urls)
}

/// 找出多个文件路径的父目录的公共部分，一定是父目录(URL)
public func ParentUrl(of urls: [URL]) -> URL {
    let urls = urls.map { $0.deletingLastPathComponent() }
    return TopUrl(of: urls)
}
