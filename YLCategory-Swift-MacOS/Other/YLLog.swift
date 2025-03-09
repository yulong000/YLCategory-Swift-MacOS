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
            return "\(dict as NSDictionary)"
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
