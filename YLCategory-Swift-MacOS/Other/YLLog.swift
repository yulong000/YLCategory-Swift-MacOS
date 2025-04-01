//
//  YLLog.swift
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2024/12/3.
//

import Foundation
import Carbon
import Cocoa

public var YL_LOG_MORE: Bool = false // 是否可以打印更详细的信息
public var YL_LOG_RELEASE: Bool = false // 打包时是否打印

public func YLLog(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
#if !DEBUG
    guard YL_LOG_RELEASE else { return }
#endif
    var message: String = ""
    let formatItems = items.map { item -> String in
        if let dict = item as? [AnyHashable: Any] {
            return dict.format()
        }
        if let arr = item as? [Any] {
            return arr.format()
        }
        if let data = item as? Data {
            return data.format()
        }
        return "\(item)"
    }
    message = formatItems.joined(separator: "👈\n") + (formatItems.count > 1 ? "👈" : "")
    if YL_LOG_MORE {
        NSLog("%@\n[ %@ 第%d行 ] in %@", message, function, line, file.lastPathComponent)
    } else {
        NSLog("%@", message)
    }
}

open class __YLLog {
    
    public static var shared = __YLLog()
    private init() {}
    
    private var monitor: Any?
    
    // MARK: 监听按键
    open func addKeyMonitor() {
        if monitor != nil { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            let flags: NSEvent.ModifierFlags = [.control, .shift, .command, .option]
            if event.keyCode == kVK_ANSI_P && event.modifierFlags.intersection(flags) == flags {
                YL_LOG_RELEASE = !YL_LOG_RELEASE
            }
            if event.keyCode == kVK_ANSI_M && event.modifierFlags.intersection(flags) == flags {
                YL_LOG_MORE = !YL_LOG_MORE
            }
            return event
        }
    }
    
    open func removeKeyMonitor() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}


fileprivate extension Array {

    func format(with indentLevel: UInt8 = 0) -> String {
        // 最终输出的内容
        var desc: String = "[\n"
        // tab对齐
        var tab: String = ""
        for _ in 0..<indentLevel {
            tab.append("\t")
        }
        for obj in self {
            var valStr = "\(tab)\t"
            if let temp = obj as? [AnyHashable: Any] {
                // dict
                valStr += temp.format(with: indentLevel + 1)
            } else if let temp = obj as? [Any] {
                // array
                valStr += temp.format(with: indentLevel + 1)
            } else if let temp = obj as? Bool {
                // bool
                valStr += temp ? "true" : "false"
            } else if let temp = obj as? Data {
                // data
                valStr += temp.format()
            } else {
                valStr += "\(obj)"
            }
            valStr.append(",\n")
            desc.append(valStr)
        }
        // 去掉最后一个,号
        if let range = desc.range(of: ",", options: .backwards) {
            desc.replaceSubrange(range, with: "")
        }
        desc.append("\(tab)]")
        return desc
    }
}

fileprivate extension Dictionary {

    func format(with indentLevel: UInt8 = 0) -> String {
        
        // 最终输出的内容
        var desc: String = "{\n"
        // tab对齐
        var tab: String = ""
        for _ in 0..<indentLevel {
            tab.append("\t")
        }
        
        for k in keys {
            let obj = self[k]
            var key = "\(k)"
            if key.count > 0 {
                key = "\"\(key)\""
            }
            let keyStr = "\(tab)\t\(key): "
            var valStr = ""
            if let temp = obj as? String {
                // 字符串
                valStr = "\"\(temp)\""
            } else if let temp = obj as? Bool {
                // bool
                valStr = temp ? "true" : "false"
            } else if let temp = obj as? [AnyHashable: Any] {
                // dict
                valStr = temp.format(with: indentLevel + 1)
            } else if let temp = obj as? [Any] {
                // array
                valStr = temp.format(with: indentLevel + 1)
            } else if let temp = obj as? Data {
                // data
                valStr = temp.format()
            } else if let temp = obj {
                valStr = "\(temp)"
            } else {
                valStr = "nil"
            }
            valStr += ",\n"
            desc.append(keyStr + valStr)
        }
        // 去掉最后一个,号
        if let range = desc.range(of: ",", options: .backwards) {
            desc.replaceSubrange(range, with: "")
        }
        desc.append("\(tab)}")
        return desc
    }
}

fileprivate extension Data {
    func format() -> String {
        do {
            let result = try JSONSerialization.jsonObject(with: self, options: [])
            if let arr = result as? Array<Any> {
                var str = arr.format()
                str = str.replacingOccurrences(of: "\t", with: "")
                str = str.replacingOccurrences(of: "\n", with: " ")
                return "DATA:【 \(str) 】"
            }
            if let dict = result as? [AnyHashable: Any] {
                var str = dict.format()
                str = str.replacingOccurrences(of: "\t", with: "")
                str = str.replacingOccurrences(of: "\n", with: " ")
                return "DATA:【 \(str)) 】"
            }
        } catch {
            if let str = String(data: self, encoding: .utf8) {
                return "DATA:【 \(str) 】"
            }
        }
        return "\(self)"
    }
}
