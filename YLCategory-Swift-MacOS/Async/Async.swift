//
//  Async.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/24.
//

import Foundation

public struct Async {
    
    private init() {}
    
    /// 延时执行
    /// - Parameters:
    ///   - seconds: 延时的秒数
    ///   - execute: 回调block
    ///   @Sendable：限定闭包的线程安全性，要求闭包中的捕获内容能安全地跨线程传递, 避免出现数据竞争问题。
    ///   @convention(block)：表明闭包以 Objective-C 的 block 调用约定执行, 用于与底层 GCD API 的交互，这些 API 是用 C 编写的。
    @discardableResult
    static func delay(_ seconds: Float, execute: @escaping @convention(block) () -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem(block: execute)
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds), execute: workItem)
        return workItem
    }
    
    /// 切换到子线程处理事务，完成后切换回主线程
    /// - Parameters:
    ///   - globalBlock: 子线程内执行
    ///   - block: 主线程内执行
    static func global(_ globalBlock: @escaping @Sendable @convention(block) () -> Void, main block: @escaping @Sendable @convention(block) () -> Void) {
        DispatchQueue.global().async {
            globalBlock()
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
