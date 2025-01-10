//
//  YLLog.swift
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2024/12/3.
//

import Foundation

public var YL_LOG_MORE: Bool = false // 是否可以打印更详细的信息
public var YL_LOG_RELEASE: Bool = false // 打包时是否打印

public func YLLog(_ items: Any..., file: NSString = #file, function: String = #function, line: Int = #line) {
#if !DEBUG
    if(YL_LOG_RELEASE == false) { return }
#endif
    var message: String = ""
    if items.count == 1 {
        message = "\(items[0])"
    } else {
        for (index, item) in items.enumerated() {
            if index < items.count - 1 {
                message.append("\(item)👈\n")
            } else {
                message.append("\(item)👈")
            }
        }
    }
    if YL_LOG_MORE {
        NSLog("%@\n【%@ 第%d行】in %@", message, function, line, file.lastPathComponent)
    } else {
        NSLog("%@", message)
    }
}
