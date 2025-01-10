//
//  NSObject+Event.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/25.
//

import Foundation
import AppKit

fileprivate var EventMonitorArrayKey = false

public extension NSObject {
    
    // MARK: 添加全局事件监听, 自动调用 addMonitor:
    @discardableResult
    func addGlobalEventMonitor(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void) -> Any? {
        let monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        addMonitor(monitor)
        return monitor
    }
    
    // MARK: 添加本地事件监听, 自动调用 addMonitor:
    @discardableResult
    func addLocalEventMonitor(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
        let monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
        addMonitor(monitor)
        return monitor
    }
    
    // MARK: 同时添加全局和本地事件监听, 自动调用 addMonitor:
    func addEventMonitor(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> NSEvent?) {
        // 添加全局监听
        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { event in
            _ = handler(event)
        }
        addMonitor(globalMonitor)
        
        // 添加本地监听
        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
        addMonitor(localMonitor)
    }
    
    // MARK: 移除单个监听
    func removeMonitor(_ monitor: Any) {
        NSEvent.removeMonitor(monitor)
        EventMonitorArray?.removeAll { $0 as AnyObject === monitor as AnyObject }
    }
    
    // MARK: 移除所有监听，只有通过 “add...” 添加的才能移除
    func removeAllMonitors() {
        EventMonitorArray?.forEach({ monitor in
            NSEvent.removeMonitor(monitor)
        })
        EventMonitorArray?.removeAll()
    }
    
    // MARK: 添加单个监听器
    func addMonitor(_ monitor: Any?) {
        guard let monitor = monitor else { return }
        addMonitors([monitor])
    }
    
    // MARK: 添加多个监听器
    func addMonitors(_ monitors: [Any]) {
        guard !monitors.isEmpty else { return }
        if EventMonitorArray == nil {
            EventMonitorArray = []
        }
        EventMonitorArray?.append(contentsOf: monitors)
    }
    
    // MARK: 存储事件监听器
    private var EventMonitorArray: [Any]? {
        get { objc_getAssociatedObject(self, &EventMonitorArrayKey) as? [Any] }
        set { objc_setAssociatedObject(self, &EventMonitorArrayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
