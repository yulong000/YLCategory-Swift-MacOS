//
//  Async.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/24.
//

import Foundation
import AppKit

public struct Async {
    
    private init() {}
    
    /// 延时执行
    /// - Parameters:
    ///   - seconds: 延时的秒数
    ///   - execute: 回调block
    ///   @convention(block)：表明闭包以 Objective-C 的 block 调用约定执行, 用于与底层 GCD API 的交互，这些 API 是用 C 编写的。
    @discardableResult
    public static func after(_ seconds: TimeInterval, execute: @escaping @convention(block) () -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem(block: execute)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem)
        return workItem
    }
    
    /// 回到主线程执行
    /// - Parameter block: 回调block
    @discardableResult
    public static func main(_ block: @escaping @convention(block) () -> Void) -> DispatchQueue {
        let queue = DispatchQueue.main
        queue.async {
            block()
        }
        return queue
    }
    
    /// 在子线程执行
    /// - Parameter block: 回调block
    @discardableResult
    public static func global(_ block: @escaping @convention(block) () -> Void) -> DispatchQueue {
        let queue = DispatchQueue.global()
        queue.async {
            block()
        }
        return queue
    }
    
    /// 切换到子线程处理事务，完成后切换回主线程
    /// - Parameters:
    ///   - globalBlock: 子线程内执行
    ///   - block: 主线程内执行
    public static func global(_ globalBlock: @escaping @convention(block) () -> Void, main block: @escaping @convention(block) () -> Void) {
        DispatchQueue.global().async {
            globalBlock()
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    /// 创建一个定时器，已做了循环引用的处理，防止内存泄漏
    /// - Parameters:
    ///   - interval: 重复时间
    ///   - target: target
    ///   - userInfo: 传递的数据
    ///   - repeats: 是否重复
    ///   - handler: 回调
    /// - Returns: 定时器
    public static func timer(with interval: TimeInterval, target: AnyObject, userInfo: Any? = nil, repeats: Bool = true, handler: @escaping (Timer) -> Void) -> Timer {
        let timerTarget = WeakTimerTarget()
        timerTarget.handler = handler
        timerTarget.target = target
        timerTarget.timer = Timer(timeInterval: interval, target: timerTarget, selector: #selector(WeakTimerTarget.fire), userInfo: userInfo, repeats: repeats)
        return timerTarget.timer!
    }
    
    /// 创建防抖函数
    /// - Parameters:
    ///   - interval: 指定秒内重复调用，只在最后一次执行
    ///   - action: 执行动作
    /// - Returns: 闭包
    public static func debounceAction(interval: TimeInterval, action: @escaping () -> Void) -> () -> Void {
        var index = 0
        return {
            let currentIndex = index + 1
            index = currentIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                if currentIndex == index {
                    action()
                    index = 0
                }
            }
        }
    }
    
    /// 创建节流函数
    /// - Parameters:
    ///   - interval: 指定秒内重复调用，只在第一次执行
    ///   - action: 执行动作
    /// - Returns: 闭包
    public static func onceAction(interval: TimeInterval, action: @escaping () -> Void) -> () -> Void {
        var index = 0
        return {
            if index == 0 { action() }
            let currentIndex = index + 1
            index = currentIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                if currentIndex == index { index = 0 }
            }
        }
    }
}


fileprivate class WeakTimerTarget: NSObject {
    var handler: ((Timer) -> Void)?
    var timer: Timer?
    weak var target: AnyObject?
    var observer: NSObjectProtocol?
    
    override init() {
        super.init()
        observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let timer = self?.timer {
                    // 从休眠中恢复，防止定时器失效，重新设置下时间
                    // 系统休眠时，偶尔会出现bug，定时器无法正常运行，不知道是定时器从循环中退出了，还是被系统设置了fireDate = [NSDate distantFuture]
                    timer.fireDate = Date(timeIntervalSinceNow: timer.timeInterval)
                }
            }
        }
    }
    
    @objc func fire() {
        guard target != nil else {
            timer?.invalidate()
            timer = nil
            return
        }
        handler?(timer!)
    }
    
    deinit {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        print("timer deinit")
    }
}
